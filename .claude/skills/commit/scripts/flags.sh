#!/usr/bin/env bash
# Resolve /commit's flags deterministically (spellings, precedence, implications)
# and print them as one JSON object. Pure parsing: touches nothing.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: flags.sh [args...]

Tokens may come in any order, several per argument, case-insensitive, with an
optional leading - or --. Spellings:
  fast:     wip quick fast          fastest:  fastest quickest
  detailed: detailed                verbose:  verbose
  push      pr      merge           force:    force force-merge

Prints: {"speed","message","push","pr","merge","force","unknown_tokens":[...]}
  speed:   verbose | fastest | fast | detailed | normal
           (verbose overrides any fast split; fastest beats fast)
  message: verbose | detailed | normal (verbose beats detailed; a message flag
           wins over a fast mode for message quality)
  force => merge => pr => push. With force, merge does not wait for green.
Unknown tokens are listed, not errors (they are usually extra requests).
Exit: 0.
EOF
}

main() {
  [[ ${1:-} == -h || ${1:-} == --help ]] && usage && return 0

  local -A canonical=(
    [wip]=fast [quick]=fast [fast]=fast
    [fastest]=fastest [quickest]=fastest
    [detailed]=detailed [verbose]=verbose
    [push]=push [pr]=pr [merge]=merge
    [force]=force ["force-merge"]=force
  )
  local -A seen=()
  local unknown=() words=() arg token key
  for arg in "$@"; do
    read -ra words <<<"$arg"
    for token in "${words[@]}"; do
      key=${token,,}
      key=${key#--}
      key=${key#-}
      key=${key%%[,.;:!]}
      if [[ -n ${canonical[$key]:-} ]]; then
        seen[${canonical[$key]}]=1
        continue
      fi
      unknown+=("$token")
    done
  done

  local has_force=${seen[force]:-0}
  local has_merge=$((${seen[merge]:-0} | has_force))
  local has_pr=$((${seen[pr]:-0} | has_merge))
  local has_push=$((${seen[push]:-0} | has_pr))

  local message=normal speed=normal
  ((${seen[detailed]:-0})) && message=detailed && speed=detailed
  ((${seen[fast]:-0})) && speed=fast
  ((${seen[fastest]:-0})) && speed=fastest
  ((${seen[verbose]:-0})) && message=verbose && speed=verbose

  jq -nc --arg speed "$speed" --arg message "$message" \
    --argjson push "$has_push" --argjson pr "$has_pr" --argjson merge "$has_merge" --argjson force "$has_force" \
    '{speed: $speed, message: $message, push: ($push == 1), pr: ($pr == 1), merge: ($merge == 1),
      force: ($force == 1), unknown_tokens: $ARGS.positional}' --args "${unknown[@]}"
}

main "$@"
