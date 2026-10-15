#!/usr/bin/env python3
"""Parse /defer arguments into a scheduling plan, printed as one JSON object on stdout."""

from __future__ import annotations

import json
import math
import os
import re
import sys
import unicodedata
from datetime import datetime
from typing import NoReturn

USAGE = """\
Usage: parse.py '<raw /defer arguments>'

Splits the arguments into flags, a duration and the prompt, and picks the mechanism:
  sleep  N <= 600 s, session-only           -> run `sleep N` in the background
  cron   N > 600 s, or --durable (any N)    -> CronCreate one-shot with `cron`
  final  final/afterall keyword             -> pin the prompt to the end of the queue

Output: {"mode","durable","seconds","rounded_up","cron","fire_at","fire_at_hhmm","prompt","warning"}
  cron is "M H dom month *"; fire_at is local ISO 8601 (the cron minute in cron mode);
  rounded_up is true when a durable wait under 60 s was moved to the next minute.
Exit 2: {"error": "missing_duration"|"missing_prompt"|"duration_too_long", "message": ...}

Env: DEFER_NOW=<ISO 8601> overrides the current time (for testing).
"""

SLEEP_MAX = 600
MAX_SECONDS = 365 * 86400

DURABLE_FLAGS = {"--durable", "-durable", "-d"}
FINAL_FLAGS = {"final", "--final", "-final", "-f", "afterall", "--afterall", "-afterall", "-a"}
DURABLE_ANYWHERE = re.compile(r"\s*(?<!\S)--?durable(?!\S)", re.IGNORECASE)
NUMBER_UNIT = re.compile(r"^(\d+(?:[.,]\d+)?)(\D*)$")


def unit_seconds(word: str) -> int | None:
    units = {
        1: "s sec secs second seconds seg segs segundo segundos seconde secondes sekunde sekunden secondo secondi",
        60: "m min mins minute minutes minuto minutos minuti minuten",
        3600: "h hr hrs hour hours hora horas heure heures stunde stunden",
        86400: "d day days dia dias jour jours tage giorno giorni",
    }
    plain = unicodedata.normalize("NFKD", word.lower())
    plain = "".join(c for c in plain if not unicodedata.combining(c)).rstrip(".")
    for seconds, words in units.items():
        if plain in words.split():
            return seconds
    return None


def fail(error: str, message: str) -> NoReturn:
    print(json.dumps({"error": error, "message": message}, ensure_ascii=False, separators=(",", ":")))
    sys.exit(2)


def current_time() -> datetime:
    injected = os.environ.get("DEFER_NOW")
    if not injected:
        return datetime.now().astimezone()
    return datetime.fromisoformat(injected).astimezone()


def leading_flags(raw: str, pos: int, allow_final: bool) -> tuple[int, bool, bool]:
    """Consume durable (and optionally final) flag tokens starting at pos."""
    durable = final = False
    for match in re.finditer(r"\S+", raw[pos:]):
        token = match.group().lower()
        if token in DURABLE_FLAGS:
            durable = True
        elif allow_final and not final and token in FINAL_FLAGS:
            final = True
        else:
            return pos + match.start(), durable, final
    return len(raw), durable, final


def parse_duration(raw: str, pos: int) -> tuple[int, int] | None:
    """Return (seconds, end position) for the duration starting at pos, or None."""
    tokens = [(m.group(), pos + m.end()) for m in re.finditer(r"\S+", raw[pos:])][:2]
    if not tokens:
        return None
    first, first_end = tokens[0]
    unit_only = unit_seconds(first)
    if unit_only:
        return unit_only, first_end
    match = NUMBER_UNIT.match(first)
    if not match:
        return None
    value = float(match.group(1).replace(",", "."))
    if match.group(2):
        unit = unit_seconds(match.group(2))
        return (math.ceil(value * unit), first_end) if unit else None
    if len(tokens) > 1 and (unit := unit_seconds(tokens[1][0])):
        return math.ceil(value * unit), tokens[1][1]
    return math.ceil(value), first_end


def cron_minute(now: datetime, seconds: int) -> tuple[datetime, bool]:
    """The cron firing minute for now + seconds; moved to the next minute if already past."""
    target = datetime.fromtimestamp(now.timestamp() + seconds).astimezone().replace(second=0, microsecond=0)
    if target.timestamp() > now.timestamp():
        return target, False
    next_minute = (math.floor(now.timestamp() / 60) + 1) * 60
    return datetime.fromtimestamp(next_minute).astimezone(), True


def plan(raw: str) -> dict[str, object]:
    pos, durable, final = leading_flags(raw, 0, allow_final=True)
    result: dict[str, object] = {
        "mode": "final",
        "durable": False,
        "seconds": None,
        "rounded_up": False,
        "cron": None,
        "fire_at": None,
        "fire_at_hhmm": None,
        "prompt": "",
        "warning": None,
    }
    if final:
        prompt = DURABLE_ANYWHERE.sub("", raw[pos:]).strip()
        if not prompt:
            fail("missing_prompt", "nothing to run after the final/afterall keyword")
        result["prompt"] = prompt
        if durable or DURABLE_ANYWHERE.search(raw[pos:]):
            result["warning"] = "--durable ignored: final mode is session-only"
        return result

    duration = parse_duration(raw, pos)
    if duration is None:
        fail("missing_duration", "no duration (e.g. 10, 10min, 2h, hora) or final/afterall keyword found")
    seconds, end = duration
    if seconds > MAX_SECONDS:
        fail("duration_too_long", "cron can't express a wait longer than a year")
    pos, more_durable, _ = leading_flags(raw, end, allow_final=False)
    prompt = DURABLE_ANYWHERE.sub("", raw[pos:]).strip()
    durable = durable or more_durable or DURABLE_ANYWHERE.search(raw[pos:]) is not None
    if not prompt:
        fail("missing_prompt", "no prompt after the duration")

    now = current_time()
    result.update(durable=durable, seconds=seconds, prompt=prompt)
    if not durable and seconds <= SLEEP_MAX:
        fire = datetime.fromtimestamp(now.timestamp() + seconds).astimezone()
        result.update(mode="sleep", fire_at=fire.isoformat(timespec="seconds"), fire_at_hhmm=fire.strftime("%H:%M"))
        return result
    minute, rounded_up = cron_minute(now, seconds)
    result.update(
        mode="cron",
        rounded_up=rounded_up,
        cron=f"{minute.minute} {minute.hour} {minute.day} {minute.month} *",
        fire_at=minute.isoformat(timespec="seconds"),
        fire_at_hhmm=minute.strftime("%H:%M"),
    )
    return result


def main() -> None:
    args = sys.argv[1:]
    if args in (["-h"], ["--help"]):
        print(USAGE, end="")
        return
    print(json.dumps(plan(" ".join(args)), ensure_ascii=False, separators=(",", ":")))


if __name__ == "__main__":
    main()
