#!/usr/bin/env python3
"""Trim CI logs down to their error regions so the model doesn't read 10k lines.

Reads either a `gh run view --log-failed` stream (JOB<TAB>STEP<TAB>line, on stdin)
or plain job logs given as NAME=PATH pairs, and prints one JSON object:

  {"sections": [{"job", "step", "lines_total", "lines_kept", "matches",
                 "excerpt"}], "truncated": bool}

Cleaning: ANSI/OSC escapes, GitLab section markers, carriage-return progress
redraws, BOMs and per-line timestamps are removed. Kept: every line matching an
error pattern plus context, and the last few lines of each section (before the
runner's post-job cleanup), merged,
with repeated lines collapsed and duplicate regions dropped. Each section is
capped at --max-lines (head 60% / tail 40% when over).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

ANSI = re.compile(r"\x1b\[[0-9;?]*[ -/]*[@-~]|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)|\x1b[()][A-Za-z0-9]|\x1b[=>]")
SECTION_MARK = re.compile(r"section_(?:start|end):\d+:[\w.-]+(?:\[[^\]]*\])?\r?")
TIMESTAMP = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z(?: \d{2}[OE]\+?)? ?")
GH_NOISE = re.compile(r"^##\[(?:group|endgroup)\]")
ERROR = re.compile(
    r"(?i)\berror(?:s)?\b|\berr!|\bfail(?:s|ed|ure|ures|ing)?\b|\bpanic(?:ked)?\b|\bexception\b"
    + r"|\bassert(?:ion)?\w*\b|traceback \(most recent call last\)|\bfatal\b|exit (?:code|status) [1-9]"
    + r"|##\[error\]|[✗✘⨯×]|\bFAIL\b|\bnot ok \d+"
)
BENIGN = re.compile(r"(?i)\b0 (?:errors?|failures?|failed)\b|\b(?:errors?|failures?|failed):? 0\b|\berror(?:s)?\s*=\s*0\b")
POST_JOB = re.compile(r"^(?:Post job cleanup\.|Cleaning up project directory and file based variables)")
TAIL_LINES = 6
REPEAT_KEEP = 2


class Args(argparse.Namespace):
    format: str = "plain"
    max_lines: int = 120
    before: int = 3
    after: int = 5
    logs: list[str] = []


@dataclass
class Section:
    job: str
    step: str | None
    lines: list[str] = field(default_factory=list)


def clean(raw: str) -> str:
    line = SECTION_MARK.sub("", raw.lstrip("\ufeff").rstrip("\n"))
    line = TIMESTAMP.sub("", line)
    if "\r" in line.rstrip("\r"):
        line = line.rstrip("\r").rsplit("\r", 1)[-1]
    line = ANSI.sub("", line.rstrip("\r"))
    return TIMESTAMP.sub("", line).rstrip()


def is_error(line: str) -> bool:
    return bool(ERROR.search(line)) and not BENIGN.search(line)


def read_github(stream: list[str]) -> list[Section]:
    sections: dict[tuple[str, str], Section] = {}
    current: Section | None = None
    for raw in stream:
        parts = raw.rstrip("\n").split("\t", 2)
        if len(parts) == 3:
            key = (parts[0], parts[1])
            current = sections.setdefault(key, Section(parts[0], parts[1]))
            text = parts[2]
        else:
            current = current or sections.setdefault(("log", ""), Section("log", None))
            text = raw
        line = clean(text)
        if not GH_NOISE.match(line):
            current.lines.append(line)
    return list(sections.values())


def read_plain(pairs: list[str]) -> list[Section]:
    sections: list[Section] = []
    for pair in pairs:
        name, _, path = pair.rpartition("=")
        if not name:
            name, path = Path(pair).stem, pair
        text = Path(path).read_text(encoding="utf-8", errors="replace")
        sections.append(Section(name, None, [clean(raw) for raw in text.splitlines()]))
    return sections


def regions(lines: list[str], before: int, after: int) -> list[tuple[int, int]]:
    spans = [(max(0, i - before), min(len(lines), i + after + 1)) for i, line in enumerate(lines) if is_error(line)]
    end = next((i for i, line in enumerate(lines) if POST_JOB.match(line)), len(lines))
    if end:
        spans.append((max(0, end - TAIL_LINES), end))
    merged: list[tuple[int, int]] = []
    for start, end in sorted(spans):
        if merged and start <= merged[-1][1]:
            merged[-1] = (merged[-1][0], max(merged[-1][1], end))
            continue
        merged.append((start, end))
    return merged


def collapse(lines: list[str]) -> list[str]:
    out: list[str] = []
    count = 0
    for i, line in enumerate(lines):
        count += 1
        if i + 1 < len(lines) and lines[i + 1] == line:
            continue
        out.append(line if count == 1 or not line.strip() else f"{line}  (x{count})")
        count = 0
    return out


def drop_repeats(body: list[str], counts: dict[str, int]) -> tuple[list[str], int]:
    """Keep the first REPEAT_KEEP copies of a long line across the section; drop the rest."""
    out: list[str] = []
    dropped = 0
    for line in body:
        counts[line] = counts.get(line, 0) + 1
        if len(line.strip()) >= 20 and counts[line] > REPEAT_KEEP:
            dropped += 1
            continue
        out.append(line)
    return out, dropped


def excerpt(section: Section, before: int, after: int, max_lines: int) -> tuple[list[str], int, bool]:
    seen: set[str] = set()
    counts: dict[str, int] = {}
    kept: list[str] = []
    dropped = 0
    for start, end in regions(section.lines, before, after):
        body, gone = drop_repeats(collapse(section.lines[start:end]), counts)
        dropped += gone
        signature = "\n".join(body)
        if not body or signature in seen:
            continue
        seen.add(signature)
        kept.append(f"@@ lines {start + 1}-{end} @@")
        kept.extend(body)
    if dropped:
        kept.append(f"@@ {dropped} repeated lines dropped @@")
    if len(kept) <= max_lines:
        return kept, len(kept), False
    head = int(max_lines * 0.6)
    tail = max_lines - head
    omitted = len(kept) - head - tail
    return [*kept[:head], f"... {omitted} lines omitted ...", *kept[-tail:]], max_lines, True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    _ = parser.add_argument("--format", choices=["github", "plain"], default="plain")
    _ = parser.add_argument("--max-lines", type=int, default=120, help="cap per section (default 120)")
    _ = parser.add_argument("--before", type=int, default=3, help="context lines before a match (default 3)")
    _ = parser.add_argument("--after", type=int, default=5, help="context lines after a match (default 5)")
    _ = parser.add_argument("logs", nargs="*", help="NAME=PATH pairs (plain format)")
    args = parser.parse_args(namespace=Args())
    if args.format == "plain" and not args.logs:
        parser.error("plain format needs NAME=PATH arguments")
    sections = read_github(sys.stdin.readlines()) if args.format == "github" else read_plain(args.logs)
    out: list[dict[str, object]] = []
    truncated = False
    for section in sections:
        lines, kept, cut = excerpt(section, args.before, args.after, args.max_lines)
        truncated = truncated or cut
        out.append(
            {
                "job": section.job,
                "step": section.step,
                "lines_total": len(section.lines),
                "lines_kept": kept,
                "matches": sum(1 for line in section.lines if is_error(line)),
                "excerpt": "\n".join(lines),
            }
        )
    json.dump({"sections": out, "truncated": truncated}, sys.stdout, ensure_ascii=False, separators=(",", ":"))
    _ = sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
