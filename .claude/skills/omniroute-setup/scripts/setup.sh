#!/usr/bin/env bash
# Setup and diagnostics for the local OmniRoute gateway (127.0.0.1:20128).
# `check` is read-only (it never starts the daemon); every other subcommand
# mutates, prints its plan first and only creates what is missing.
#
# Secrets: ~/.omniroute/admin_password and cli_api_key are read internally to
# authenticate and are never printed or passed on a command line (jq --rawfile,
# curl -H @file, curl --data-binary @-). $DEEPSEEK_API_KEY goes into the request
# body through jq's env. Cookie jars and response bodies live in a 0700 mktemp
# dir removed on exit. ~/.config/zsh/secrets (ccr's token) is out of scope.
set -euo pipefail

BASE="${OMNIROUTE_SETUP_URL:-http://127.0.0.1:20128}"
DATA_DIR="$HOME/.omniroute"
PW_FILE="$DATA_DIR/admin_password"
KEY_FILE="$DATA_DIR/cli_api_key"
DEEPSEEK_URL="https://api.deepseek.com/v1"
TEST_MODEL="claude-deepseek-v4-flash"
WANT_COMBOS='{"claude-deepseek-v4-flash":"deepseek/deepseek-v4-flash","claude-deepseek-v4-pro":"deepseek/deepseek-v4-pro"}'

SUBCMD=check
DRY_RUN=0
STEPS=()
WARNINGS=()
TMPD=""
JAR=""
BIN=""

usage() {
  cat <<EOF
Usage: setup.sh [check|install|bootstrap|deepseek|test] [--dry-run]

  check      (default) read-only JSON report; never starts the daemon.
             Exit 0 = ready, 1 = something missing or unverified ("todo"/"manual").
  install    NPM_CONFIG_PREFIX=~/.local npm install -g omniroute (skipped if installed)
  bootstrap  start the daemon if needed, admin password (~/.omniroute/admin_password)
             + omniroute setup, then a local API key (~/.omniroute/cli_api_key)
  deepseek   node + connection (needs \$DEEPSEEK_API_KEY only if missing) + combos
             claude-deepseek-v4-flash|pro, then fixes the combos' models
  test       GET /v1/models + POST /v1/messages ($TEST_MODEL); exit 1 on failure

  --dry-run  mutating subcommands print the plan and change nothing
             (they still log in and list state when the daemon is up).

Mutating subcommands print each step to stderr ("+" runs, "=" already done)
and a JSON summary on stdout: {subcommand, dry_run, ok, steps[], warnings[]}.
Exit codes: 0 ok, 1 negative result, 2 usage or environment error.
Env (tests only): OMNIROUTE_SETUP_URL (default http://127.0.0.1:20128).
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

find_bin() {
  if [ -x "$HOME/.local/bin/omniroute" ]; then
    printf '%s' "$HOME/.local/bin/omniroute"
    return 0
  fi
  command -v omniroute 2>/dev/null || true
}

daemon_healthy() {
  curl -sf -m 2 -o /dev/null "$BASE/healthz"
}

# Strips token-looking strings and truncates, for server error messages.
JQ_MASK='def mask: tostring | gsub("(sk|ork|oma)[-_][A-Za-z0-9_-]{6,}"; "<redacted>") | .[0:200];'

# ---------- HTTP helpers (bodies stay in $TMPD, never on stdout) ----------

login() { # login <password-file> -> HTTP code; fills $JAR
  jq -nc --rawfile pw "$1" '{password: ($pw | rtrimstr("\n"))}' |
    curl -s -m 15 -c "$JAR" -o /dev/null -w '%{http_code}' -X POST "$BASE/api/auth/login" \
      -H 'content-type: application/json' --data-binary @- 2>/dev/null || true
}

api_get() { # api_get <path> <out-file> -> HTTP code
  curl -s -m 30 -b "$JAR" -o "$2" -w '%{http_code}' "$BASE$1" 2>/dev/null || true
}

# api_send <method> <path> <out-file>, JSON body on stdin; 0 on 2xx, else a
# masked error on stderr.
api_send() {
  local code
  code=$(curl -s -m 30 -b "$JAR" -X "$1" -o "$3" -w '%{http_code}' "$BASE$2" \
    -H 'content-type: application/json' --data-binary @- 2>/dev/null) || true
  case "$code" in 2??) return 0 ;; esac
  printf 'HTTP %s: %s\n' "${code:-000}" \
    "$(jq -r "$JQ_MASK"' (.error.message? // .error? // .message? // .) | mask' "$3" 2>/dev/null || echo '<no body>')" >&2
  return 1
}

fetch_state() { # lists connections, nodes and combos concurrently; 0 if all 200
  local name
  api_get "/api/providers?limit=5000" "$TMPD/providers.json" >"$TMPD/providers.code" &
  api_get "/api/provider-nodes" "$TMPD/nodes.json" >"$TMPD/nodes.code" &
  api_get "/api/combos" "$TMPD/combos.json" >"$TMPD/combos.code" &
  wait
  for name in providers nodes combos; do
    [ "$(cat "$TMPD/$name.code")" = 200 ] || {
      printf 'GET %s: HTTP %s\n' "$name" "$(cat "$TMPD/$name.code")" >&2
      return 1
    }
  done
}

# Summarizes the three lists into booleans and model ids (no names, no keys).
summarize_state() {
  jq -nc --slurpfile p "$TMPD/providers.json" --slurpfile n "$TMPD/nodes.json" \
    --slurpfile c "$TMPD/combos.json" --arg ds_url "$DEEPSEEK_URL" --argjson want "$WANT_COMBOS" '
    def rows(k): if type == "array" then . elif type == "object" then (.[k] // .items // .data // []) else [] end;
    def model_ids: [.models[]? | if type == "string" then . else (.model // .modelId // empty) end];
    ($p[0] | rows("connections")) as $conns
    | ($n[0] | rows("nodes")) as $nodes
    | ($c[0] | rows("combos")) as $combos
    | {verified: true,
       claude_oauth: ([$conns[] | select(.provider == "claude" or .provider == "claude-code")]
         | {present: (length > 0), active: any(.[]; .isActive != false)}),
       deepseek_node: ([$nodes[] | select(.prefix == "deepseek")]
         | {present: (length > 0), base_url: (.[0].baseUrl // null), base_url_ok: any(.[]; .baseUrl == $ds_url)}),
       deepseek_connection: ([$conns[] | select(.provider == "deepseek")]
         | {present: (length > 0), active: any(.[]; .isActive != false)}),
       combos: ($want | with_entries(.key as $name | .value as $model
         | ([$combos[] | select(.name == $name)] | first) as $co
         | .value = {present: ($co != null), id: ($co.id // null), want: $model,
                     models: (if $co == null then [] else ($co | model_ids) end)}
         | .value.models_ok = (.value.models == [$model]))),
       ollama: {node: any($nodes[]; .prefix == "ollama"),
                combos: [$combos[] | .name | strings | select(startswith("claude-ollama-"))]}}
    | .deepseek_ok = (.deepseek_node.present and .deepseek_connection.present
                      and all(.combos[]; .present and .models_ok))'
}

# ---------- check ----------

section_binary() {
  local version=""
  [ -n "$BIN" ] && version=$(timeout 30 "$BIN" --version 2>/dev/null | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+' | tail -n1) || true
  jq -nc --arg path "$BIN" --arg version "$version" \
    '{present: ($path != ""), path: (if $path == "" then null else $path end),
      version: (if $version == "" then null else $version end)}'
}

section_files() {
  local f args=()
  for f in "$PW_FILE" "$KEY_FILE"; do
    args+=("$(basename "$f")=$(bool [ -f "$f" ])=$(file_mode "$f")")
  done
  jq -nc '[$ARGS.positional[] | split("=") | {(.[0]): {exists: (.[1] == "true"),
      mode: (if .[2] == "" then null else .[2] end), mode_ok: (.[2] == "600")}}] | add' --args "${args[@]}"
}

section_ollama() {
  local running=false
  if pgrep -x ollama >/dev/null 2>&1 || port_listening 11434; then running=true; fi
  jq -nc --argjson running "$running" '{running: $running}'
}

# Port first, then /healthz, then the admin API; never starts anything.
section_daemon() {
  local port listening=false healthy=false config='{"verified":false,"reason":"daemon down"}'
  port=$(url_port "$BASE")
  if port_listening "$port"; then
    listening=true
    daemon_healthy && healthy=true
  fi
  if [ "$healthy" = true ]; then
    config=$(daemon_config)
  elif [ "$listening" = true ]; then
    config='{"verified":false,"reason":"port bound but /healthz does not answer (stalled daemon)"}'
  fi
  jq -nc --arg port "$port" --argjson listening "$listening" --argjson healthy "$healthy" \
    --argjson config "$config" '{daemon: {port: ($port | tonumber), listening: $listening, healthy: $healthy},
      config: $config}'
}

daemon_config() {
  local code
  if [ ! -f "$PW_FILE" ]; then
    echo '{"verified":false,"reason":"no admin_password file"}'
    return 0
  fi
  code=$(login "$PW_FILE")
  if [ "$code" != 200 ]; then
    jq -nc --arg code "$code" '{verified: false, reason: "admin login failed (HTTP \($code))"}'
    return 0
  fi
  if ! fetch_state 2>/dev/null; then
    echo '{"verified":false,"reason":"admin API list calls failed"}'
    return 0
  fi
  summarize_state
}

cmd_check() {
  need jq curl ss
  local name args=()
  section_binary >"$TMPD/binary.json" &
  section_files >"$TMPD/files.json" &
  section_ollama >"$TMPD/ollama.json" &
  section_daemon >"$TMPD/daemon.json" &
  wait
  for name in binary files ollama daemon; do
    args+=(--slurpfile "$name" "$TMPD/$name.json")
  done
  jq -nc "${args[@]}" --arg ds_url "$DEEPSEEK_URL" '
    {binary: $binary[0], files: $files[0], daemon: $daemon[0].daemon, config: $daemon[0].config,
     ollama: ($ollama[0] + {node: $daemon[0].config.ollama.node, combos: $daemon[0].config.ollama.combos})}
    | del(.config.ollama)
    | .todo = ([
        (if .binary.present then empty else "install" end),
        (if .files.admin_password.exists and .files.cli_api_key.exists then empty else "bootstrap" end),
        (if .config.verified and (.config.deepseek_ok | not) then "deepseek" else empty end)])
    | .manual = ([
        (.files | to_entries[] | select(.value.exists and (.value.mode_ok | not))
          | "chmod 600 ~/.omniroute/\(.key)"),
        (if .config.verified and (.config.claude_oauth.present | not)
          then "Claude OAuth: dashboard http://localhost:20128 -> Providers -> Claude Code (OAuth)" else empty end),
        (if .config.deepseek_node.present and (.config.deepseek_node.base_url_ok | not)
          then "node deepseek baseUrl is \(.config.deepseek_node.base_url), expected \($ds_url): fix it in the dashboard" else empty end),
        (if .config.verified then empty else "config not verified: \(.config.reason)" end)])
    | .ready = ((.todo | length) == 0 and (.manual | length) == 0)' >"$TMPD/report.json"
  cat "$TMPD/report.json"
  jq -e '.ready' "$TMPD/report.json" >/dev/null || exit 1
}

# ---------- step machinery ----------

record() { # record <status> <description>
  STEPS+=("$(jq -nc --arg step "$2" --arg status "$1" '{step: $step, status: $status}')")
}

emit_steps() {
  local steps warnings
  steps=$(printf '%s\n' "${STEPS[@]}" | jq -sc '.')
  warnings=$(jq -nc '$ARGS.positional' --args "${WARNINGS[@]}")
  jq -nc --arg cmd "$SUBCMD" --argjson dry "$DRY_RUN" --argjson steps "$steps" --argjson warnings "$warnings" \
    '{subcommand: $cmd, dry_run: ($dry == 1), ok: all($steps[]; .status != "failed"),
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

fail() { # fail <description>: record a failed precondition and stop
  printf '! %s\n' "$1" >&2
  record failed "$1"
  emit_steps
  exit 1
}

require_bin() {
  [ -n "$BIN" ] || die "omniroute not found in ~/.local/bin or PATH: run 'setup.sh install' first"
}

# ---------- daemon ----------

start_daemon() {
  local i
  # The daemon inherits stdout/stderr: keep them off our pipes or callers hang.
  "$BIN" serve --daemon --no-open --no-tray >"$TMPD/serve.log" 2>&1 </dev/null || {
    tail -n 20 "$TMPD/serve.log"
    return 1
  }
  for ((i = 0; i < 120; i++)); do
    daemon_healthy && return 0
    sleep 0.5
  done
  echo "daemon did not answer /healthz within 60s; its output:"
  tail -n 20 "$TMPD/serve.log"
  return 1
}

ensure_daemon() {
  if daemon_healthy; then
    skip "daemon up on $BASE"
    return 0
  fi
  if port_listening "$(url_port "$BASE")"; then
    fail "port $(url_port "$BASE") is bound but /healthz does not answer (stalled daemon): restart it with 'omniroute restart'"
  fi
  require_bin
  step "omniroute serve --daemon --no-open --no-tray (wait for /healthz)" start_daemon
}

# ---------- install ----------

npm_install() {
  (umask 022 && NPM_CONFIG_PREFIX="$HOME/.local" npm install -g omniroute)
}

cmd_install() {
  need jq
  if [ -n "$BIN" ]; then
    skip "omniroute already installed: $BIN"
    emit_steps
    return 0
  fi
  need npm
  step "NPM_CONFIG_PREFIX=~/.local npm install -g omniroute (~3GB)" npm_install
  emit_steps
}

# ---------- bootstrap ----------

# Generates the password into a temp file, sets it through INITIAL_PASSWORD
# (process env, not argv) and keeps the file only if logging in with it works:
# `omniroute setup` ignores INITIAL_PASSWORD when a password already exists.
set_admin_password() {
  local tmp code
  mkdir -p "$DATA_DIR" || return 1
  tmp=$(mktemp "$PW_FILE.XXXXXX") || return 1
  openssl rand -base64 24 >"$tmp" || {
    rm -f "$tmp"
    return 1
  }
  INITIAL_PASSWORD="$(<"$tmp")" "$BIN" setup --non-interactive </dev/null || {
    rm -f "$tmp"
    return 1
  }
  code=$(login "$tmp")
  if [ "$code" != 200 ]; then
    rm -f "$tmp"
    echo "login with the new password failed (HTTP $code): OmniRoute already had an admin password."
    echo "Recover it into $PW_FILE (0600) or reset it from the dashboard, then rerun bootstrap."
    return 1
  fi
  chmod 600 "$tmp" && mv -f "$tmp" "$PW_FILE"
}

provision_key() {
  local tmp
  jq -nc '{name: "cli-local"}' | api_send POST /api/v1/registered-keys "$TMPD/key.out" || return 1
  tmp=$(mktemp "$KEY_FILE.XXXXXX") || return 1
  jq -er '.key // empty' "$TMPD/key.out" >"$tmp" || {
    rm -f "$tmp"
    echo "response has no \"key\" field"
    return 1
  }
  chmod 600 "$tmp" && mv -f "$tmp" "$KEY_FILE"
}

cmd_bootstrap() {
  need curl jq openssl ss
  require_bin
  ensure_daemon
  if [ -f "$PW_FILE" ]; then
    skip "admin password exists: $PW_FILE"
    if daemon_healthy && [ "$(login "$PW_FILE")" != 200 ]; then
      fail "login with $PW_FILE failed: fix the file or reset the password from the dashboard"
    fi
  else
    step "generate $PW_FILE (openssl rand -base64 24, 0600) + omniroute setup --non-interactive" set_admin_password
  fi
  if [ -f "$KEY_FILE" ]; then
    skip "API key exists: $KEY_FILE"
  else
    step "POST /api/v1/registered-keys {name: cli-local} -> $KEY_FILE (0600)" provision_key
  fi
  emit_steps
}

# ---------- deepseek ----------

create_node() {
  jq -nc --arg url "$DEEPSEEK_URL" \
    '{provider: "deepseek", prefix: "deepseek", apiType: "chat", baseUrl: $url, name: "deepseek"}' |
    api_send POST /api/provider-nodes "$TMPD/node.out"
}

create_connection() {
  jq -nc '{provider: "deepseek", name: "DeepSeek", apiKey: env.DEEPSEEK_API_KEY, isActive: true}' |
    api_send POST /api/providers "$TMPD/connection.out"
}

put_combo_models() { # put_combo_models <id> <model>
  jq -nc --arg m "$2" '{models: [$m]}' | api_send PUT "/api/combos/$1" "$TMPD/combo-put.out"
}

# Creates the combo with its model, then PUTs the models when the stored combo
# doesn't carry exactly that model (older versions ignored them on create).
create_combo() { # create_combo <name> <model>
  local id ok
  jq -nc --arg name "$1" --arg m "$2" '{name: $name, models: [$m], strategy: "priority"}' |
    api_send POST /api/combos "$TMPD/combo-post.out" || return 1
  id=$(jq -r '.id // .combo.id // empty' "$TMPD/combo-post.out")
  [ -n "$id" ] || {
    echo "create response has no combo id"
    return 1
  }
  ok=$(jq -r --arg m "$2" '(.combo // .) | [.models[]? | if type == "string" then . else (.model // .modelId // empty) end] == [$m]' "$TMPD/combo-post.out")
  [ "$ok" = true ] && return 0
  echo "combo $1 created without the expected model; fixing it with PUT"
  put_combo_models "$id" "$2"
}

plan_combos() {
  local name model present id models_ok
  while IFS='|' read -r name model present id models_ok; do
    if [ "$present" = false ]; then
      step "POST /api/combos {name: $name, models: [$model]} (+ PUT models if they don't stick)" create_combo "$name" "$model"
    elif [ "$models_ok" = false ]; then
      step "PUT /api/combos/$id {models: [$model]} (fix $name)" put_combo_models "$id" "$model"
    else
      skip "combo $name -> $model"
    fi
  done < <(jq -r '.combos | to_entries[] | [.key, .value.want, .value.present, (.value.id // "-"), .value.models_ok] | join("|")' "$TMPD/state.json")
}

cmd_deepseek() {
  need curl jq ss
  [ -f "$PW_FILE" ] || die "$PW_FILE missing: run 'setup.sh bootstrap' first"
  ensure_daemon
  if ! daemon_healthy; then # only possible under --dry-run
    step "log in, list nodes/connections/combos, create the missing deepseek node, connection and combos" true
    emit_steps
    return 0
  fi
  [ "$(login "$PW_FILE")" = 200 ] || fail "admin login with $PW_FILE failed"
  fetch_state || fail "could not list providers/nodes/combos"
  summarize_state >"$TMPD/state.json"

  if [ "$(jq -r '.deepseek_connection.present' "$TMPD/state.json")" = false ] && [ -z "${DEEPSEEK_API_KEY:-}" ]; then
    die "the deepseek connection is missing and \$DEEPSEEK_API_KEY is empty: export it in the shell that runs this script"
  fi

  if [ "$(jq -r '.deepseek_node.present' "$TMPD/state.json")" = true ]; then
    skip "node deepseek exists ($(jq -r '.deepseek_node.base_url' "$TMPD/state.json"))"
    [ "$(jq -r '.deepseek_node.base_url_ok' "$TMPD/state.json")" = true ] ||
      warn "node deepseek baseUrl is not $DEEPSEEK_URL: fix it in the dashboard"
  else
    step "POST /api/provider-nodes {prefix: deepseek, apiType: chat, baseUrl: $DEEPSEEK_URL}" create_node
  fi

  if [ "$(jq -r '.deepseek_connection.present' "$TMPD/state.json")" = true ]; then
    skip "connection deepseek exists"
  else
    step "POST /api/providers {provider: deepseek, apiKey: <redacted>}" create_connection
  fi

  plan_combos
  emit_steps
}

# ---------- test ----------

test_models() {
  local code
  code=$(curl -s -m 90 -H @"$TMPD/auth.h" -o "$TMPD/models.body" -w '%{http_code}' "$BASE/v1/models" 2>/dev/null) || true
  jq -nc --arg code "${code:-000}" --rawfile body "$TMPD/models.body" --argjson want "$WANT_COMBOS" "$JQ_MASK"'
    (($body | fromjson?) // null) as $j
    | [$j.data[]?.id] as $ids
    | {http: ($code | tonumber), total: ($ids | length),
       claude: ($ids | map(select(startswith("claude/"))) | length),
       deepseek: ($ids | map(select(startswith("deepseek/"))) | length),
       combos: ($want | keys | map(. as $k | {($k): ($ids | index($k) != null)}) | add)}
    + (if $code == "200" then {} elif $code == "000" then {error: "no response"}
       else {error: ($j.error.message? // $body | mask)} end)
    | .pass = (.http == 200 and all(.combos[]; .))'
}

test_messages() {
  local code
  code=$(
    curl -s -m 120 -H @"$TMPD/auth.h" -o "$TMPD/messages.body" -w '%{http_code}' "$BASE/v1/messages" \
      -H 'content-type: application/json' -H 'anthropic-version: 2023-06-01' \
      --data-binary @- 2>/dev/null <<EOF
{"model":"$TEST_MODEL","max_tokens":48,"messages":[{"role":"user","content":"oi"}]}
EOF
  ) || true
  jq -nc --arg code "${code:-000}" --rawfile body "$TMPD/messages.body" "$JQ_MASK"'
    (($body | fromjson?) // null) as $j
    | {http: ($code | tonumber), model: $j.model?, type: $j.type?, stop_reason: $j.stop_reason?,
       blocks: [$j.content[]?.type], output_tokens: $j.usage.output_tokens?}
    + (if $code == "200" and $j.type? != "error" then {} elif $code == "000" then {error: "no response"}
       else {error: ($j.error.message? // $body | mask)} end)
    | .pass = (.http == 200 and .type == "message")'
}

cmd_test() {
  need curl jq ss
  [ -f "$KEY_FILE" ] || die "$KEY_FILE missing: run 'setup.sh bootstrap' first"
  ensure_daemon
  if ((DRY_RUN)); then
    step "GET $BASE/v1/models (Bearer <cli_api_key>)" true
    step "POST $BASE/v1/messages {model: $TEST_MODEL, max_tokens: 48}" true
    emit_steps
    return 0
  fi
  printf 'Authorization: Bearer %s\n' "$(<"$KEY_FILE")" >"$TMPD/auth.h"
  : >"$TMPD/models.body"
  : >"$TMPD/messages.body"
  printf '+ GET %s/v1/models | POST %s/v1/messages (%s)\n' "$BASE" "$BASE" "$TEST_MODEL" >&2
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
      check | install | bootstrap | deepseek | test) SUBCMD=$arg ;;
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
  umask 077
  TMPD=$(mktemp -d)
  JAR="$TMPD/cookies"
  trap cleanup EXIT
  BIN=$(find_bin)
  "cmd_$SUBCMD"
}

main "$@"
