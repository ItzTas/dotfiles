#!/usr/bin/env bash
# audit helper: secret scan of the working tree, staged changes or full git history with the
# best installed scanner, normalized to JSON with masked previews, plus tracked sensitive files
# and an optional dependency/misconfiguration pass. Raw secret values never reach stdout or
# stderr; scanner reports live in a mode-700 temp dir removed on exit.
# $HOME/.config/zsh/secrets is never scanned.
# shellcheck disable=SC2016 # single-quoted jq/awk programs carry their own $variables
set -euo pipefail

SECRETS_DIR=$HOME/.config/zsh/secrets
SECRETS_REAL="" SECRETS_REPO=""
SCANNERS=(gitleaks trufflehog trivy heuristic)
declare -A CAPABLE=(
  [gitleaks]="worktree staged history"
  [trufflehog]="worktree history"
  [trivy]="worktree staged"
  [heuristic]="worktree staged history"
)
# Cheap lowercase prefilter for the heuristic; jq's rules below decide what is a finding.
PREFILTER='akia|asia|abia|acca|private key|eyj|gh[pousr]_|glpat-|passw|pwd|secret|token|api.?key'
MODE=worktree TARGET="" VULN=0
SCOPE="" TOP="" REL="" BASE="" TMP=""
PATHSPEC=()
declare -A USED=()
# Set to a rule id to make the heuristic emit only that rule (used for the supplement pass).
HEURISTIC_ONLY=""

JQ_LIB=$(
  cat <<'JQ'
def mask:
  if length >= 16 then .[0:4] + ("•" * ([length - 8, 16] | min)) + .[-4:]
  elif length >= 10 then .[0:2] + ("•" * (length - 4)) + .[-2:]
  else "••••••••" end;
# For text that may hold a secret the scanner didn't mask: long digit-bearing tokens get masked.
def sanitize:
  gsub("\\*{3,}"; "••••")
  | gsub("(?<t>[A-Za-z0-9+/=_.-]*[0-9][A-Za-z0-9+/=_.-]*)";
      if (.t | length) >= 16 then (.t | mask) else .t end)
  | .[0:160];
def rank: ascii_downcase
  | {critical: 0, high: 1, moderate: 2, medium: 2, low: 3, info: 4}[.] // 5;
def rel($base): if startswith($base + "/") then .[($base | length) + 1:] else . end;
def placeholder:
  test("^(?:\\$|\\{\\{|<|%\\(|\\*+$|x{4,}$)"; "i") or test("^(?:[a-z_.]+|[A-Z_]+)$")
  or test("changeme|change_me|example|placeholder|your[_-]|redacted|dummy|sample"; "i");
def rules: [
  {id: "private-key", type: "Private key", severity: "CRITICAL", show: true,
   re: "-----BEGIN[A-Z ]*PRIVATE KEY(?: BLOCK)?-----"},
  {id: "aws-access-key-id", type: "AWS access key ID", severity: "CRITICAL",
   re: "\\b((?:AKIA|ASIA|ABIA|ACCA)[0-9A-Z]{16})\\b"},
  {id: "github-token", type: "GitHub token", severity: "CRITICAL",
   re: "\\b(gh[pousr]_[A-Za-z0-9]{36,255})\\b"},
  {id: "gitlab-token", type: "GitLab token", severity: "CRITICAL",
   re: "\\b(glpat-[A-Za-z0-9_-]{20,})"},
  {id: "jwt", type: "JWT", severity: "MEDIUM",
   re: "\\b(eyJ[A-Za-z0-9_-]{10,}\\.eyJ[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]{10,})"},
  {id: "secret-assignment", type: "Hardcoded secret", severity: "HIGH", check: true,
   re: "(?i)(?:password|passwd|pwd|secret|token|api[_-]?key)[a-z0-9_-]*[\"']?\\s*(?::=|=>|[:=])\\s*[\"']([^\"'\\s]{8,})[\"']"},
  {id: "secret-assignment", type: "Hardcoded secret", severity: "HIGH", check: true,
   re: "(?i)^\\s*(?:export\\s+)?[a-z0-9_]*(?:password|passwd|secret|token|api_?key)[a-z0-9_]*=([^\\s\"'][^\\s\"']{7,})\\s*$"}
];
# Input: {file, line, text, commit}. Output: one finding per rule match, value masked.
def classify($where):
  . as $hit
  | rules[] as $r
  | select(($ARGS.named.only // "") as $o | $o == "" or $r.id == $o)
  | ($hit.text | match($r.re; "g")) as $m
  | (if $r.show then $m.string else $m.captures[0].string end) as $value
  | select($value != null)
  | select((($r.check // false) | not) or ($value | placeholder | not))
  | {type: $r.type, rule: $r.id, severity: $r.severity, file: $hit.file, line: $hit.line,
     preview: (if $r.show then $value else ($value | mask) end), where: $where,
     commit: $hit.commit, scanner: "heuristic"};
JQ
)

# Parses `git log -p` / `git diff` output (-U0) into commit<TAB>file<TAB>line<TAB>added text,
# keeping only added lines that pass the prefilter.
DIFF_AWK='
/^commit [0-9a-f]+$/ { commit = $2; next }
/^diff --git / { header = 1; file = ""; next }
header && /^\+\+\+ / { file = substr($0, 5); sub(/^b\//, "", file); next }
/^@@ / { header = 0; split($0, part, " "); n = part[3]; sub(/^\+/, "", n); sub(/,.*/, "", n); line = n + 0; next }
header { next }
/^\+/ {
  text = substr($0, 2)
  if (file != "" && tolower(text) ~ prefilter) printf "%s\t%s\t%d\t%s\n", commit, file, line, text
  line++
}'

usage() {
  cat <<'EOF'
Usage: scan.sh [path | --staged | --history] [--vuln]

  (none)      working tree of the current repo (cwd outside a repo); .gitignored files skipped
  <path>      that path only (inside a repo, --staged/--history narrow to it too)
  --staged    staged changes only (-staged, -s)
  --history   working tree + every commit on every ref (-history, -h)
  --vuln      also run the dependency/misconfig pass (trivy vuln,misconfig; npm/cargo audit)

Scanner preference: gitleaks > trufflehog > trivy > heuristic (rg/git + regexes).
stdout: {mode, target, repo, scanners: {worktree?, staged?, history?}, heuristic,
         findings: [{type, rule, severity, file, line, preview, where, commit, scanner}],
         sensitive_files: [{path, where}], vuln: null | [{tool, status, ...}],
         summary: {secrets, sensitive_files, vuln}}
  preview is always masked; where is worktree | staged | history; file is repo-relative.
Exit: 0 clean, 1 secrets or tracked sensitive files found, 2 usage/environment error.
EOF
}

die() {
  printf 'scan.sh: %s\n' "$1" >&2
  exit 2
}

in_secrets() {
  local path=$1 dir
  for dir in "$SECRETS_DIR" "$SECRETS_REAL"; do
    [[ $path == "$dir" || $path == "$dir"/* ]] && return 0
  done
  return 1
}

holds_secrets() {
  local root=${1%/} dir
  for dir in "$SECRETS_DIR" "$SECRETS_REAL"; do
    [[ $dir == "$root"/* ]] && return 0
  done
  return 1
}

# Resolves $1 one component at a time, so nothing under the secrets dir is ever stat'ed.
safe_resolve() {
  local lexical part resolved=/
  local -a parts
  lexical=$(realpath -ms -- "$1")
  in_secrets "$lexical" && return 1
  IFS=/ read -ra parts <<<"${lexical#/}"
  for part in "${parts[@]}"; do
    [[ -n $part ]] || continue
    resolved=$(realpath -m -- "${resolved%/}/$part")
    in_secrets "$resolved" && return 1
  done
  printf '%s\n' "$resolved"
}

parse_args() {
  local arg
  for arg; do
    case $arg in
      --help) usage && exit 0 ;;
      --staged | -staged | -s) MODE=staged ;;
      --history | -history | -h) MODE=history ;;
      --vuln | -vuln) VULN=1 ;;
      -*) die "unknown flag: $arg (see --help)" ;;
      *)
        [[ -z $TARGET ]] || die "only one path allowed"
        TARGET=$arg
        ;;
    esac
  done
  [[ -z $TARGET || $MODE != worktree ]] || MODE=path
}

resolve_scope() {
  local dir secrets
  SECRETS_REAL=$(realpath -m -- "$SECRETS_DIR")
  SECRETS_REPO=$(git -C "${SECRETS_REAL%/*}" rev-parse --show-toplevel 2>/dev/null || true)
  TARGET=${TARGET:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}
  SCOPE=$(safe_resolve "$TARGET") || die "refusing to scan inside $SECRETS_DIR"
  [[ -e $SCOPE ]] || die "no such path: $TARGET"
  dir=$SCOPE
  [[ -d $dir ]] || dir=${SCOPE%/*}
  TOP=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)
  BASE=${TOP:-$dir}
  [[ -n $TOP || $MODE == worktree || $MODE == path ]] || die "--$MODE needs a git repository"
  [[ -n $TOP ]] || return 0
  REL=$(realpath -m --relative-to="$TOP" -- "$SCOPE")
  PATHSPEC=(":(top)")
  [[ $REL == . ]] || PATHSPEC=(":(top,literal)$REL")
  for secrets in "$SECRETS_DIR" "$SECRETS_REAL"; do
    [[ $secrets == "$TOP"/* ]] && PATHSPEC+=(":(top,exclude)${secrets#"$TOP"/}")
  done
  return 0
}

installed() {
  local name=$1 kind=$2
  [[ $name != heuristic ]] && {
    command -v "$name" >/dev/null
    return
  }
  [[ $kind != worktree ]] || command -v rg >/dev/null
}

overlaps_secrets_repo() {
  local path=${1%/}
  [[ -n $SECRETS_REPO ]] || return 1
  [[ $path == "$SECRETS_REPO" || $path == "$SECRETS_REPO"/* || $SECRETS_REPO == "$path"/* ]]
}

# Only rg's glob (and git pathspecs) keep every scanner out of the secrets dir. trivy's
# --skip-dirs does too, but not inside a git work tree holding that dir (it stats every
# tracked file through go-git); gitleaks/trufflehog may read files before filtering paths.
unsafe_for_secrets() {
  local name=$1 kind=$2
  [[ $name == heuristic || $kind:$name == staged:trivy ]] && return 1
  overlaps_secrets_repo "$SCOPE" && return 0
  [[ $name != trivy ]] && holds_secrets "$SCOPE"
}

usable() {
  local name=$1 kind=$2
  [[ " ${CAPABLE[$name]} " == *" $kind "* ]] || return 1
  installed "$name" "$kind" || return 1
  ! unsafe_for_secrets "$name" "$kind"
}

pick_scanner() {
  local kind=$1 name
  for name in "${SCANNERS[@]}"; do
    usable "$name" "$kind" && printf '%s\n' "$name" && return 0
  done
  die "no scanner available for $kind (need rg, trivy, gitleaks or trufflehog)"
}

# Runs a scanner with its stderr kept aside; on failure prints a sanitized tail and exits 2.
run_tool() {
  local name=$1 status=0
  shift
  "$@" 2>"$TMP/$name.err" || status=$?
  ((status == 0)) && return 0
  printf 'scan.sh: %s failed (exit %d):\n' "$name" "$status" >&2
  tail -n 5 "$TMP/$name.err" | jq -Rr "$JQ_LIB sanitize" >&2
  exit 2
}

emit() {
  jq -c "$@" >>"$TMP/findings.jsonl"
}

trivy_skips() {
  local entry
  printf '%s\n' --skip-dirs "$SECRETS_DIR" --skip-dirs "$SECRETS_REAL"
  [[ -d $SCOPE ]] || return 0
  printf '%s\n' --skip-dirs "$SCOPE/.git"
  [[ -n $TOP ]] || return 0
  while IFS= read -r -d '' entry; do
    [[ $entry == */ ]] && printf '%s\n' --skip-dirs "$SCOPE/${entry%/}" && continue
    printf '%s\n' --skip-files "$SCOPE/$entry"
  done < <(git -C "$SCOPE" ls-files -z -o -i --exclude-standard --directory -- . 2>/dev/null)
}

trivy_findings() {
  local report=$1 prefix=$2 where=$3
  emit --arg prefix "$prefix" --arg where "$where" "$JQ_LIB"'
    .Results[]? | .Target as $t | .Secrets[]?
    | {type: .Title, rule: .RuleID, severity: .Severity, file: ($prefix + $t), line: .StartLine,
       preview: (.Match // "" | sanitize), where: $where, commit: null, scanner: "trivy"}' "$report"
}

scan_trivy_worktree() {
  local -a skips
  local prefix=""
  mapfile -t skips < <(trivy_skips)
  run_tool trivy trivy fs --scanners secret --format json --quiet "${skips[@]}" \
    --output "$TMP/trivy.json" "$SCOPE"
  [[ -z $TOP || $REL == . ]] || prefix="$REL/"
  [[ -d $SCOPE ]] || prefix=${prefix%"${SCOPE##*/}/"}
  trivy_findings "$TMP/trivy.json" "$prefix" worktree
}

# trivy has no staged mode: export the staged blobs and scan those.
scan_trivy_staged() {
  local file
  mkdir -p "$TMP/staged"
  while IFS= read -r -d '' file; do
    mkdir -p "$TMP/staged/$(dirname -- "$file")"
    git -C "$TOP" cat-file blob ":$file" >"$TMP/staged/$file" 2>/dev/null || true
  done < <(git -C "$TOP" diff --cached --name-only -z --diff-filter=ACMR -- "${PATHSPEC[@]}")
  run_tool trivy trivy fs --scanners secret --format json --quiet --output "$TMP/trivy.json" \
    "$TMP/staged"
  trivy_findings "$TMP/trivy.json" "" staged
}

glob_escape() {
  local s=$1 c
  for c in "\\" '*' '?' '[' ']' '{' '}'; do
    s=${s//"$c"/\\$c}
  done
  printf '%s' "$s"
}

# Absolute paths + cwd=/ make rg match the anchored secrets globs against full paths.
scan_heuristic_worktree() {
  (cd / && rg --json --hidden --no-messages --max-filesize 5M -i -e "$PREFILTER" -g '!.git' \
    -g "!$(glob_escape "$SECRETS_DIR")" -g "!$(glob_escape "$SECRETS_REAL")" -- "$SCOPE") \
    >"$TMP/rg.json" || true
  emit --arg base "$BASE" --arg only "$HEURISTIC_ONLY" "$JQ_LIB"'
    select(.type == "match")
    | {file: (.data.path.text // empty | rel($base)), line: .data.line_number,
       text: (.data.lines.text // empty), commit: null}
    | classify("worktree")' "$TMP/rg.json"
}

heuristic_diff() {
  local where=$1
  shift
  if ! git -C "$TOP" -c core.quotePath=false "$@" -U0 --no-color --no-ext-diff --no-renames \
    --src-prefix=a/ --dst-prefix=b/ -- "${PATHSPEC[@]}" |
    awk -v prefilter="$PREFILTER" "$DIFF_AWK" >"$TMP/diff.tsv"; then
    die "git $1 failed while scanning $where"
  fi
  emit -R --arg where "$where" --arg only "$HEURISTIC_ONLY" "$JQ_LIB"'
    split("\t")
    | {commit: (.[0] | select(. != "") // null), file: .[1], line: (.[2] | tonumber),
       text: (.[3:] | join("\t"))}
    | classify($where)' "$TMP/diff.tsv"
}

scan_heuristic_staged() {
  heuristic_diff staged diff --cached
}

scan_heuristic_history() {
  heuristic_diff history log --all -p --format='commit %H'
}

gitleaks_modern() {
  gitleaks dir --help >/dev/null 2>&1
}

# gitleaks JSON report: [{RuleID, Description, File, StartLine, Secret, Commit, ...}].
gitleaks_findings() {
  emit --arg base "$BASE" --arg where "$1" "$JQ_LIB"'
    .[]
    | {type: .Description, rule: .RuleID, severity: null, file: (.File | rel($base)),
       line: .StartLine, preview: (.Secret // "" | mask), where: $where,
       commit: (.Commit // "" | select(. != "") // null), scanner: "gitleaks"}' "$TMP/gitleaks.json"
}

gitleaks_args() {
  printf '%s\n' --report-format json --report-path "$TMP/gitleaks.json" --exit-code 0 \
    --no-banner --log-level error
}

scan_gitleaks_worktree() {
  local -a args
  mapfile -t args < <(gitleaks_args)
  if gitleaks_modern; then
    run_tool gitleaks gitleaks dir "${args[@]}" "$SCOPE"
  else
    run_tool gitleaks gitleaks detect --no-git --source "$SCOPE" "${args[@]}"
  fi
  gitleaks_findings worktree
}

scan_gitleaks_staged() {
  local -a args
  mapfile -t args < <(gitleaks_args)
  if gitleaks_modern; then
    run_tool gitleaks gitleaks git --staged "${args[@]}" "$TOP"
  else
    run_tool gitleaks gitleaks protect --staged --source "$TOP" "${args[@]}"
  fi
  gitleaks_findings staged
}

scan_gitleaks_history() {
  local -a args
  mapfile -t args < <(gitleaks_args)
  args+=("--log-opts=--all -- ${PATHSPEC[*]}")
  if gitleaks_modern; then
    run_tool gitleaks gitleaks git "${args[@]}" "$TOP"
  else
    run_tool gitleaks gitleaks detect --source "$TOP" "${args[@]}"
  fi
  gitleaks_findings history
}

# trufflehog --json: one object per line with SourceMetadata.Data.{Filesystem,Git}, Raw, Verified.
trufflehog_findings() {
  emit -R --arg base "$BASE" --arg where "$1" "$JQ_LIB"'
    fromjson? | select(.SourceMetadata?)
    | (.SourceMetadata.Data | .Filesystem // .Git // {}) as $src
    | {type: .DetectorName, rule: (.DetectorName | ascii_downcase),
       severity: (if .Verified then "CRITICAL" else null end),
       file: ($src.file // "" | rel($base)),
       line: $src.line, preview: (.Raw // "" | mask), where: $where,
       commit: $src.commit, scanner: "trufflehog", verified: .Verified}' "$TMP/trufflehog.jsonl"
}

scan_trufflehog_worktree() {
  printf '%s\n' '(^|/)\.git/' >"$TMP/trufflehog-exclude"
  run_tool trufflehog trufflehog filesystem "$SCOPE" --json --no-update \
    --exclude-paths "$TMP/trufflehog-exclude" >"$TMP/trufflehog.jsonl"
  trufflehog_findings worktree
}

scan_trufflehog_history() {
  run_tool trufflehog trufflehog git "file://$TOP" --json --no-update >"$TMP/trufflehog.jsonl"
  trufflehog_findings history
}

# Filesystem scanners that don't read .gitignore: drop findings in ignored files.
drop_ignored() {
  local ignored
  [[ -n $TOP && -s $TMP/findings.jsonl ]] || return 0
  ignored=$(jq -r 'select(.where == "worktree") | .file' "$TMP/findings.jsonl" | sort -u |
    git -C "$TOP" check-ignore --stdin 2>/dev/null || true)
  [[ -n $ignored ]] || return 0
  jq -c --arg ignored "$ignored" '($ignored | split("\n")) as $skip
    | select(.where != "worktree" or (.file | IN($skip[]) | not))' \
    "$TMP/findings.jsonl" >"$TMP/kept.jsonl"
  mv "$TMP/kept.jsonl" "$TMP/findings.jsonl"
}

scan_kind() {
  local kind=$1 scanner
  scanner=$(pick_scanner "$kind")
  USED[$kind]=$scanner
  "scan_${scanner}_${kind}"
  [[ $kind == worktree && $scanner =~ ^(gitleaks|trufflehog)$ ]] && drop_ignored
  supplement_assignments "$kind" "$scanner"
  return 0
}

# trivy and trufflehog have no generic rule for `password = "..."`-style assignments (gitleaks
# does), so the heuristic adds just that rule on top of them.
supplement_assignments() {
  local kind=$1 scanner=$2
  [[ $scanner == trivy || $scanner == trufflehog ]] || return 0
  usable heuristic "$kind" || return 0
  HEURISTIC_ONLY=secret-assignment
  "scan_heuristic_${kind}"
  HEURISTIC_ONLY=""
  USED[$kind]="$scanner+assignments"
}

# NUL-separated path list on stdin -> [{path, where}].
name_list() {
  jq -Rsc --arg where "$1" 'split("\u0000") | map(select(. != "") | {path: ., where: $where})'
}

sensitive_files() {
  [[ -n $TOP ]] || {
    echo '[]'
    return 0
  }
  {
    if [[ $MODE == staged ]]; then
      git -C "$TOP" diff --cached --name-only -z --diff-filter=ACMR -- "${PATHSPEC[@]}" |
        name_list staged
    else
      git -C "$TOP" ls-files -z -- "${PATHSPEC[@]}" | name_list tracked
    fi
    if [[ $MODE == history ]]; then
      git -C "$TOP" log --all --name-only --format= -z -- "${PATHSPEC[@]}" | name_list history
    fi
  } | jq -sc '
    def sensitive: split("/")[-1]
      | test("^(?:\\.env|\\.env\\.(?!example$|sample$|template$|dist$).+|.*\\.pem|.*\\.key|.*\\.p12|id_rsa(?!.*\\.pub$).*|.*credentials.*\\.json|.*service[-_ ]?account.*\\.json)$"; "i");
    (.[0] | map(.path)) as $current
    | .[0] + ((.[1] // []) | map(select(.path | IN($current[]) | not)))
    | map(select(.path | sensitive)) | unique_by(.path)
    | sort_by(.where != "history", .path)'
}

vuln_trivy() {
  local -a skips=(--skip-dirs "$SECRETS_DIR" --skip-dirs "$SECRETS_REAL")
  trivy fs --scanners vuln,misconfig --format json --quiet "${skips[@]}" \
    --output "$TMP/vuln-trivy.json" "$1" 2>"$TMP/vuln-trivy.err"
}

vuln_npm() {
  (cd "$1" && npm audit --json) >"$TMP/vuln-npm.json" 2>"$TMP/vuln-npm.err"
}

vuln_cargo() {
  cargo audit --json --file "$1/Cargo.lock" >"$TMP/vuln-cargo.json" 2>"$TMP/vuln-cargo.err"
}

vuln_skip() {
  jq -nc --arg tool "$1" --arg reason "$2" '{tool: $tool, status: "skipped", reason: $reason}' \
    >"$TMP/vuln-$1.summary"
}

summarize_vuln() {
  local tool=$1
  local -A filters=(
    [trivy]='
      [.Results[]? | .Target as $t | .Vulnerabilities[]?
        | {id: .VulnerabilityID, pkg: .PkgName, installed: .InstalledVersion,
           fixed: .FixedVersion, severity: .Severity, target: $t}] as $v
      | [.Results[]? | .Target as $t | .Misconfigurations[]? | select(.Status == "FAIL")
        | {id: (.AVDID // .ID), title: .Title, severity: .Severity, target: $t}] as $m
      | {vulnerabilities: {total: ($v | length), counts: ($v | group_by(.severity)
           | map({key: .[0].severity, value: length}) | from_entries),
           top: ($v | sort_by(.severity | rank) | .[:10])},
         misconfigurations: {total: ($m | length), counts: ($m | group_by(.severity)
           | map({key: .[0].severity, value: length}) | from_entries),
           top: ($m | sort_by(.severity | rank) | .[:10])},
         total: (($v | length) + ($m | length))}'
    [npm]='
      if .error then {status: "error", message: (.error.summary // "npm audit failed" | sanitize)}
      else {counts: .metadata.vulnerabilities, total: .metadata.vulnerabilities.total,
         top: ([.vulnerabilities // {} | to_entries[]
           | {pkg: .key, severity: .value.severity, range: .value.range,
              fix: (.value.fixAvailable | if type == "object" then "\(.name)@\(.version)"
                    else . end)}] | sort_by(.severity | rank) | .[:10])} end'
    [cargo]='
      {total: .vulnerabilities.count,
       top: [.vulnerabilities.list[]? | {id: .advisory.id, pkg: .advisory.package,
         title: .advisory.title, patched: .versions.patched}][:10],
       warnings: (.warnings // {} | map_values(length))}'
  )
  [[ -s $TMP/vuln-$tool.summary ]] && return 0
  if jq -c --arg tool "$tool" "$JQ_LIB"'{tool: $tool, status: "ok"} + ('"${filters[$tool]}"')' \
    "$TMP/vuln-$tool.json" >"$TMP/vuln-$tool.summary" 2>/dev/null; then
    return 0
  fi
  jq -nc --arg tool "$tool" --rawfile err "$TMP/vuln-$tool.err" "$JQ_LIB"'
    {tool: $tool, status: "error", message: ($err | split("\n") | map(select(. != ""))
      | .[-3:] | join(" | ") | sanitize)}' >"$TMP/vuln-$tool.summary"
}

vuln_pass() {
  local dir=${TOP:-$BASE} tool lock
  local -A pids=()
  touch "$TMP/vuln-trivy.err" "$TMP/vuln-npm.err" "$TMP/vuln-cargo.err"
  if ! command -v trivy >/dev/null; then
    vuln_skip trivy "trivy not installed"
  elif overlaps_secrets_repo "$dir"; then
    vuln_skip trivy "this work tree holds $SECRETS_DIR"
  else
    vuln_trivy "$dir" &
    pids[trivy]=$!
  fi
  if [[ -f $dir/package-lock.json || -f $dir/npm-shrinkwrap.json ]] && command -v npm >/dev/null; then
    vuln_npm "$dir" &
    pids[npm]=$!
  else
    for lock in yarn.lock pnpm-lock.yaml bun.lock bun.lockb; do
      [[ -f $dir/$lock ]] && vuln_skip npm "npm audit needs package-lock.json; trivy covers $lock"
    done
  fi
  if [[ -f $dir/Cargo.lock ]]; then
    if cargo audit --version >/dev/null 2>&1; then
      vuln_cargo "$dir" &
      pids[cargo]=$!
    else
      vuln_skip cargo "cargo-audit not installed; trivy covers Cargo.lock"
    fi
  fi
  for tool in "${!pids[@]}"; do
    wait "${pids[$tool]}" || true
  done
  for tool in trivy npm cargo; do
    [[ -n ${pids[$tool]:-} ]] && summarize_vuln "$tool"
  done
  cat "$TMP"/vuln-*.summary 2>/dev/null | jq -sc '.'
}

render() {
  local sensitive=$1 vuln=$2 scanners
  scanners=$(for kind in "${!USED[@]}"; do printf '%s\t%s\n' "$kind" "${USED[$kind]}"; done |
    jq -Rsc 'split("\n") | map(select(. != "") | split("\t") | {key: .[0], value: .[1]})
      | from_entries')
  jq -nc --slurpfile findings "$TMP/findings.jsonl" --argjson sensitive "$sensitive" \
    --argjson vuln "$vuln" --argjson scanners "$scanners" --arg mode "$MODE" \
    --arg target "$SCOPE" --arg repo "$TOP" --arg rel "$REL" "$JQ_LIB"'
    def where_rank: {history: 0, staged: 1, worktree: 2}[.];
    # gitleaks --staged and trufflehog git take no pathspec: narrow to the path here.
    def in_scope: $rel == "" or $rel == "." or .file == $rel or (.file | startswith($rel + "/"));
    # One finding per place and value (most severe rule wins); history repeats a secret
    # across commits and shifted lines, so there it is one per file and value.
    ($findings | map(select(in_scope)) | sort_by(.severity // "" | rank)
      | unique_by([.where, .file, (if .where == "history" then null else .line end), .preview])
      | sort_by((.severity // "" | rank), (.where | where_rank), .file, .line)) as $f
    | {mode: $mode, target: $target, repo: (if $repo == "" then null else $repo end),
       scanners: $scanners, heuristic: ($scanners | any(. == "heuristic")),
       findings: $f, sensitive_files: $sensitive, vuln: $vuln,
       summary: {secrets: ($f | length), sensitive_files: ($sensitive | length),
         vuln: (if $vuln == null then null else ($vuln | map(.total // 0) | add // 0) end)}}'
}

main() {
  local kind sensitive vuln=null out
  local -a todo
  local -A kinds=([worktree]=worktree [path]=worktree [staged]=staged [history]="worktree history")
  parse_args "$@"
  command -v jq >/dev/null || die "jq is required"
  command -v git >/dev/null || die "git is required"
  resolve_scope
  TMP=$(mktemp -d)
  chmod 700 "$TMP"
  trap 'rm -rf "$TMP"' EXIT
  : >"$TMP/findings.jsonl"
  read -ra todo <<<"${kinds[$MODE]}"
  for kind in "${todo[@]}"; do
    scan_kind "$kind"
  done
  sensitive=$(sensitive_files)
  ((VULN == 0)) || vuln=$(vuln_pass)
  out=$(render "$sensitive" "$vuln")
  printf '%s\n' "$out"
  jq -e '.summary.secrets + .summary.sensitive_files == 0' <<<"$out" >/dev/null || return 1
}

main "$@"
