#!/usr/bin/env python3
"""Detect a project's stack: ecosystems, package managers, proto pins, task runners,
env templates, git hooks, linter configs and which relevant tools are installed.

Prints one JSON object on stdout. Read-only: never reads the contents of env files.
Exit: 0 ok, 2 bad path.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path
from typing import cast

SKIP_DIRS = {
    ".git", "node_modules", "target", "vendor", "dist", "build", ".venv", "venv",
    "__pycache__", ".next", ".nuxt", ".svelte-kit", ".yarn", ".tox", ".mypy_cache",
}
SECRETS_DIR = Path.home() / ".config" / "zsh" / "secrets"
MASON_BIN = Path.home() / ".local" / "share" / "nvim" / "mason" / "bin"

# manifest file name -> ecosystem
MANIFESTS = {
    "package.json": "node",
    "go.mod": "go",
    "Cargo.toml": "rust",
    "pyproject.toml": "python",
    "requirements.txt": "python",
    "setup.py": "python",
    "composer.json": "php",
    "Gemfile": "ruby",
    "build.gradle": "jvm",
    "build.gradle.kts": "jvm",
    "pom.xml": "jvm",
    "mix.exs": "elixir",
    "pubspec.yaml": "dart",
}
MANIFEST_SUFFIXES = {".rockspec": "lua", ".csproj": "dotnet"}

# lockfile name -> (ecosystem, package manager)
LOCKFILES = {
    "pnpm-lock.yaml": ("node", "pnpm"),
    "yarn.lock": ("node", "yarn"),
    "package-lock.json": ("node", "npm"),
    "bun.lockb": ("node", "bun"),
    "bun.lock": ("node", "bun"),
    "uv.lock": ("python", "uv"),
    "poetry.lock": ("python", "poetry"),
    "pdm.lock": ("python", "pdm"),
    "Pipfile.lock": ("python", "pipenv"),
    "Cargo.lock": ("rust", "cargo"),
    "go.sum": ("go", "go"),
    "composer.lock": ("php", "composer"),
    "Gemfile.lock": ("ruby", "bundler"),
    "mix.lock": ("elixir", "mix"),
    "pubspec.lock": ("dart", "pub"),
}
DEFAULT_PM = {
    "node": "npm", "go": "go", "rust": "cargo", "python": "pip", "php": "composer",
    "ruby": "bundler", "lua": "luarocks", "elixir": "mix", "dart": "pub", "dotnet": "dotnet",
}

# config file name -> tool it configures
LINTER_CONFIGS = {
    "eslint.config.js": "eslint", "eslint.config.mjs": "eslint", "eslint.config.cjs": "eslint",
    "eslint.config.ts": "eslint", ".eslintrc": "eslint", ".eslintrc.js": "eslint",
    ".eslintrc.cjs": "eslint", ".eslintrc.json": "eslint", ".eslintrc.yml": "eslint",
    ".prettierrc": "prettier", ".prettierrc.json": "prettier", "prettier.config.js": "prettier",
    ".prettierrc.yml": "prettier", "biome.json": "biome", "biome.jsonc": "biome",
    "tsconfig.json": "tsc", "ruff.toml": "ruff", ".ruff.toml": "ruff", "mypy.ini": "mypy",
    "pyrightconfig.json": "basedpyright", ".golangci.yml": "golangci-lint",
    ".golangci.yaml": "golangci-lint", ".golangci.toml": "golangci-lint", "clippy.toml": "clippy",
    "rustfmt.toml": "rustfmt", ".luacheckrc": "luacheck", "selene.toml": "selene",
    "stylua.toml": "stylua", ".stylua.toml": "stylua", "phpstan.neon": "phpstan",
    "phpstan.neon.dist": "phpstan", ".php-cs-fixer.php": "php-cs-fixer",
    ".php-cs-fixer.dist.php": "php-cs-fixer", ".yamllint": "yamllint", ".yamllint.yml": "yamllint",
    ".hadolint.yaml": "hadolint", ".shellcheckrc": "shellcheck", "detekt.yml": "detekt",
    ".editorconfig": "editorconfig", "_typos.toml": "typos", ".typos.toml": "typos",
}
PYPROJECT_TOOLS = {"ruff": "ruff", "mypy": "mypy", "pyright": "pyright", "basedpyright": "basedpyright",
                   "pytest": "pytest", "black": "black", "uv": "uv", "poetry": "poetry", "pdm": "pdm"}

# ecosystem -> binaries worth reporting
ECOSYSTEM_TOOLS = {
    "node": ["node", "npm", "npx", "pnpm", "yarn", "bun"],
    "go": ["go", "golangci-lint", "govulncheck", "gopls"],
    "rust": ["cargo", "cargo-audit", "cargo-llvm-cov", "cargo-tarpaulin", "critcmp", "cargo-outdated"],
    "python": ["python3", "uv", "poetry", "pdm", "pip-audit", "ruff", "basedpyright"],
    "php": ["php", "composer", "phpstan"],
    "ruby": ["ruby", "bundle"],
    "lua": ["luarocks", "luacheck", "selene", "stylua"],
    "jvm": ["java", "gradle", "mvn", "ktlint", "detekt"],
    "elixir": ["mix"],
    "dart": ["dart", "flutter"],
    "dotnet": ["dotnet"],
}
ALWAYS_TOOLS = ["proto", "docker", "make", "just", "task", "hyperfine", "trivy", "hadolint", "shellcheck"]

# .env.example -> .env, .env.local.sample -> .env.local, config.example.yml -> config.yml
ENV_TEMPLATES = (
    re.compile(r"^(?P<target>.*(?:env|config|settings)[^/]*?)\.(?:example|sample|dist|template)$"),
    re.compile(r"^(?P<stem>[^.]*(?:env|config|settings)[^.]*)\.(?:example|sample|dist)(?P<ext>\.\w+)$"),
)
MAKE_TARGET = re.compile(r"^([A-Za-z0-9][A-Za-z0-9_.-]*)\s*:(?!=)", re.M)
JUST_RECIPE = re.compile(r"^@?([A-Za-z0-9][A-Za-z0-9_-]*)(?:\s+[^:=\n]*)?:(?!=)", re.M)
TASKFILE_TASK = re.compile(r"^  ([A-Za-z0-9][A-Za-z0-9_:.-]*):\s*$", re.M)


def list_files(root: Path, depth: int) -> list[Path]:
    """Relative paths of files up to `depth` dirs deep, honoring .gitignore inside a repo."""
    git = subprocess.run(
        ["git", "-C", str(root), "ls-files", "--cached", "--others", "--exclude-standard"],
        capture_output=True, text=True, check=False,
    )
    if git.returncode == 0:
        paths = (Path(line) for line in git.stdout.splitlines() if line)
        return [p for p in paths if len(p.parts) <= depth + 1 and not SKIP_DIRS.intersection(p.parts[:-1])]
    found: list[Path] = []
    for dirpath, dirnames, filenames in os.walk(root):
        current = Path(dirpath)
        rel = current.relative_to(root)
        dirnames[:] = [
            d for d in dirnames
            if d not in SKIP_DIRS and (current / d).resolve() != SECRETS_DIR and len(rel.parts) < depth
        ]
        found.extend(rel / f for f in filenames)
    return found


def read_toml(path: Path) -> dict[str, object]:
    try:
        return tomllib.loads(path.read_text(encoding="utf-8"))
    except (OSError, tomllib.TOMLDecodeError):
        return {}


def read_json(path: Path) -> dict[str, object]:
    try:
        data = cast(object, json.loads(path.read_text(encoding="utf-8")))
    except (OSError, ValueError):
        return {}
    return cast("dict[str, object]", data) if isinstance(data, dict) else {}


def table_keys(value: object) -> list[str]:
    """Keys of a parsed TOML/JSON table, or [] when it isn't one."""
    return [str(k) for k in cast("dict[object, object]", value)] if isinstance(value, dict) else []


def prototools(root: Path) -> dict[str, object]:
    """Pins from .prototools in root and its parents (closest wins), like proto does."""
    files: list[str] = []
    pins: dict[str, str] = {}
    for directory in [root, *root.parents]:
        candidate = directory / ".prototools"
        if not candidate.is_file():
            continue
        files.append(str(candidate))
        for tool, version in read_toml(candidate).items():
            if isinstance(version, str):
                _ = pins.setdefault(tool, version)
    return {"files": files, "pins": pins}


def node_package_manager(root: Path, manifest: Path) -> tuple[str | None, str]:
    field = read_json(root / manifest).get("packageManager")
    if isinstance(field, str) and field:
        return field.split("@", 1)[0], "packageManager field"
    return None, ""


def ecosystems(root: Path, files: list[Path]) -> list[dict[str, object]]:
    manifests: dict[tuple[str, str], list[str]] = {}
    for path in files:
        eco = MANIFESTS.get(path.name) or MANIFEST_SUFFIXES.get(path.suffix)
        if eco:
            manifests.setdefault((eco, str(path.parent)), []).append(str(path))
    by_dir: dict[tuple[str, str], dict[str, object]] = {
        key: {"name": key[0], "dir": key[1], "manifests": paths} for key, paths in manifests.items()
    }
    for path in files:
        lock = LOCKFILES.get(path.name)
        if not lock:
            continue
        entry = by_dir.get((lock[0], str(path.parent)))
        if entry is None or "lockfile" in entry:
            continue
        entry["lockfile"] = str(path)
        entry["package_manager"] = lock[1]
        entry["pm_source"] = "lockfile"
    for (eco, directory), entry in by_dir.items():
        if eco == "node":
            pm, source = node_package_manager(root, Path(directory) / "package.json")
            if pm and "lockfile" in entry and entry["package_manager"] != pm:
                # Lockfile and packageManager disagree: may be the user's local PM, report both.
                entry["lockfile_pm"] = entry["package_manager"]
            if pm:
                entry["package_manager"], entry["pm_source"] = pm, source
        if eco == "python" and "package_manager" not in entry:
            tools = table_keys(read_toml(root / directory / "pyproject.toml").get("tool"))
            for name in ("uv", "poetry", "pdm"):
                if name in tools:
                    entry["package_manager"], entry["pm_source"] = name, "pyproject [tool]"
                    break
        _ = entry.setdefault("package_manager", DEFAULT_PM.get(eco))
        _ = entry.setdefault("pm_source", "default")
    return sorted(by_dir.values(), key=lambda e: (str(e["dir"]).count("/"), str(e["dir"]), str(e["name"])))


def task_runners(root: Path, files: list[Path]) -> list[dict[str, object]]:
    patterns = {
        "Makefile": MAKE_TARGET, "makefile": MAKE_TARGET, "GNUmakefile": MAKE_TARGET,
        "justfile": JUST_RECIPE, "Justfile": JUST_RECIPE, ".justfile": JUST_RECIPE,
        "Taskfile.yml": TASKFILE_TASK, "Taskfile.yaml": TASKFILE_TASK,
    }
    runners: list[dict[str, object]] = []
    for path in files:
        if path.name == "package.json":
            scripts = table_keys(read_json(root / path).get("scripts"))
            if scripts:
                runners.append({"file": str(path), "kind": "npm-scripts", "targets": sorted(scripts)})
            continue
        pattern = patterns.get(path.name)
        if pattern is None:
            continue
        try:
            text = (root / path).read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        targets = sorted({str(t) for t in cast("list[str]", pattern.findall(text)) if not str(t).startswith(".")})
        runners.append({"file": str(path), "kind": path.name.lower().lstrip("."), "targets": targets})
    return runners


def env_templates(root: Path, files: list[Path]) -> list[dict[str, object]]:
    templates: list[dict[str, object]] = []
    for path in files:
        match = next((m for m in (t.match(path.name) for t in ENV_TEMPLATES) if m), None)
        if not match:
            continue
        groups = match.groupdict()
        name = groups.get("target") or f"{groups['stem']}{groups['ext']}"
        target = path.parent / name
        templates.append({"template": str(path), "target": str(target), "target_exists": (root / target).exists()})
    return templates


def linter_configs(root: Path, files: list[Path]) -> dict[str, list[str]]:
    configs: dict[str, list[str]] = {}
    for path in files:
        tool = LINTER_CONFIGS.get(path.name)
        if tool:
            configs.setdefault(tool, []).append(str(path))
        if path.name == "pyproject.toml":
            for key in table_keys(read_toml(root / path).get("tool")):
                if key in PYPROJECT_TOOLS:
                    configs.setdefault(PYPROJECT_TOOLS[key], []).append(f"{path} [tool.{key}]")
        if path.name == "package.json" and "eslintConfig" in read_json(root / path):
            configs.setdefault("eslint", []).append(f"{path} (eslintConfig)")
    return configs


def git_hooks(root: Path, files: list[Path]) -> list[str]:
    markers = {"lefthook.yml": "lefthook", "lefthook.yaml": "lefthook", ".pre-commit-config.yaml": "pre-commit"}
    hooks = {markers[p.name] for p in files if p.name in markers}
    if (root / ".husky").is_dir():
        hooks.add("husky")
    return sorted(hooks)


def which(tool: str) -> str | None:
    found = shutil.which(tool)
    if found:
        return found
    mason = MASON_BIN / tool
    return str(mason) if mason.exists() else None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    _ = parser.add_argument("path", nargs="?", default=".", help="project root (default: git toplevel or cwd)")
    _ = parser.add_argument("--depth", type=int, default=2, help="how many dirs deep to look for manifests (default 2)")
    args = parser.parse_args()
    path_arg = cast(str, args.path)
    depth = cast(int, args.depth)

    start = Path(os.path.abspath(Path(path_arg).expanduser()))
    if start == SECRETS_DIR or SECRETS_DIR in start.parents:
        print("stack-detect: refusing to scan the secrets directory", file=sys.stderr)
        return 2
    start = start.resolve()
    if not start.is_dir():
        print(f"stack-detect: not a directory: {start}", file=sys.stderr)
        return 2
    top = subprocess.run(["git", "-C", str(start), "rev-parse", "--show-toplevel"],
                         capture_output=True, text=True, check=False)
    root = Path(top.stdout.strip()) if path_arg == "." and top.returncode == 0 else start

    files = list_files(root, depth)
    ecos = ecosystems(root, files)
    names = {str(e["name"]) for e in ecos}
    wanted = ALWAYS_TOOLS + [t for eco in sorted(names) for t in ECOSYSTEM_TOOLS.get(eco, [])]
    compose = [str(p) for p in files if re.fullmatch(r"(docker-)?compose(\.[\w-]+)?\.ya?ml", p.name)]

    result = {
        "root": str(root),
        "git": top.returncode == 0,
        "ecosystems": ecos,
        "prototools": prototools(root),
        "task_runners": task_runners(root, files),
        "compose_files": compose,
        "dockerfiles": [str(p) for p in files if p.name.startswith("Dockerfile") or p.name.endswith(".Dockerfile")],
        "env_templates": env_templates(root, files),
        "git_hooks": git_hooks(root, files),
        "linter_configs": linter_configs(root, files),
        "tools": {tool: which(tool) for tool in dict.fromkeys(wanted)},
    }
    json.dump(result, sys.stdout, separators=(",", ":"))
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
