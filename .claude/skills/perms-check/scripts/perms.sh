#!/usr/bin/env bash
# perms-check helper: finds sensitive files and dirs with loose permissions and prints a
# JSON report. Metadata only (find + mode bits): never opens a file and never chmods.
# $HOME/.config/zsh/secrets is pruned from every walk and refused as a scope.
set -euo pipefail
shopt -s nocasematch

KEY_GLOBS=('id_rsa*' 'id_ed25519*' '*.pem' '*.key' '*.p12' '*.pfx' '*.gpg')
SECRET_GLOBS=('.env' '.env.*' '*credentials*' '.netrc' '.pgpass' '.npmrc' '.git-credentials'
  '*service?account*.json')
# Names the globs above catch that hold no secret: public keys, env templates, source code.
BENIGN_GLOBS=('*.pub' '.env.example' '.env.sample' '.env.template' '.env.dist'
  '*.go' '*.py' '*.ts' '*.tsx' '*.js' '*.jsx' '*.mjs' '*.cjs' '*.rs' '*.java' '*.kt' '*.rb'
  '*.php' '*.c' '*.h' '*.cpp' '*.cs' '*.swift' '*.md' '*.svelte' '*.vue' '*.html' '*.css')
MAX_ISSUES=200
SECRETS_DIR=$HOME/.config/zsh/secrets
SECRETS_REAL=""
declare -A IN_REPO=()

usage() {
  cat <<'EOF'
Usage: perms.sh [path]

Reports files with loose permissions under <path> (default: repo root, else cwd).
Metadata only; never reads file contents, never changes modes.

stdout: {"scope", "clean", "summary": {critical, high, medium, low},
         "issues": [{severity, type, path, mode, recommended, reason, tracked}],
         "truncated"?: N}
  issues are sorted most dangerous first (max 200 listed; summary counts all);
  path is relative to scope.
  tracked: true/false when the path is inside a git work tree, null otherwise.
Exit: 0 clean, 1 issues found, 2 usage/environment error.
EOF
}

die() {
  printf 'perms.sh: %s\n' "$1" >&2
  exit 2
}

in_secrets() {
  local path=$1 dir
  for dir in "$SECRETS_DIR" "$SECRETS_REAL"; do
    [[ $path == "$dir" || $path == "$dir"/* ]] && return 0
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

glob_escape() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\*/\\*}
  s=${s//\?/\\?}
  s=${s//\[/\\[}
  printf '%s' "$s"
}

matches_any() {
  local name=$1 glob
  shift
  for glob; do
    # shellcheck disable=SC2053 # glob match on purpose
    [[ $name == $glob ]] && return 0
  done
  return 1
}

# Sets REPLY to key, secret or other.
file_kind() {
  local name=$1
  REPLY=other
  matches_any "$name" "${BENIGN_GLOBS[@]}" && return 0
  if matches_any "$name" "${KEY_GLOBS[@]}"; then
    REPLY=key
    return 0
  fi
  matches_any "$name" "${SECRET_GLOBS[@]}" && REPLY=secret
  return 0
}

# Sets REPLY to true, false or null (not inside a git work tree).
tracked_status() {
  local path=$1 dir=${1%/*}
  dir=${dir:-/}
  if [[ -z ${IN_REPO[$dir]+set} ]]; then
    IN_REPO[$dir]=$(git -C "$dir" rev-parse --is-inside-work-tree 2>/dev/null || true)
  fi
  REPLY=null
  [[ ${IN_REPO[$dir]} == true ]] || return 0
  REPLY=false
  [[ -n $(git -C "$dir" ls-files -- ":(literal)${path##*/}" 2>/dev/null) ]] && REPLY=true
  return 0
}

add_issue() {
  local severity=$1 type=$2 mode=$3 recommended=$4 reason=$5 path=$6
  tracked_status "$path"
  printf '%s\0' "$severity" "$type" "$mode" "$recommended" "$reason" "$REPLY" "$path"
}

check_dir() {
  local mode=$1 path=$2
  (((8#$mode & 8#077) != 0)) || return 0
  add_issue high dir "$mode" 700 "${path##*/} dir accessible by group/other" "$path"
}

check_file() {
  local mode=$1 path=$2 perm severity="" recommended reason
  local -a reasons=()
  perm=$((8#$mode & 8#777))
  file_kind "${path##*/}"
  if ((perm & 8#002)); then
    severity=critical
    reasons+=("world-writable")
  fi
  case $REPLY in
    key)
      recommended=400
      if ((perm != 8#600 && perm != 8#400)); then
        severity=${severity:-high}
        reasons+=("private key not 600/400")
      fi
      ;;
    secret)
      recommended=600
      if ((perm & 8#077)); then
        severity=${severity:-medium}
        reasons+=("secret file accessible by group/other")
      fi
      ;;
    *)
      recommended=$(printf '%o' $((8#$mode & ~8#022)))
      if [[ -z $severity ]] && ((perm & 8#020)); then
        severity=low
        reasons+=("group-writable")
      fi
      ;;
  esac
  [[ -n $severity ]] || return 0
  printf -v reason '%s, ' "${reasons[@]}"
  add_issue "$severity" file "$mode" "$recommended" "${reason%, }" "$path"
}

scan() {
  local scope=$1 glob
  local -a names=()
  for glob in "${KEY_GLOBS[@]}" "${SECRET_GLOBS[@]}"; do
    ((${#names[@]} == 0)) || names+=(-o)
    names+=(-iname "$glob")
  done
  find -P "$scope" \
    \( -path "$(glob_escape "$SECRETS_DIR")" -o -path "$(glob_escape "$SECRETS_REAL")" \) -prune -o \
    \( -type d \( -name .ssh -o -name .gnupg \) -printf 'd\0%m\0%p\0' \) -o \
    \( -type f \( -perm /022 -o \( "${names[@]}" \) \) -printf 'f\0%m\0%p\0' \) || true
}

collect() {
  local type mode path
  local -A checks=([d]=check_dir [f]=check_file)
  while IFS= read -r -d '' type && IFS= read -r -d '' mode && IFS= read -r -d '' path; do
    "${checks[$type]}" "$mode" "$path"
  done < <(scan "$1")
}

render() {
  jq -Rsc --arg scope "$1" --argjson max "$MAX_ISSUES" '
    def rank: {critical: 0, high: 1, medium: 2, low: 3}[.];
    def relative: if startswith($scope + "/") then .[($scope | length) + 1:] else . end;
    (split("\u0000") | map(select(. != ""))) as $f
    | [range(0; $f | length; 7) as $i | $f[$i:$i + 7]
        | {severity: .[0], type: .[1], path: (.[6] | relative), mode: .[2],
           recommended: .[3], reason: .[4], tracked: (.[5] | fromjson)}]
    | sort_by((.severity | rank), .path) as $all
    | {scope: $scope, clean: ($all | length == 0),
       summary: (reduce $all[] as $i ({critical: 0, high: 0, medium: 0, low: 0};
         .[$i.severity] += 1)),
       issues: $all[:$max]}
    + (if ($all | length) > $max then {truncated: (($all | length) - $max)} else {} end)'
}

main() {
  local target scope out
  case ${1:-} in
    --help) usage && return 0 ;;
    -*) die "unknown flag: $1 (see --help)" ;;
  esac
  (($# <= 1)) || die "expected at most one path (see --help)"
  command -v jq >/dev/null || die "jq is required"
  SECRETS_REAL=$(realpath -m -- "$SECRETS_DIR")
  target=${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}
  scope=$(safe_resolve "$target") || die "refusing to scan inside $SECRETS_DIR"
  [[ -e $scope ]] || die "no such path: $target"
  out=$(collect "$scope" | render "$scope")
  printf '%s\n' "$out"
  jq -e '.clean' <<<"$out" >/dev/null || return 1
}

main "$@"
