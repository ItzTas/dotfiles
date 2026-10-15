#!/usr/bin/env python3
"""Compare locale files against a base locale: missing/orphan/untranslated keys, placeholders, order."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable, cast

USAGE_EPILOG = """\
Formats: JSON (nested keys become dotted), ARB (@-metadata skipped), Java .properties,
gettext .po/.pot (empty msgstr = untranslated, fuzzy listed apart), YAML through `yq` when
installed (else listed as unsupported). Rails-style YAML wrapped in a top-level locale key is
unwrapped.

--dir pairs files by naming: en.json/pt-BR.json, messages_en.properties (+ messages.properties as
"default"), app_en.arb, devise.en.yml, en/translation.json, pt_BR/LC_MESSAGES/app.po (+ app.pot as
"template"). Base per group: --base, else the .pot template, else en*, else "default", else the
first locale (base_guessed: true).

Output (stdout, one JSON object):
  {"in_sync": bool,
   "groups": [{"pattern", "format", "base": {"locale", "file", "keys"}, "base_guessed",
               "locales": [{"locale", "file", "keys", "missing", "orphan", "untranslated",
                            "same_as_base", "placeholder_mismatches": [{"key", "missing", "extra"}],
                            "order_differs", "fuzzy" (po only), "counts", "in_sync"}]}],
   "unsupported": [{"file", "reason"}], "errors": [{"file", "error"}], "skipped": [files]}
same_as_base (value identical to the base) doesn't break in_sync: it may be legit. printf
placeholders are compared by position, so "%s %d" matches "%2$d %1$s" reordered.

Exit: 0 all in sync, 1 something out of sync or unreadable, 2 usage error or nothing comparable.
"""

FORMATS = {".json": "json", ".arb": "arb", ".properties": "properties", ".po": "po", ".pot": "po", ".yml": "yaml", ".yaml": "yaml"}
PRUNE_DIRS = {".git", "node_modules", "vendor", "dist", "build", "target", ".venv", "__pycache__"}
SECRETS = os.path.abspath(os.path.join(os.path.expanduser("~"), ".config", "zsh", "secrets"))
LANGS = set(
    """aa ab ae af ak am an ar as av ay az ba be bg bh bi bm bn bo br bs ca ce ch co cr cs cu cv cy da de dv dz
    ee el en eo es et eu fa ff fi fj fo fr fy ga gd gl gn gu gv ha he hi ho hr ht hu hy hz ia id ie ig ii ik io is
    it iu ja jv ka kg ki kj kk kl km kn ko kr ks ku kv kw ky la lb lg li ln lo lt lu lv mg mh mi mk ml mn mr ms mt
    my na nb nd ne ng nl nn no nr nv ny oc oj om or os pa pi pl ps pt qu rm rn ro ru rw sa sc sd se sg si sk sl sm
    sn so sq sr ss st su sv sw ta te tg th ti tk tl tn to tr ts tt tw ty ug uk ur uz ve vi vo wa wo xh yi yo za zh
    zu fil ast ckb yue haw gsw nds sco tzm zgh kab ceb chr""".split()
)
LOCALE_RE = re.compile(r"^([A-Za-z]{2,3})((?:[-_](?:[A-Z][a-z]{3}|[A-Za-z]{2}|\d{3}))*)$")


class Unsupported(Exception):
    pass


@dataclass
class Catalog:
    file: str
    fmt: str
    entries: dict[str, list[str]]
    sources: dict[str, list[str]] = field(default_factory=dict)
    fuzzy: list[str] = field(default_factory=list)


@dataclass
class LocaleFile:
    path: Path
    locale: str
    pattern: str


@dataclass
class Plan:
    pattern: str | None
    base: LocaleFile
    others: list[LocaleFile]
    base_guessed: bool


# ---------------------------------------------------------------- loaders


def flatten(node: object, prefix: str, out: dict[str, list[str]]) -> None:
    if isinstance(node, dict):
        for key, value in cast(dict[str, object], node).items():
            flatten(value, f"{prefix}.{key}" if prefix else str(key), out)
        return
    if isinstance(node, list):
        for index, value in enumerate(cast(list[object], node)):
            flatten(value, f"{prefix}.{index}", out)
        return
    if node is None:
        out[prefix] = [""]
        return
    out[prefix] = [str(node).lower() if isinstance(node, bool) else str(node)]


def load_json(path: Path) -> Catalog:
    data = cast(object, json.loads(path.read_text(encoding="utf-8")))
    if not isinstance(data, dict):
        raise ValueError("top level is not an object")
    entries: dict[str, list[str]] = {}
    flatten(cast(dict[str, object], data), "", entries)
    return Catalog(str(path), "json", entries)


def load_arb(path: Path) -> Catalog:
    data = cast(object, json.loads(path.read_text(encoding="utf-8")))
    if not isinstance(data, dict):
        raise ValueError("top level is not an object")
    items = cast(dict[str, object], data).items()
    entries = {key: ["" if value is None else str(value)] for key, value in items if not key.startswith("@")}
    return Catalog(str(path), "arb", entries)


PROPERTIES_ESCAPES = {"t": "\t", "n": "\n", "r": "\r", "f": "\f"}


def unescape_properties(text: str) -> str:
    def repl(match: re.Match[str]) -> str:
        body = match.group(1)
        if body.startswith("u") and len(body) == 5:
            return chr(int(body[1:], 16))
        return PROPERTIES_ESCAPES.get(body, body)

    return re.sub(r"\\(u[0-9a-fA-F]{4}|.)", repl, text)


def properties_lines(text: str) -> list[str]:
    """Logical lines: comments and blanks dropped, backslash continuations joined."""
    logical: list[str] = []
    pending = ""
    for raw in text.splitlines():
        line = raw.lstrip()
        if not pending and (not line or line[0] in "#!"):
            continue
        trailing = len(line) - len(line.rstrip("\\"))
        if trailing % 2:
            pending += line[:-1]
            continue
        logical.append(pending + line)
        pending = ""
    if pending:
        logical.append(pending)
    return logical


def load_properties(path: Path) -> Catalog:
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        text = raw.decode("latin-1")
    entries: dict[str, list[str]] = {}
    for line in properties_lines(text):
        match = re.match(r"((?:\\.|[^\s:=\\])*)\s*[:=]?\s*(.*)$", line, re.DOTALL)
        if match:
            entries[unescape_properties(match.group(1))] = [unescape_properties(match.group(2))]
    return Catalog(str(path), "properties", entries)


PO_ESCAPES = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\", "a": "\a", "b": "\b", "f": "\f", "v": "\v"}


def po_string(text: str) -> str:
    inner = text.strip()[1:-1]
    return re.sub(r"\\(.)", lambda m: PO_ESCAPES.get(m.group(1), m.group(1)), inner)


def po_entries(text: str) -> list[dict[str, str | bool]]:
    entries: list[dict[str, str | bool]] = []
    current: dict[str, str | bool] = {}
    last = ""
    for line in [*text.splitlines(), ""]:
        stripped = line.strip()
        starts_entry = not stripped or stripped.startswith("#") or re.match(r"(msgctxt|msgid)\s", stripped)
        if starts_entry and any(name.startswith("msgstr") for name in current):
            entries.append(current)
            current, last = {}, ""
        if not stripped or stripped.startswith("#~"):
            continue
        if stripped.startswith("#,"):
            current["fuzzy"] = "fuzzy" in stripped
            continue
        if stripped.startswith("#"):
            continue
        if stripped.startswith('"') and last:
            current[last] = str(current[last]) + po_string(stripped)
            continue
        match = re.match(r"(msgctxt|msgid_plural|msgid|msgstr(?:\[\d+\])?)\s+(\".*\")$", stripped)
        if match:
            last = match.group(1)
            current[last] = po_string(match.group(2))
    return entries


def load_po(path: Path) -> Catalog:
    catalog = Catalog(str(path), "po", {})
    for entry in po_entries(path.read_text(encoding="utf-8", errors="replace")):
        msgid = str(entry.get("msgid", ""))
        if not msgid:
            continue
        key = f"{entry['msgctxt']}|{msgid}" if "msgctxt" in entry else msgid
        forms = [str(value) for name, value in sorted(entry.items()) if name.startswith("msgstr")]
        catalog.entries[key] = forms or [""]
        catalog.sources[key] = [msgid, *([str(entry["msgid_plural"])] if "msgid_plural" in entry else [])]
        if entry.get("fuzzy"):
            catalog.fuzzy.append(key)
    return catalog


def yq_command(path: Path) -> list[str]:
    yq = shutil.which("yq")
    if not yq:
        raise Unsupported("YAML needs yq, which isn't installed")
    version = subprocess.run([yq, "--version"], capture_output=True, text=True, check=False)
    if "mikefarah" in version.stdout + version.stderr:
        return [yq, "-o=json", ".", str(path)]
    return [yq, ".", str(path)]


def load_yaml(path: Path) -> Catalog:
    result = subprocess.run(yq_command(path), capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise ValueError(result.stderr.strip() or f"yq exited {result.returncode}")
    data = cast(object, json.loads(result.stdout or "null"))
    if not isinstance(data, dict):
        raise ValueError("top level is not a mapping")
    mapping = cast(dict[str, object], data)
    if len(mapping) == 1:
        ((only_key, only_value),) = mapping.items()
        if as_locale(only_key) and isinstance(only_value, dict):
            mapping = cast(dict[str, object], only_value)
    entries: dict[str, list[str]] = {}
    flatten(mapping, "", entries)
    return Catalog(str(path), "yaml", entries)


LOADERS: dict[str, Callable[[Path], Catalog]] = {
    "json": load_json,
    "arb": load_arb,
    "properties": load_properties,
    "po": load_po,
    "yaml": load_yaml,
}


# ---------------------------------------------------------------- placeholders


DOUBLE_BRACES = re.compile(r"\{\{\s*([^{}]+?)\s*\}\}")
RUBY = re.compile(r"%\{(\w+)\}|%<(\w+)>[a-zA-Z]")
PRINTF = re.compile(r"%(?:(\d+)\$)?(\([^)]+\))?[-+0#]*(?:\d+|\*)?(?:\.(?:\d+|\*))?(?:hh|h|ll|l|L|q|j|z|t)?([sdifuxXoeEgGc@])")
ICU_NAME = re.compile(r"\s*([^\s,{}]*)\s*")
ICU_TYPE = re.compile(r"\s*(\w*)\s*")


def icu_arguments(text: str) -> set[str]:
    """Argument names in an ICU/MessageFormat string, nested plural/select branches included."""
    names: set[str] = set()

    def message(i: int, nested: bool) -> int:
        while i < len(text):
            char = text[i]
            if char == "'" and i + 1 < len(text) and text[i + 1] in "{}":
                close = text.find("'", i + 1)
                i = len(text) if close < 0 else close + 1
            elif char == "{":
                i = argument(i + 1)
            elif char == "}" and nested:
                return i + 1
            else:
                i += 1
        return i

    def skip_to_close(i: int) -> int:
        depth = 1
        while i < len(text) and depth:
            depth += {"{": 1, "}": -1}.get(text[i], 0)
            i += 1
        return i

    def argument(i: int) -> int:
        match = ICU_NAME.match(text, i)
        name, i = (match.group(1), match.end()) if match else ("", i)
        if re.fullmatch(r"[\w.-]+", name):
            names.add(name)
        if i >= len(text) or text[i] != ",":
            return skip_to_close(i)
        kind = ICU_TYPE.match(text, i + 1)
        i = kind.end() if kind else i + 1
        if not kind or kind.group(1) not in ("plural", "select", "selectordinal"):
            return skip_to_close(i)
        while i < len(text):
            if text[i] == "}":
                return i + 1
            i = message(i + 1, nested=True) if text[i] == "{" else i + 1
        return i

    _ = message(0, nested=False)
    return names


def placeholders(texts: list[str]) -> tuple[set[str], Counter[str]]:
    """Named placeholders as a set; printf conversions as position-tagged tokens (%1$s)."""
    named: set[str] = set()
    positional: Counter[str] = Counter()
    for text in texts:
        named.update("{{" + str(m.group(1)).split(",")[0].strip() + "}}" for m in DOUBLE_BRACES.finditer(text))
        text = DOUBLE_BRACES.sub(" ", text)
        named.update("%{" + str(m.group(1) or m.group(2)) + "}" for m in RUBY.finditer(text))
        text = RUBY.sub(" ", text.replace("%%", " "))
        sequence = 0
        for m in PRINTF.finditer(text):
            position, name, conversion = (str(group or "") for group in m.groups())
            if name:
                named.add(f"%{name}{conversion}")
                continue
            sequence += 1
            positional[f"%{position or sequence}${conversion}"] += 1
        text = PRINTF.sub(" ", text)
        named.update(f"{{{name}}}" for name in icu_arguments(text))
    return named, positional


def placeholder_mismatch(base: list[str], target: list[str]) -> tuple[list[str], list[str]]:
    base_named, base_positional = placeholders(base)
    target_named, target_positional = placeholders(target)
    distinct_base = set(base_positional)
    distinct_target = set(target_positional)
    missing = sorted((base_named - target_named) | (distinct_base - distinct_target))
    extra = sorted((target_named - base_named) | (distinct_target - distinct_base))
    return missing, extra


# ---------------------------------------------------------------- comparison


def compare(base: Catalog, other: Catalog) -> dict[str, object]:
    is_po = other.fmt == "po"
    base_keys = list(base.entries)
    other_keys = list(other.entries)
    base_set, other_set = set(base_keys), set(other_keys)
    untranslated: list[str] = []
    same_as_base: list[str] = []
    mismatches: list[dict[str, object]] = []
    for key in other_keys:
        if key not in base_set:
            continue
        forms = other.entries[key]
        source = other.sources.get(key) or base.sources.get(key) or base.entries[key]
        if any(not form.strip() for form in forms):
            untranslated.append(key)
            continue
        if forms[0] == source[0]:
            same_as_base.append(key)
        missing, extra = placeholder_mismatch(source, forms)
        if missing or extra:
            mismatches.append({"key": key, "missing": missing, "extra": extra})
    shared_base = [key for key in base_keys if key in other_set]
    shared_other = [key for key in other_keys if key in base_set]
    report: dict[str, object] = {
        "missing": [key for key in base_keys if key not in other_set],
        "orphan": [key for key in other_keys if key not in base_set],
        "untranslated": untranslated,
        "same_as_base": same_as_base,
        "placeholder_mismatches": mismatches,
        "order_differs": None if is_po else shared_base != shared_other,
    }
    if is_po:
        report["fuzzy"] = [key for key in other.fuzzy if key in base_set]
    breaking = ("missing", "orphan", "untranslated", "placeholder_mismatches", "fuzzy")
    report["counts"] = {name: len(cast(list[object], value)) for name, value in report.items() if isinstance(value, list)}
    report["in_sync"] = not any(report.get(name) for name in breaking) and not report["order_differs"]
    return report


# ---------------------------------------------------------------- discovery


def as_locale(text: str) -> str | None:
    match = LOCALE_RE.match(text)
    if not match or match.group(1).lower() not in LANGS:
        return None
    return text


def classify(path: Path, root: Path) -> LocaleFile | None:
    relative = path.relative_to(root)
    suffix = path.suffix
    stem = path.stem
    if suffix == ".pot":
        return LocaleFile(path, "template", str(relative.with_name("{pot}")))
    if as_locale(stem):
        return LocaleFile(path, stem, str(relative.with_name("{locale}" + suffix)))
    for match in re.finditer(r"[._-]", stem):
        rest = stem[match.end() :]
        if as_locale(rest):
            name = f"{stem[: match.end()]}{{locale}}{suffix}"
            return LocaleFile(path, rest, str(relative.with_name(name)))
    parts = relative.parts
    for index in range(len(parts) - 2, -1, -1):
        if as_locale(parts[index]):
            pattern = Path(*parts[:index], "{locale}", *parts[index + 1 :])
            return LocaleFile(path, parts[index], str(pattern))
    if suffix == ".properties":
        return LocaleFile(path, "default", str(relative.with_name(f"{stem}_{{locale}}{suffix}")))
    return None


def under_secrets(path: Path) -> bool:
    """Checked lexically first, so nothing under the secrets dir is ever stat'ed."""
    lexical = os.path.abspath(path)
    if lexical == SECRETS or lexical.startswith(SECRETS + os.sep):
        return True
    resolved = os.path.realpath(lexical)
    return resolved == SECRETS or resolved.startswith(SECRETS + os.sep)


def candidate_files(root: Path) -> list[Path]:
    listed = subprocess.run(
        ["git", "-C", str(root), "ls-files", "-co", "--exclude-standard", "-z"],
        capture_output=True,
        text=True,
        check=False,
    )
    if listed.returncode == 0:
        paths = [root / name for name in listed.stdout.split("\0") if name]
        return sorted(p for p in paths if p.suffix in FORMATS and not under_secrets(p) and p.is_file())
    found: list[Path] = []
    for directory, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in PRUNE_DIRS and not under_secrets(Path(directory, d))]
        found.extend(Path(directory, name) for name in files if Path(name).suffix in FORMATS)
    return sorted(found)


def pick_base(members: dict[str, LocaleFile], wanted: str | None) -> tuple[str, bool]:
    if wanted and wanted in members:
        return wanted, False
    if "template" in members:
        return "template", False
    english = sorted(locale for locale in members if locale.lower().split("-")[0].split("_")[0] == "en")
    if english:
        return ("en" if "en" in english else english[0]), False
    if "default" in members:
        return "default", False
    return sorted(members)[0], True


def group_dir(root: Path, wanted_base: str | None) -> tuple[list[Plan], list[str]]:
    groups: dict[str, dict[str, LocaleFile]] = {}
    templates: list[LocaleFile] = []
    skipped: list[str] = []
    for path in candidate_files(root):
        found = classify(path, root)
        if found is None:
            skipped.append(str(path))
        elif found.locale == "template":
            templates.append(found)
        else:
            groups.setdefault(found.pattern, {})[found.locale] = found
    singles = [pattern for pattern, members in groups.items() if list(members) == ["default"]]
    for pattern in singles:
        skipped.append(str(groups.pop(pattern)["default"].path))
    for template in templates:
        owner = next((p for p in groups if p.endswith(".po") and template_matches(template, p, groups[p])), None)
        if owner is None:
            skipped.append(str(template.path))
            continue
        groups[owner]["template"] = template
    plans: list[Plan] = []
    for pattern, members in sorted(groups.items()):
        base, guessed = pick_base(members, wanted_base)
        others = [members[locale] for locale in sorted(members) if locale != base]
        plans.append(Plan(pattern, members[base], others, guessed))
    return plans, skipped


def template_matches(template: LocaleFile, pattern: str, members: dict[str, LocaleFile]) -> bool:
    if "template" in members:
        return False
    domain = Path(pattern).stem
    sample = next(iter(members.values())).path
    return template.path.stem == domain or template.path.parent == sample.parent


def explicit_plan(paths: list[Path]) -> Plan:
    def labelled(path: Path) -> LocaleFile:
        found = classify(path.resolve(), Path("/"))
        return LocaleFile(path, found.locale if found else str(path), "")

    return Plan(None, labelled(paths[0]), [labelled(p) for p in paths[1:]], False)


# ---------------------------------------------------------------- main


def load(path: Path) -> Catalog | Unsupported | Exception:
    fmt = FORMATS.get(path.suffix)
    if fmt is None:
        return Unsupported(f"unsupported file type {path.suffix or '(none)'}")
    try:
        return LOADERS[fmt](path)
    except (Unsupported, ValueError, OSError, UnicodeDecodeError) as error:
        return error


def run(plans: list[Plan], skipped: list[str]) -> tuple[dict[str, object], int]:
    files = sorted({str(f.path) for plan in plans for f in (plan.base, *plan.others)})
    with ThreadPoolExecutor(max_workers=8) as pool:
        loaded = dict(zip(files, pool.map(load, map(Path, files))))
    unsupported = [{"file": name, "reason": str(value)} for name, value in loaded.items() if isinstance(value, Unsupported)]
    errors = [{"file": name, "error": str(value)} for name, value in loaded.items() if isinstance(value, Exception) and not isinstance(value, Unsupported)]
    groups: list[dict[str, object]] = []
    for plan in plans:
        base_file = plan.base
        base = loaded[str(base_file.path)]
        if not isinstance(base, Catalog):
            continue
        locales: list[dict[str, object]] = []
        for other_file in plan.others:
            other = loaded[str(other_file.path)]
            if isinstance(other, Catalog):
                locales.append({"locale": other_file.locale, "file": str(other_file.path), "keys": len(other.entries), **compare(base, other)})
        groups.append(
            {
                "pattern": plan.pattern,
                "format": base.fmt,
                "base": {"locale": base_file.locale, "file": str(base_file.path), "keys": len(base.entries)},
                "base_guessed": plan.base_guessed,
                "locales": locales,
            }
        )
    in_sync = bool(groups) and not errors and all(locale["in_sync"] for group in groups for locale in cast(list[dict[str, object]], group["locales"]))
    output: dict[str, object] = {"in_sync": in_sync, "groups": groups, "unsupported": unsupported, "errors": errors, "skipped": skipped}
    if not groups and not errors:
        return output, 2
    return output, 0 if in_sync else 1


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Compare locale files against a base locale.",
        usage="i18n-diff.py <base-file> [other-files...] | --dir <locales-dir> [--base <locale>]",
        epilog=USAGE_EPILOG,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    _ = parser.add_argument("files", nargs="*", type=Path, help="base locale file first, then the others")
    _ = parser.add_argument("--dir", type=Path, help="auto-pair the locale files under this directory")
    _ = parser.add_argument("--base", help="base locale for --dir (default: template, en*, default)")
    args = parser.parse_args()
    if bool(cast(list[Path], args.files)) == bool(cast(Path | None, args.dir)):
        parser.error("pass either locale files or --dir")
    return args


def main() -> None:
    args = parse_args()
    directory = cast(Path | None, args.dir)
    files = cast(list[Path], args.files)
    targets = [directory] if directory else files
    if any(under_secrets(path) for path in targets):
        print("i18n-diff: refusing to read under ~/.config/zsh/secrets", file=sys.stderr)
        sys.exit(2)
    missing = [str(path) for path in targets if not path.exists()]
    if missing:
        print(f"i18n-diff: not found: {', '.join(missing)}", file=sys.stderr)
        sys.exit(2)
    if directory:
        plans, skipped = group_dir(directory, cast(str | None, args.base))
    else:
        plans, skipped = [explicit_plan(files)], []
    output, code = run(plans, skipped)
    print(json.dumps(output, ensure_ascii=False, separators=(",", ":")))
    sys.exit(code)


if __name__ == "__main__":
    main()
