#!/usr/bin/env python3
"""Collect my commits (and optionally my open PRs/MRs) for /worklog as JSON.

Read-only: runs `git log` / `git config` per repo, plus `gh`/`glab` list calls with --prs.
"""

import json
import os
import re
import subprocess
import sys
import threading
from collections.abc import Callable
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from datetime import date, timedelta
from pathlib import Path
from typing import cast

USAGE = """\
Usage: collect.py [period] [path] [--prs] [--stat]

period  today | yesterday (default) | week | N (days) | any `git log --since` expression
path    a repo, or a directory holding several repos (found up to 3 levels deep);
        default: the current repo, or the repos under the current directory.
        Period and path may come in either order.
--prs   add my open PRs (gh) / MRs (glab) per repo; missing CLI or auth -> a note
--stat  add files/insertions/deletions per commit

Prints one JSON object:
  {"window": {"period", "since"}, "identity": {"email", "name"}, "scope", "scanned",
   "repos": [{"path", "identity", "identity_differs",
              "commits": [{"hash", "date", "type", "scope", "breaking", "subject",
                           "files"?, "insertions"?, "deletions"?}],
              "prs"?: {"open": [{"forge", "number", "title", "url", "branch", "draft"}],
                       "notes": [...]}}],
   "errors"?: [{"path", "error"}]}
Commits are --no-merges on HEAD, authored by the identity (matched by email; a repo
whose own git config has another identity uses that one and is flagged
identity_differs). "type"/"scope"/"breaking" come from the Conventional Commit
subject ("type" null when it isn't one). Repos with nothing to report are omitted.

Exit: 0 something found, 1 no commits (and no PRs) in the window, 2 bad args / no identity.
"""

HOME = os.path.expanduser("~")
_ZSH_DIR = os.path.join(HOME, ".config", "zsh")
# Lexical and resolved forms of the secrets dir (resolving only touches the path itself).
SECRETS = {os.path.join(_ZSH_DIR, "secrets"), os.path.join(os.path.realpath(_ZSH_DIR), "secrets"),
           os.path.realpath(os.path.join(_ZSH_DIR, "secrets"))}
# skills/worklog/scripts/collect.py -> ~/.claude/scripts/forge-detect.sh
FORGE_DETECT = str(Path(__file__).resolve().parents[3] / "scripts" / "forge-detect.sh")
MAX_DEPTH = 3
SKIP_DIRS = {
    "node_modules", ".venv", "venv", "vendor", "target", "dist", "build", ".cache",
    "__pycache__", ".tox", ".next", ".git", ".yarn", ".pnpm-store",
}
CC_RE = re.compile(r"^(?P<type>[A-Za-z]+)(?:\((?P<scope>[^()]*)\))?(?P<bang>!)?:\s*(?P<desc>.+)$")
BREAKING_RE = re.compile(r"^BREAKING[ -]CHANGE:", re.MULTILINE)
STAT_RE = re.compile(r"(\d+) (file|insertion|deletion)")

type Json = dict[str, object]


class UsageError(Exception):
    pass


@dataclass(frozen=True)
class Identity:
    email: str
    name: str

    def as_json(self) -> Json:
        return {"email": self.email, "name": self.name}


@dataclass(frozen=True)
class Options:
    period: str
    since: str
    root: str
    prs: bool
    stat: bool


def run(args: list[str], cwd: str | None = None) -> tuple[int, str, str]:
    try:
        proc = subprocess.run(args, cwd=cwd, capture_output=True, text=True, stdin=subprocess.DEVNULL,
                              env={**os.environ, "GH_PROMPT_DISABLED": "1", "NO_PROMPT": "1"})
    except OSError as err:
        return 127, "", f"{args[0]}: {err.strerror}"
    return proc.returncode, proc.stdout, proc.stderr


def is_secret(path: str) -> bool:
    path = os.path.abspath(path)
    return any(path == s or path.startswith(s + os.sep) for s in SECRETS)


def since_for(period: str) -> str:
    today = date.today()
    fixed = {
        "today": f"{today.isoformat()} 00:00",
        "yesterday": f"{(today - timedelta(days=1)).isoformat()} 00:00",
        "week": "7 days ago",
    }
    if period in fixed:
        return fixed[period]
    if period.isdigit():
        return f"{int(period)} days ago"
    return period


def looks_like_path(token: str) -> bool:
    return token.startswith(("/", "~", "./", "../")) or token in {".", ".."}


def parse_args(argv: list[str]) -> Options:
    prs = stat = False
    path: str | None = None
    period_parts: list[str] = []
    for token in argv:
        if token in {"-h", "--help"}:
            print(USAGE, end="")
            sys.exit(0)
        if token in {"--prs", "--stat"}:
            prs = prs or token == "--prs"
            stat = stat or token == "--stat"
            continue
        if token.startswith("--"):
            raise UsageError(f"unknown option: {token}")
        expanded = os.path.abspath(os.path.expanduser(token))
        if is_secret(expanded):
            raise UsageError("refusing to scan under ~/.config/zsh/secrets")
        if os.path.isdir(expanded):
            if path is not None:
                raise UsageError("only one path may be given")
            path = expanded
            continue
        if looks_like_path(token):
            raise UsageError(f"path not found: {token}")
        period_parts.append(token)
    period = " ".join(period_parts) or "yesterday"
    root = os.path.realpath(path or os.getcwd())
    if is_secret(root):
        raise UsageError("refusing to scan under ~/.config/zsh/secrets")
    return Options(period=period, since=since_for(period), root=root, prs=prs, stat=stat)


def git_config(key: str, repo: str | None = None, scope: str | None = None) -> str:
    args = ["git"] + (["-C", repo] if repo else []) + ["config"] + ([scope] if scope else []) + ["--get", key]
    _, out, _ = run(args)
    return out.strip()


def base_identity() -> Identity:
    email = git_config("user.email", scope="--global") or git_config("user.email")
    name = git_config("user.name", scope="--global") or git_config("user.name")
    if not email and not name:
        raise UsageError("no git identity: set git config --global user.email")
    return Identity(email=email, name=name)


def find_repos(root: str) -> list[str]:
    code, top, _ = run(["git", "-C", root, "rev-parse", "--show-toplevel"])
    if code == 0:
        return [top.strip()]
    repos: list[str] = []
    base_depth = root.rstrip(os.sep).count(os.sep)
    for dirpath, dirnames, filenames in os.walk(root, onerror=lambda _err: None):
        if ".git" in dirnames or ".git" in filenames:
            repos.append(dirpath)
            dirnames[:] = []
            continue
        depth = dirpath.rstrip(os.sep).count(os.sep) - base_depth
        dirnames[:] = [] if depth >= MAX_DEPTH else [
            d for d in dirnames if d not in SKIP_DIRS and not is_secret(os.path.join(dirpath, d))
        ]
    return sorted(repos)


def parse_stat(text: str) -> Json:
    pairs = cast(list[tuple[str, str]], STAT_RE.findall(text))
    found = {kind: int(num) for num, kind in pairs}
    return {"files": found.get("file", 0), "insertions": found.get("insertion", 0),
            "deletions": found.get("deletion", 0)}


def parse_commit(record: str, stat: bool) -> Json:
    short, when, subject, body, stat_text = (record.split("\x1f") + [""] * 5)[:5]
    match = CC_RE.match(subject)
    commit: Json = {"hash": short, "date": when, "type": None, "scope": None,
                    "breaking": bool(BREAKING_RE.search(body)), "subject": subject}
    if match:
        commit.update(type=match["type"].lower(), scope=match["scope"] or None, subject=match["desc"],
                      breaking=bool(match["bang"]) or bool(commit["breaking"]))
    if stat:
        commit.update(parse_stat(stat_text))
    return commit


def repo_commits(repo: str, who: Identity, opts: Options) -> list[Json]:
    author = who.email or who.name
    args = ["git", "-C", repo, "log", "-F", f"--author={author}", f"--since={opts.since}", "--no-merges",
            "--format=%x1e%h%x1f%aI%x1f%s%x1f%b%x1f"]
    if opts.stat:
        args.append("--shortstat")
    code, out, err = run(args)
    if code != 0:
        if "does not have any commits" in err:
            return []
        raise RuntimeError(err.strip().splitlines()[-1] if err.strip() else f"git log exited {code}")
    return [parse_commit(rec.strip("\n"), opts.stat) for rec in out.split("\x1e") if rec.strip()]


class GitlabUsers:
    """`glab api user` per host, resolved once and shared across threads."""

    def __init__(self) -> None:
        self._lock: threading.Lock = threading.Lock()
        self._cache: dict[str, str | None] = {}

    def get(self, host: str, cwd: str) -> str | None:
        with self._lock:
            if host not in self._cache:
                code, out, _ = run(["glab", "api", "--hostname", host, "user"], cwd=cwd)
                user = cast(Json, json.loads(out)).get("username") if code == 0 and out.strip() else None
                self._cache[host] = user if isinstance(user, str) else None
            return self._cache[host]


def json_list(text: str) -> list[Json]:
    data = cast(object, json.loads(text))
    if not isinstance(data, list):
        raise ValueError("unexpected output")
    return [cast(Json, item) for item in cast(list[object], data) if isinstance(item, dict)]


def first_line(err: str) -> str:
    lines = err.strip().splitlines()
    return lines[0] if lines else "no output"


def github_prs(remote: Json, repo: str) -> list[Json]:
    slug = f"{remote['host']}/{remote['slug']}"
    code, out, err = run(["gh", "pr", "list", "-R", slug, "--author", "@me", "--state", "open",
                          "--json", "number,title,url,headRefName,isDraft"], cwd=repo)
    if code != 0:
        raise RuntimeError(f"gh failed for {slug}: {first_line(err)}")
    return [{"forge": "github", "number": pr.get("number"), "title": pr.get("title"), "url": pr.get("url"),
             "branch": pr.get("headRefName"), "draft": pr.get("isDraft")} for pr in json_list(out)]


def gitlab_prs(remote: Json, repo: str, users: GitlabUsers) -> list[Json]:
    host, url = str(remote["host"]), str(remote["url"])
    user = users.get(host, repo)
    if not user:
        raise RuntimeError(f"glab: could not resolve my username on {host} (not logged in?)")
    code, out, err = run(["glab", "mr", "list", "-R", url, f"--author={user}", "-F", "json"], cwd=repo)
    if code != 0:
        raise RuntimeError(f"glab failed for {url}: {first_line(err)}")
    return [{"forge": "gitlab", "number": mr.get("iid"), "title": mr.get("title"), "url": mr.get("web_url"),
             "branch": mr.get("source_branch"), "draft": mr.get("draft")} for mr in json_list(out)]


def repo_prs(repo: str, users: GitlabUsers) -> Json:
    code, out, err = run([FORGE_DETECT, "-C", repo])
    if code != 0:
        return {"open": [], "notes": [f"forge-detect failed: {first_line(err)}"]}
    forge = cast(Json, json.loads(out))
    cli = cast(dict[str, bool], forge.get("cli", {}))
    lookups: dict[str, tuple[str, Callable[[Json], list[Json]]]] = {
        "github": ("gh", lambda r: github_prs(r, repo)),
        "gitlab": ("glab", lambda r: gitlab_prs(r, repo, users)),
    }
    found: list[Json] = []
    notes: list[str] = []
    for kind, (tool, lookup) in lookups.items():
        remotes = cast(list[Json], forge.get(kind, []))
        unique = list({str(r.get("url")): r for r in remotes}.values())
        if unique and not cli.get(tool):
            notes.append(f"{tool} not installed")
            continue
        for remote in unique:
            try:
                found.extend(lookup(remote))
            except (RuntimeError, ValueError, json.JSONDecodeError) as err_:
                notes.append(str(err_))
    return {"open": found, "notes": notes}


def collect_repo(repo: str, base: Identity, opts: Options, users: GitlabUsers) -> Json:
    own = Identity(email=git_config("user.email", repo) or base.email,
                   name=git_config("user.name", repo) or base.name)
    entry: Json = {"path": repo, "identity": own.as_json(), "identity_differs": own != base}
    try:
        entry["commits"] = repo_commits(repo, own, opts)
    except RuntimeError as err:
        entry["commits"] = []
        entry["error"] = str(err)
    if opts.prs:
        entry["prs"] = repo_prs(repo, users)
    return entry


def has_content(entry: Json) -> bool:
    prs = cast(Json, entry.get("prs") or {})
    return bool(entry["commits"]) or bool(prs.get("open"))


def main(argv: list[str]) -> int:
    try:
        opts = parse_args(argv)
        base = base_identity()
    except UsageError as err:
        print(f"collect: {err}", file=sys.stderr)
        return 2
    repos = find_repos(opts.root)
    users = GitlabUsers()

    def one(repo: str) -> Json:
        return collect_repo(repo, base, opts, users)

    with ThreadPoolExecutor(max_workers=max(1, min(8, len(repos)))) as pool:
        entries = list(pool.map(one, repos))
    errors = [{"path": e["path"], "error": e.pop("error")} for e in entries if "error" in e]
    kept = [e for e in entries if has_content(e)]
    result: Json = {"window": {"period": opts.period, "since": opts.since}, "identity": base.as_json(),
                    "scope": opts.root, "scanned": len(repos), "repos": kept}
    if errors:
        result["errors"] = errors
    print(json.dumps(result, ensure_ascii=False, separators=(",", ":")))
    return 0 if kept else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
