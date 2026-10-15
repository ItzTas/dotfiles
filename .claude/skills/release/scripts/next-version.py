#!/usr/bin/env python3
"""Work out the next release version from the last tag and the Conventional Commits since.

Usage: next-version.py [major|minor|patch|<version>] [-C dir]

Prints one JSON object:
  {"branch", "protected_branch", "last_tag", "last_version", "tag_prefix",
   "base_version", "base_source": "tag|manifest|default", "commits_since",
   "commits": {"<type>": [{"sha", "scope", "subject", "breaking"}], "other": [...]},
   "breaking": [{"sha", "subject", "note"}],
   "requested", "bump", "reason", "zero_major_rule", "next_version", "next_tag",
   "manifests": [{"path", "version", "field", "note"}], "lockfiles": [paths],
   "nested_manifests": [paths], "warnings": [...]}

Inference (no argument): BREAKING CHANGE footer or `!` -> major, feat -> minor,
anything else -> patch; before 1.0.0 a breaking change bumps the minor
(zero_major_rule). An explicit level or version is used as given.
Exit: 0 ok, 1 nothing to release (no commits since the last tag and no
explicit version), 2 error (not a git repo, bad argument).
"""

from __future__ import annotations

import argparse
import configparser
import json
import re
import subprocess
import sys
import tomllib
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path
from typing import cast, override

PROTECTED = {"main", "master", "dev", "develop", "pre-homolog"}
SEMVER = re.compile(r"(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?")
CONVENTIONAL = re.compile(r"^(?P<type>[A-Za-z]+)(?:\((?P<scope>[^)]*)\))?(?P<bang>!)?:\s*(?P<desc>.+)$")
BREAKING_FOOTER = re.compile(r"^BREAKING[ -]CHANGE:\s*(.+)$", re.MULTILINE)
TYPE_ORDER = ["feat", "fix", "perf", "refactor", "revert", "docs", "style", "test", "build", "ci", "chore"]
LOCKFILES = ["Cargo.lock", "package-lock.json", "npm-shrinkwrap.json", "yarn.lock", "pnpm-lock.yaml",
             "bun.lock", "bun.lockb", "uv.lock", "poetry.lock", "pdm.lock", "composer.lock", "deno.lock"]


@dataclass(frozen=True)
class Version:
    major: int
    minor: int
    patch: int
    pre: str | None = None

    @override
    def __str__(self) -> str:
        return f"{self.major}.{self.minor}.{self.patch}" + (f"-{self.pre}" if self.pre else "")

    def key(self) -> tuple[int, int, int, int]:
        return (self.major, self.minor, self.patch, 0 if self.pre else 1)

    def bump(self, level: str) -> Version:
        """npm-style increment: a pre-release base is finalized when the level allows it."""
        steps: dict[str, Callable[[Version], Version]] = {
            "major": lambda v: Version(v.major, 0, 0) if v.pre and v.minor == 0 and v.patch == 0 else Version(v.major + 1, 0, 0),
            "minor": lambda v: Version(v.major, v.minor, 0) if v.pre and v.patch == 0 else Version(v.major, v.minor + 1, 0),
            "patch": lambda v: Version(v.major, v.minor, v.patch) if v.pre else Version(v.major, v.minor, v.patch + 1),
        }
        return steps[level](self)


def parse_version(text: str) -> tuple[str, Version] | None:
    """Returns (prefix, version) for the first semver found in text."""
    match = SEMVER.search(text)
    if not match:
        return None
    major, minor, patch, pre = match.groups()
    return text[: match.start()], Version(int(major), int(minor), int(patch), pre)


def git(root: Path, *args: str) -> str | None:
    result = subprocess.run(["git", "-C", str(root), *args], capture_output=True, text=True, check=False)
    return result.stdout.strip() if result.returncode == 0 else None


def last_tag(root: Path) -> str | None:
    for match in ("v[0-9]*", "[0-9]*", "*"):
        tag = git(root, "describe", "--tags", "--abbrev=0", "--match", match)
        if tag:
            return tag
    return None


def commits_since(root: Path, tag: str | None) -> list[dict[str, object]]:
    rng = f"{tag}..HEAD" if tag else "HEAD"
    raw = git(root, "log", "--no-merges", "--format=%H%x1f%s%x1f%b%x1e", rng) or ""
    commits: list[dict[str, object]] = []
    for record in filter(None, (r.strip("\n") for r in raw.split("\x1e"))):
        sha, subject, body = (record.split("\x1f") + ["", ""])[:3]
        match = CONVENTIONAL.match(subject)
        footer = BREAKING_FOOTER.search(body)
        commits.append({
            "sha": sha[:10],
            "type": match.group("type").lower() if match else "other",
            "scope": (match.group("scope") or None) if match else None,
            "subject": subject,
            "breaking": bool((match and match.group("bang")) or footer),
            "note": footer.group(1).strip() if footer else None,
        })
    return commits


def group(commits: list[dict[str, object]]) -> dict[str, list[dict[str, object]]]:
    grouped: dict[str, list[dict[str, object]]] = {}
    rank = {t: i for i, t in enumerate(TYPE_ORDER)}
    for commit in sorted(commits, key=lambda c: rank.get(str(c["type"]), len(rank) + (c["type"] == "other"))):
        entry = {k: commit[k] for k in ("sha", "scope", "subject", "breaking")}
        grouped.setdefault(str(commit["type"]), []).append(entry)
    return grouped


def infer(commits: list[dict[str, object]], base: Version) -> tuple[str | None, str, bool]:
    """Returns (bump, reason, zero_major_rule_applied)."""
    breaking = [c for c in commits if c["breaking"]]
    if breaking and base.major == 0:
        return "minor", f"{len(breaking)} breaking change(s), but pre-1.0 a breaking change bumps the minor", True
    if breaking:
        return "major", f"{len(breaking)} breaking change(s) (BREAKING CHANGE footer or `!`)", False
    feats = sum(1 for c in commits if c["type"] == "feat")
    if feats:
        return "minor", f"{feats} feat commit(s), no breaking changes", False
    if commits:
        return "patch", f"{len(commits)} commit(s), no feat or breaking changes", False
    return None, "no commits since the last tag", False


def read_toml(path: Path) -> dict[str, object]:
    try:
        return tomllib.loads(path.read_text(encoding="utf-8"))
    except (OSError, tomllib.TOMLDecodeError):
        return {}


def read_json(path: Path) -> dict[str, object]:
    try:
        data = cast(object, json.loads(path.read_text(encoding="utf-8")))
    except (OSError, json.JSONDecodeError):
        return {}
    return cast(dict[str, object], data) if isinstance(data, dict) else {}


def dig(node: object, *keys: str) -> object:
    if not keys:
        return node
    if not isinstance(node, dict):
        return None
    return dig(cast(dict[str, object], node).get(keys[0]), *keys[1:])


def manifest(path: str, version: object, field: str, note: str | None = None) -> dict[str, object]:
    return {"path": path, "version": version if isinstance(version, str) else None, "field": field, "note": note}


def cargo_manifest(root: Path) -> list[dict[str, object]]:
    data = read_toml(root / "Cargo.toml")
    if not data:
        return []
    found: list[dict[str, object]] = []
    package = dig(data, "package", "version")
    if isinstance(package, dict):
        found.append(manifest("Cargo.toml", None, "package.version", "inherits workspace.package.version"))
    elif package is not None:
        found.append(manifest("Cargo.toml", package, "package.version"))
    workspace = dig(data, "workspace", "package", "version")
    if workspace is not None:
        found.append(manifest("Cargo.toml", workspace, "workspace.package.version"))
    return found


def node_manifests(root: Path) -> list[dict[str, object]]:
    found: list[dict[str, object]] = []
    for name in ("package.json", "deno.json", "jsr.json", "composer.json"):
        data = read_json(root / name)
        if not data:
            continue
        note = "private package" if data.get("private") is True else None
        if "workspaces" in data:
            note = "workspace root" + (", private" if note else "")
        found.append(manifest(name, data.get("version"), "version", note))
    return found


def python_manifests(root: Path) -> list[dict[str, object]]:
    found: list[dict[str, object]] = []
    data = read_toml(root / "pyproject.toml")
    dynamic = dig(data, "project", "dynamic")
    if isinstance(dynamic, list) and "version" in dynamic:
        found.append(manifest("pyproject.toml", None, "project.version", "dynamic: set by the build backend (e.g. hatch/setuptools-scm)"))
    elif dig(data, "project", "version") is not None:
        found.append(manifest("pyproject.toml", dig(data, "project", "version"), "project.version"))
    if dig(data, "tool", "poetry", "version") is not None:
        found.append(manifest("pyproject.toml", dig(data, "tool", "poetry", "version"), "tool.poetry.version"))
    setup_cfg = root / "setup.cfg"
    if setup_cfg.is_file():
        parser = configparser.ConfigParser()
        _ = parser.read(setup_cfg, encoding="utf-8")
        if parser.has_option("metadata", "version"):
            found.append(manifest("setup.cfg", parser.get("metadata", "version"), "metadata.version"))
    return found


def plain_manifests(root: Path) -> list[dict[str, object]]:
    found: list[dict[str, object]] = []
    for name in ("VERSION", "version.txt"):
        path = root / name
        if path.is_file():
            found.append(manifest(name, path.read_text(encoding="utf-8").strip() or None, "file content"))
    return found


def nested_manifests(root: Path) -> list[str]:
    listing = git(root, "ls-files", "--", "*/Cargo.toml", "*/package.json", "*/pyproject.toml") or ""
    return listing.splitlines()[:50]


class Args(argparse.Namespace):
    target: str | None = None
    C: str = "."


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    _ = parser.add_argument("target", nargs="?", help="major | minor | patch | <version>")
    _ = parser.add_argument("-C", default=".", help="repository directory (default: cwd)")
    args = parser.parse_args(namespace=Args())
    root_text = git(Path(args.C), "rev-parse", "--show-toplevel")
    if not root_text:
        print("next-version: not inside a git repository", file=sys.stderr)
        return 2
    root = Path(root_text)
    requested = args.target.strip().lower() if args.target else None
    explicit = parse_version(requested.lstrip("v")) if requested and requested not in ("major", "minor", "patch") else None
    if requested and requested not in ("major", "minor", "patch") and not explicit:
        print(f"next-version: not a bump level or version: {args.target}", file=sys.stderr)
        return 2

    warnings: list[str] = []
    tag = last_tag(root)
    parsed_tag = parse_version(tag) if tag else None
    if tag and not parsed_tag:
        warnings.append(f"last tag {tag!r} has no semver in it; using the manifest version as the base")
    manifests = [*cargo_manifest(root), *node_manifests(root), *python_manifests(root), *plain_manifests(root)]
    manifest_version = next((parse_version(str(m["version"])) for m in manifests if m["version"]), None)

    prefix, base, base_source = "v", Version(0, 0, 0), "default"
    if parsed_tag:
        (prefix, base), base_source = parsed_tag, "tag"
    elif manifest_version:
        base, base_source = manifest_version[1], "manifest"
    if not parsed_tag and tag is None:
        warnings.append("no tags yet: this is the first release (the manifest version may already be the one to tag)")
    if manifest_version and parsed_tag and manifest_version[1] != parsed_tag[1]:
        warnings.append(f"manifest version {manifest_version[1]} differs from the last tag {tag}")

    commits = commits_since(root, tag)
    if explicit:
        bump, reason, zero_rule = None, "explicit version requested", False
        next_version = explicit[1]
        if next_version.key() <= base.key() and base_source != "default":
            warnings.append(f"requested version {next_version} is not greater than {base}")
    elif requested:
        bump, reason, zero_rule = requested, f"{requested} requested explicitly", False
        next_version = base.bump(requested)
    else:
        bump, reason, zero_rule = infer(commits, base)
        next_version = base.bump(bump) if bump else None

    branch = git(root, "branch", "--show-current") or None
    out = {
        "branch": branch,
        "protected_branch": branch in PROTECTED,
        "last_tag": tag,
        "last_version": str(parsed_tag[1]) if parsed_tag else None,
        "tag_prefix": prefix,
        "base_version": str(base),
        "base_source": base_source,
        "commits_since": len(commits),
        "commits": group(commits),
        "breaking": [{"sha": c["sha"], "subject": c["subject"], "note": c["note"]} for c in commits if c["breaking"]],
        "requested": requested,
        "bump": bump,
        "reason": reason,
        "zero_major_rule": zero_rule,
        "next_version": str(next_version) if next_version else None,
        "next_tag": f"{prefix}{next_version}" if next_version else None,
        "manifests": manifests,
        "lockfiles": [name for name in LOCKFILES if (root / name).is_file()],
        "nested_manifests": nested_manifests(root),
        "warnings": warnings,
    }
    json.dump(out, sys.stdout, separators=(",", ":"))
    _ = sys.stdout.write("\n")
    return 0 if next_version else 1


if __name__ == "__main__":
    sys.exit(main())
