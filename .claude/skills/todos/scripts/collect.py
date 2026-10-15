#!/usr/bin/env python3
"""todos helper: collects TODO/FIXME-style markers into one JSON report.

Searches with rg (honors .gitignore), falling back to grep -r. Skips vendored/generated dirs
and never reads anything under $HOME/.config/zsh/secrets.
"""

from __future__ import annotations

import glob
import json
import os
import re
import shutil
import subprocess
import sys
from collections import Counter
from dataclasses import asdict, dataclass
from typing import cast

USAGE = """\
Usage: collect.py [--limit N] [marker | path | 'glob' ...]

  marker  one of TODO FIXME HACK XXX BUG OPTIMIZE NOTE: report only that marker
  path    file or dir to scan; quote globs ('src/**/*.ts') so this script expands them
  default: every marker, whole repo (or cwd outside a repo)
  --limit N  list at most N items (default 300, 0 = all); counts always cover everything

stdout: {"tool", "paths", "markers", "counts": {MARKER: n}, "total",
         "items": [{marker, urgency, file, line, owner, text}], "truncated"?: n}
  items are ordered FIXME, BUG, XXX (high), TODO, HACK, OPTIMIZE (medium), NOTE (low),
  then by file and line; file is relative to the current directory.
Exit: 0 ok (with or without findings), 2 usage/environment error.
"""

MARKERS = ("FIXME", "BUG", "XXX", "TODO", "HACK", "OPTIMIZE", "NOTE")
URGENCY = {"FIXME": "high", "BUG": "high", "XXX": "high", "TODO": "medium", "HACK": "medium",
           "OPTIMIZE": "medium", "NOTE": "low"}
SKIP_DIRS = (".git", "node_modules", "target", "dist", "build", "vendor")
DEFAULT_LIMIT = 300
MAX_TEXT = 200

SECRETS_DIR = os.path.join(os.path.expanduser("~"), ".config", "zsh", "secrets")
SECRETS_REAL = os.path.realpath(SECRETS_DIR)

# A marker counts when it opens a comment (`// TODO`, `# FIXME`, ` * NOTE`) or has the
# `MARKER:` / `MARKER(owner):` shape. Identifiers, string values (an enum member called TODO,
# "XXX-XXXX" masks) and the word used mid-sentence ("fixed the BUG in") don't.
COMMENT_OPENER = re.compile(r"(?://+|#+|/\*+|<!--|\(\*|\{-|--+|;+|^\s*\*+|^\s*%+)[\s!*/-]*$")
COLON_FORM = re.compile(r"^\(([^)]*)\)\s*:|^\s*:")
OWNER = re.compile(r"^\(\s*@?([^)]*?)\s*\)")
TRAILING_CLOSER = re.compile(r"\s*(\*/|-->|\*\)|-\}|\"\"\"|''')\s*$")


@dataclass
class Item:
    marker: str
    urgency: str
    file: str
    line: int
    owner: str | None
    text: str


class UsageError(Exception):
    pass


def in_secrets(path: str) -> bool:
    return any(path == d or path.startswith(d + os.sep) for d in (SECRETS_DIR, SECRETS_REAL))


def safe_resolve(path: str) -> str:
    """Resolves one component at a time so nothing under the secrets dir is ever stat'ed."""
    lexical = os.path.normpath(os.path.abspath(path))
    if in_secrets(lexical):
        raise UsageError(f"refusing to scan inside {SECRETS_DIR}")
    resolved = os.sep
    for part in lexical.split(os.sep):
        if not part:
            continue
        resolved = os.path.realpath(os.path.join(resolved, part))
        if in_secrets(resolved):
            raise UsageError(f"refusing to scan inside {SECRETS_DIR}")
    return resolved


def marker_filter(arg: str) -> str | None:
    if arg in MARKERS:
        return arg
    upper = arg.upper()
    if upper in MARKERS and not os.path.lexists(arg):
        return upper
    return None


def glob_root(pattern: str) -> str:
    """Literal directory prefix of a glob, the part rg can search without expanding it."""
    literal: list[str] = []
    for part in pattern.split(os.sep):
        if glob.has_magic(part):
            break
        literal.append(part)
    root = os.sep.join(literal)
    return root or (os.sep if pattern.startswith(os.sep) else ".")


@dataclass
class PathGlob:
    regex: re.Pattern[str]
    absolute: bool

    def matches(self, path: str) -> bool:
        return self.regex.match(path if self.absolute else os.path.relpath(path)) is not None


@dataclass
class Scope:
    roots: list[str]
    globs: list[PathGlob]


def build_scope(path_args: list[str]) -> Scope:
    if not path_args:
        top = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                             text=True, check=False)
        path_args = [top.stdout.strip() if top.returncode == 0 else "."]
    roots: list[str] = []
    globs: list[PathGlob] = []
    for arg in path_args:
        if glob.has_magic(arg) and not os.path.lexists(arg):
            pattern = os.path.normpath(arg)
            regex = re.compile(glob.translate(pattern, recursive=True, include_hidden=True))
            globs.append(PathGlob(regex, os.path.isabs(pattern)))
            arg = glob_root(pattern)
        resolved = safe_resolve(arg)
        if not os.path.exists(resolved):
            raise UsageError(f"no such path: {arg}")
        roots.append(resolved)
    return Scope(roots, globs)


def rg_glob_escape(path: str) -> str:
    return re.sub(r"([\\*?\[\]{}])", r"\\\1", path)


def search_pattern(markers: list[str]) -> str:
    words = r"\b(" + "|".join(markers) + r")\b"  # plain group: grep -E has no (?:)
    return words + r"|@todo\b" if "TODO" in markers else words


def run_rg(pattern: str, roots: list[str]) -> list[tuple[str, int, str]]:
    excludes = [f"!{d}/" for d in SKIP_DIRS] + ["!.git"]
    excludes += [f"!{rg_glob_escape(d)}" for d in {SECRETS_DIR, SECRETS_REAL}]
    cmd = ["rg", "--json", "--hidden", "--no-messages", "-e", pattern]
    for g in excludes:
        cmd += ["-g", g]
    # Absolute roots + cwd=/ make rg match the anchored secrets globs against full paths.
    proc = subprocess.run([*cmd, "--", *roots], capture_output=True, text=True, cwd=os.sep,
                          check=False)
    if proc.returncode == 2 and not proc.stdout:
        raise RuntimeError(f"rg failed: {proc.stderr.strip()}")
    hits: list[tuple[str, int, str]] = []
    for raw in proc.stdout.splitlines():
        event = cast(object, json.loads(raw))
        if dig(event, "type") != "match":
            continue
        path = dig(event, "data", "path", "text")
        line = dig(event, "data", "line_number")
        text = dig(event, "data", "lines", "text")
        if isinstance(path, str) and isinstance(line, int) and isinstance(text, str):
            hits.append((path, line, text))
    return hits


def run_grep(pattern: str, roots: list[str]) -> list[tuple[str, int, str]]:
    cmd = ["grep", "-rnIEZ", *[f"--exclude-dir={d}" for d in SKIP_DIRS]]
    if any(contains_secrets(r) for r in roots):
        # grep only matches base names: skip every dir called "secrets" rather than risk it.
        cmd += [f"--exclude-dir={os.path.basename(d)}" for d in {SECRETS_DIR, SECRETS_REAL}]
    proc = subprocess.run([*cmd, "-e", pattern, "--", *roots], capture_output=True, text=True,
                          errors="replace", check=False)
    if proc.returncode == 2 and not proc.stdout:
        raise RuntimeError(f"grep failed: {proc.stderr.strip()}")
    hits: list[tuple[str, int, str]] = []
    for raw in proc.stdout.splitlines():
        path, _, rest = raw.partition("\0")
        line, _, text = rest.partition(":")
        if line.isdigit():
            hits.append((path, int(line), text))
    return hits


def contains_secrets(root: str) -> bool:
    return any(os.path.commonpath([root, d]) == root for d in (SECRETS_DIR, SECRETS_REAL))


def dig(obj: object, *keys: str) -> object:
    for key in keys:
        if not isinstance(obj, dict):
            return None
        obj = cast(dict[str, object], obj).get(key)
    return obj


def counts_as_marker(line: str, start: int, end: int) -> bool:
    if line[start] == "@":
        return True
    if COMMENT_OPENER.search(line[:start]):
        return True
    return COLON_FORM.match(line[end:]) is not None


def clean_text(rest: str) -> tuple[str | None, str]:
    owner: str | None = None
    owner_match = OWNER.match(rest)
    if owner_match:
        owner = owner_match.group(1) or None
        rest = rest[owner_match.end():]
    text = TRAILING_CLOSER.sub("", rest.lstrip(" \t:-!").rstrip()).rstrip()
    if len(text) > MAX_TEXT:
        text = text[:MAX_TEXT].rstrip() + "…"
    return owner, text


def parse_hit(path: str, line_no: int, line: str, regex: re.Pattern[str]) -> Item | None:
    line = line.rstrip("\r\n")
    for match in regex.finditer(line):
        if not counts_as_marker(line, match.start(), match.end()):
            continue
        marker = match.group(0).lstrip("@").upper()
        owner, text = clean_text(line[match.end():])
        return Item(marker, URGENCY[marker], os.path.relpath(path), line_no, owner, text)
    return None


def collect(markers: list[str], scope: Scope) -> tuple[str, list[Item]]:
    pattern = search_pattern(markers)
    tool = "rg" if shutil.which("rg") else "grep"
    hits = (run_rg if tool == "rg" else run_grep)(pattern, scope.roots)
    regex = re.compile(pattern)
    items: list[Item] = []
    for path, line_no, text in hits:
        if scope.globs and not any(g.matches(path) for g in scope.globs):
            continue
        item = parse_hit(path, line_no, text, regex)
        if item:
            items.append(item)
    items.sort(key=lambda i: (MARKERS.index(i.marker), i.file, i.line))
    return tool, items


def parse_args(argv: list[str]) -> tuple[list[str], list[str], int]:
    markers: list[str] = []
    paths: list[str] = []
    limit = DEFAULT_LIMIT
    args = iter(argv)
    for arg in args:
        if arg in ("-h", "--help"):
            print(USAGE, end="")
            sys.exit(0)
        if arg == "--limit":
            value = next(args, "")
            if not value.isdigit():
                raise UsageError("--limit needs a number")
            limit = int(value)
            continue
        marker = marker_filter(arg)
        if marker:
            markers.append(marker)
            continue
        paths.append(arg)
    return markers or list(MARKERS), paths, limit


def main(argv: list[str]) -> int:
    try:
        markers, path_args, limit = parse_args(argv)
        scope = build_scope(path_args)
        tool, items = collect(markers, scope)
    except UsageError as err:
        print(f"collect.py: {err}", file=sys.stderr)
        return 2
    except RuntimeError as err:
        print(f"collect.py: {err}", file=sys.stderr)
        return 2
    counts = Counter(i.marker for i in items)
    shown = items[:limit] if limit else items
    report: dict[str, object] = {
        "tool": tool,
        "paths": [os.path.relpath(r) for r in scope.roots],
        "markers": [m for m in MARKERS if m in markers],
        "counts": {m: counts[m] for m in MARKERS if counts[m]},
        "total": len(items),
        "items": [asdict(i) for i in shown],
    }
    if len(shown) < len(items):
        report["truncated"] = len(items) - len(shown)
    print(json.dumps(report, ensure_ascii=False, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
