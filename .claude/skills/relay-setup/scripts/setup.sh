#!/usr/bin/env bash
# Setup and diagnostics for the local Claude relay (~/.local/bin/claude-relay,
# socket-activated on 127.0.0.1:4000). `check` is read-only; every other
# subcommand mutates, prints its plan first and is idempotent.
#
# Secrets: ~/.config/litellm/.env is only checked for existence, mode and the
# presence of a DEEPSEEK_API_KEY line; its value never reaches stdout/stderr or
# a command line. Nothing here touches ~/.config/zsh/secrets.
set -euo pipefail

VENV="$HOME/.local/share/litellm-venv"
RELAY_BIN="$HOME/.local/bin/claude-relay"
ENV_FILE="$HOME/.config/litellm/.env"
CACHE_DIR="$HOME/.cache/litellm"
UNIT_DIR="$HOME/.config/systemd/user"
RELAY_URL="${RELAY_SETUP_URL:-http://127.0.0.1:4000}"
OLLAMA_URL="${RELAY_SETUP_OLLAMA_URL:-http://127.0.0.1:11434}"
TEST_MODEL="anthropic/deepseek-v4-flash"
DEPS=(fastapi httpx uvicorn)
UNITS=(relay.socket relay.service)

SUBCMD=check
DRY_RUN=0
PROBE=0
FORCE=0
STEPS=()
WARNINGS=()
TMPD=""

usage() {
  cat <<EOF
Usage: setup.sh [check|venv|secret|enable|test] [--probe] [--force] [--dry-run]

  check   (default) read-only report as JSON on stdout.
          Exit 0 = ready, 1 = something missing (see "todo"/"manual").
          --probe also GETs <relay>/v1/models, which socket-activates the relay.
  venv    create $VENV and pip install what is missing of: ${DEPS[*]}
  secret  write $ENV_FILE (0600) from \$DEEPSEEK_API_KEY.
          Refuses an empty variable; refuses to overwrite unless --force.
  enable  systemctl --user daemon-reload + enable --now relay.socket
  test    GET /v1/models + POST /v1/messages ($TEST_MODEL, max_tokens 100);
          prints a pass/fail summary, exit 1 if any test fails.

  --dry-run  mutating subcommands print the plan and change nothing.

Mutating subcommands print each step to stderr ("+" runs, "=" already done)
and a JSON summary on stdout: {subcommand, dry_run, ok, steps[], warnings[]}.
Exit codes: 0 ok, 1 negative result, 2 usage or environment error.
Env (tests only): RELAY_SETUP_URL (default http://127.0.0.1:4000),
RELAY_SETUP_OLLAMA_URL (default http://127.0.0.1:11434).
EOF
}

die() {
  printf 'setup.sh: %s\n' "$1" >&2
  exit "${2:-2}"
}

need() {
  local tool
  for tool in "$@"; do
    command -v "$tool" >/dev/null 2>&1 || die "missing tool: $tool"
  done
}

cleanup() {
  [ -n "$TMPD" ] && rm -rf "$TMPD"
  return 0
}

bool() {
  if "$@"; then echo true; else echo false; fi
}

file_mode() {
  stat -c '%a' "$1" 2>/dev/null || true
}

url_port() {
  local hostport=${1#*://}
  hostport=${hostport%%/*}
  printf '%s' "${hostport##*:}"
}

port_listening() {
  [ -n "$(ss -Htln "sport = :$1" 2>/dev/null)" ]
}

unit_state() { # unit_state <unit> <is-enabled|is-active>
  local state
  state=$(systemctl --user "$2" "$1" 2>/dev/null | head -n1) || true
  printf '%s' "${state:-unknown}"
}

# Strips token-looking strings and truncates, for upstream error messages.
JQ_MASK='def mask: tostring | gsub("(sk|ork|oma)[-_][A-Za-z0-9_-]{6,}"; "<redacted>") | .[0:200];'
# Error text for a failed call; expects $code, $body and $j bound in the program.
# shellcheck disable=SC2016
JQ_ERROR='def error_text: if $code == "000" then "no response (connection refused or timeout)"
  else ($j.error.message? // $j.error? // $body | mask) end;'

# Counts model ids per family in a /v1/models body (jq program, literal on purpose).
# shellcheck disable=SC2016
JQ_MODEL_FAMILIES='def families: [.data[]?.id] as $ids | {
  total: ($ids | length),
  claude: ($ids | map(select(startswith("claude"))) | length),
  deepseek: ($ids | map(select(test("deepseek") and (test("ollama/") | not))) | length),
  ollama: ($ids | map(select(test("ollama/"))) | length)};'

# ---------- check sections (each prints one JSON value) ----------

missing_deps() {
  local py="$VENV/bin/python3"
  if [ ! -x "$py" ]; then
    printf '%s\n' "${DEPS[@]}"
    return 0
  fi
  "$py" -I -c 'import importlib.util as u, sys
for m in sys.argv[1:]:
    if u.find_spec(m) is None:
        print(m)' "${DEPS[@]}"
}

section_venv() {
  local missing
  missing=$(missing_deps 2>/dev/null) || missing=$(printf '%s\n' "${DEPS[@]}")
  jq -nc --arg path "$VENV" --argjson exists "$(bool [ -x "$VENV/bin/python3" ])" \
    --arg missing "$missing" '($missing | split("\n") | map(select(. != ""))) as $m
      | {path: $path, exists: $exists, missing_deps: $m, ok: ($exists and ($m | length == 0))}'
}

section_relay_bin() {
  local shebang=""
  [ -f "$RELAY_BIN" ] && IFS= read -r shebang <"$RELAY_BIN"
  jq -nc --arg path "$RELAY_BIN" --arg shebang "$shebang" --arg want "#!$VENV/bin/python" \
    --argjson exists "$(bool [ -f "$RELAY_BIN" ])" --argjson exec "$(bool [ -x "$RELAY_BIN" ])" \
    '{path: $path, exists: $exists, executable: $exec, shebang: $shebang,
      shebang_ok: ($shebang | startswith($want))}
      | .ok = (.exists and .executable and .shebang_ok)'
}

section_secret() {
  local mode="" has_key=false
  if [ -f "$ENV_FILE" ]; then
    mode=$(file_mode "$ENV_FILE")
    grep -q '^DEEPSEEK_API_KEY=.' "$ENV_FILE" 2>/dev/null && has_key=true
  fi
  jq -nc --arg path "$ENV_FILE" --arg mode "$mode" --argjson has_key "$has_key" \
    --argjson exists "$(bool [ -f "$ENV_FILE" ])" \
    '{path: $path, exists: $exists, mode: (if $mode == "" then null else $mode end),
      mode_ok: ($mode == "600"), has_key: $has_key}
      | .ok = (.exists and .mode_ok and .has_key)'
}

section_units() {
  local unit present=()
  for unit in "${UNITS[@]}"; do
    present+=("$unit=$(bool [ -f "$UNIT_DIR/$unit" ])")
  done
  jq -nc --arg dir "$UNIT_DIR" '[$ARGS.positional[] | split("=") | {(.[0]): (.[1] == "true")}] | add
    | {dir: $dir, files: ., ok: all(.[]; .)}' --args "${present[@]}"
}

section_systemd() {
  local port
  port=$(url_port "$RELAY_URL")
  jq -nc --arg se "$(unit_state relay.socket is-enabled)" --arg sa "$(unit_state relay.socket is-active)" \
    --arg va "$(unit_state relay.service is-active)" --argjson listening "$(bool port_listening "$port")" \
    '{socket_enabled: $se, socket_active: $sa, socket_listening: $listening, service_active: $va,
      ok: ($se == "enabled" and $sa == "active")}'
}

section_ollama() {
  local port running=false tags=""
  port=$(url_port "$OLLAMA_URL")
  if pgrep -x ollama >/dev/null 2>&1 || port_listening "$port"; then
    running=true
    tags=$(curl -sf -m 2 "$OLLAMA_URL/api/tags" 2>/dev/null) || tags=""
  fi
  jq -nc --argjson running "$running" --arg tags "$tags" \
    '{running: $running,
      reachable: (if $running then ($tags != "") else null end),
      models: (if $tags == "" then null else ((($tags | fromjson?) // {}) | .models // [] | length) end)}'
}

section_endpoint() {
  if ((!PROBE)); then
    echo '{"probed":false}'
    return 0
  fi
  local code
  code=$(curl -s -m 15 -o "$TMPD/probe.body" -w '%{http_code}' "$RELAY_URL/v1/models" 2>/dev/null) || true
  jq -nc --arg code "${code:-000}" --rawfile body "$TMPD/probe.body" "$JQ_MODEL_FAMILIES"'
    (($body | fromjson?) // null) as $j
    | {probed: true, http: ($code | tonumber), ok: ($code == "200"),
       models: (if $code == "200" and $j != null then ($j | families) else null end)}'
}

cmd_check() {
  need jq curl ss systemctl
  local sections=(venv relay_bin secret units systemd ollama endpoint) name args=()
  : >"$TMPD/probe.body"
  for name in "${sections[@]}"; do
    "section_$name" >"$TMPD/$name.json" &
  done
  wait
  for name in "${sections[@]}"; do
    args+=(--slurpfile "$name" "$TMPD/$name.json")
  done
  jq -nc "${args[@]}" '
    {venv: $venv[0], relay_bin: $relay_bin[0], secret: $secret[0], units: $units[0],
     systemd: $systemd[0], ollama: $ollama[0], endpoint: $endpoint[0]}
    | .todo = ([
        (if .venv.ok then empty else "venv" end),
        (if .secret.exists and .secret.has_key then empty else "secret" end),
        (if .systemd.ok then empty else "enable" end)])
    | .manual = ([
        (if .secret.exists and (.secret.mode_ok | not) then "chmod 600 \(.secret.path)" else empty end),
        (if .relay_bin.ok then empty else "relay_bin: comes with the yadm clone (shebang must point to the venv)" end),
        (if .units.ok then empty else "systemd units: come with the yadm clone" end)])
    | .ready = ((.todo | length) == 0 and (.manual | length) == 0)' >"$TMPD/report.json"
  cat "$TMPD/report.json"
  jq -e '.ready' "$TMPD/report.json" >/dev/null || exit 1
}

# ---------- mutating subcommands ----------

record() { # record <status> <description>
  STEPS+=("$(jq -nc --arg step "$2" --arg status "$1" '{step: $step, status: $status}')")
}

emit_steps() {
  local steps warnings
  steps=$(printf '%s\n' "${STEPS[@]}" | jq -sc '.')
  warnings=$(jq -nc '$ARGS.positional' --args "${WARNINGS[@]}")
  jq -nc --arg cmd "$SUBCMD" --argjson dry "$DRY_RUN" --argjson steps "$steps" --argjson warnings "$warnings" \
    '{subcommand: $cmd, dry_run: ($dry == 1), ok: all($steps[]; .status != "failed" and .status != "refused"),
      steps: $steps, warnings: $warnings}'
}

# step <description> <command...>: announce, run unless --dry-run; abort on failure.
# Commands run in an `if`, so functions passed here must chain with `|| return 1`.
step() {
  local desc=$1
  shift
  printf '+ %s\n' "$desc" >&2
  if ((DRY_RUN)); then
    record planned "$desc"
    return 0
  fi
  if "$@" >&2; then
    record "done" "$desc"
    return 0
  fi
  record failed "$desc"
  emit_steps
  exit 1
}

skip() {
  printf '= %s\n' "$1" >&2
  record skipped "$1"
}

warn() {
  printf 'warning: %s\n' "$1" >&2
  WARNINGS+=("$1")
}

cmd_venv() {
  need python3 jq
  local missing=()
  if [ -x "$VENV/bin/python3" ]; then
    skip "venv exists: $VENV"
  else
    step "python3 -m venv $VENV" python3 -m venv "$VENV"
  fi
  mapfile -t missing < <(missing_deps 2>/dev/null || printf '%s\n' "${DEPS[@]}")
  if ((${#missing[@]} == 0)); then
    skip "deps already installed: ${DEPS[*]}"
  else
    step "$VENV/bin/pip install ${missing[*]}" "$VENV/bin/pip" install "${missing[@]}"
  fi
  emit_steps
}

make_secret_dirs() {
  mkdir -p "$(dirname "$ENV_FILE")" "$CACHE_DIR"
}

write_env_file() {
  local tmp
  tmp=$(mktemp "$ENV_FILE.XXXXXX") || return 1
  printf 'DEEPSEEK_API_KEY=%s\n' "$DEEPSEEK_API_KEY" >"$tmp" || {
    rm -f "$tmp"
    return 1
  }
  chmod 600 "$tmp" && mv -f "$tmp" "$ENV_FILE"
}

cmd_secret() {
  need jq
  umask 077
  [ -n "${DEEPSEEK_API_KEY:-}" ] || die "\$DEEPSEEK_API_KEY is empty: export it in the shell that runs this script"
  if [ -e "$ENV_FILE" ] && ((!FORCE)); then
    printf '! %s already exists (pass --force to overwrite)\n' "$ENV_FILE" >&2
    record refused "$ENV_FILE already exists (pass --force to overwrite)"
    emit_steps
    exit 1
  fi
  step "mkdir -p (0700) $(dirname "$ENV_FILE") $CACHE_DIR" make_secret_dirs
  step "write $ENV_FILE (0600): DEEPSEEK_API_KEY=<redacted>" write_env_file
  emit_steps
}

cmd_enable() {
  need jq systemctl
  local unit
  for unit in "${UNITS[@]}"; do
    [ -f "$UNIT_DIR/$unit" ] || die "missing $UNIT_DIR/$unit (it comes with the yadm clone)"
  done
  [ -n "$(missing_deps 2>/dev/null || echo x)" ] && warn "venv incomplete: run 'setup.sh venv' or the relay fails on first use"
  [ -f "$ENV_FILE" ] || warn "$ENV_FILE missing: run 'setup.sh secret' or relay.service will not start"
  step "systemctl --user daemon-reload" systemctl --user daemon-reload
  if [ "$(unit_state relay.socket is-enabled)" = enabled ] && [ "$(unit_state relay.socket is-active)" = active ]; then
    skip "relay.socket already enabled and active"
  else
    step "systemctl --user enable --now relay.socket" systemctl --user enable --now relay.socket
  fi
  emit_steps
}

test_models() {
  local code
  code=$(curl -s -m 30 -o "$TMPD/models.body" -w '%{http_code}' "$RELAY_URL/v1/models" 2>/dev/null) || true
  jq -nc --arg code "${code:-000}" --rawfile body "$TMPD/models.body" "$JQ_MODEL_FAMILIES $JQ_MASK"'
    (($body | fromjson?) // null) as $j | '"$JQ_ERROR"'
    {http: ($code | tonumber)}
    + (if $code == "200" then ($j | families) else {error: error_text} end)
    | .pass = (.http == 200 and (.deepseek // 0) > 0)'
}

test_messages() {
  local code
  code=$(
    curl -s -m 120 -o "$TMPD/messages.body" -w '%{http_code}' "$RELAY_URL/v1/messages" \
      -H 'content-type: application/json' -H 'anthropic-version: 2023-06-01' \
      --data-binary @- 2>/dev/null <<EOF
{"model":"$TEST_MODEL","max_tokens":100,"messages":[{"role":"user","content":"oi"}]}
EOF
  ) || true
  jq -nc --arg code "${code:-000}" --rawfile body "$TMPD/messages.body" "$JQ_MASK"'
    (($body | fromjson?) // null) as $j | '"$JQ_ERROR"'
    {http: ($code | tonumber), model: $j.model?, type: $j.type?, stop_reason: $j.stop_reason?,
       blocks: [$j.content[]?.type], output_tokens: $j.usage.output_tokens?}
    + (if $j.type? == "error" or $code != "200" then {error: error_text} else {} end)
    | .pass = (.http == 200 and .type == "message")'
}

cmd_test() {
  need curl jq
  if ((DRY_RUN)); then
    step "curl -s $RELAY_URL/v1/models" true
    step "curl -s $RELAY_URL/v1/messages -d '{\"model\":\"$TEST_MODEL\",\"max_tokens\":100,...}'" true
    emit_steps
    return 0
  fi
  printf '+ GET %s/v1/models | POST %s/v1/messages (%s)\n' "$RELAY_URL" "$RELAY_URL" "$TEST_MODEL" >&2
  : >"$TMPD/models.body"
  : >"$TMPD/messages.body"
  test_models >"$TMPD/t_models.json" &
  test_messages >"$TMPD/t_messages.json" &
  wait
  jq -nc --slurpfile m "$TMPD/t_models.json" --slurpfile x "$TMPD/t_messages.json" \
    '{subcommand: "test", models: $m[0], messages: $x[0], pass: ($m[0].pass and $x[0].pass)}' >"$TMPD/test.json"
  cat "$TMPD/test.json"
  jq -e '.pass' "$TMPD/test.json" >/dev/null || exit 1
}

parse_args() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      check | venv | secret | enable | test) SUBCMD=$arg ;;
      --probe) PROBE=1 ;;
      --force) FORCE=1 ;;
      --dry-run) DRY_RUN=1 ;;
      -h | --help)
        usage
        exit 0
        ;;
      *) die "unknown argument: $arg (see --help)" ;;
    esac
  done
}

main() {
  parse_args "$@"
  TMPD=$(mktemp -d)
  trap cleanup EXIT
  "cmd_$SUBCMD"
}

main "$@"
