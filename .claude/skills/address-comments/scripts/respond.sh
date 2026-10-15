#!/usr/bin/env bash
# Post a reply to one review thread and/or resolve it, on GitHub or GitLab.
# This one DOES write to the forge: run it only for a thread the user confirmed.
# --dry-run prints the requests instead of sending them.
set -euo pipefail

FORGE_DETECT="$HOME/.claude/scripts/forge-detect.sh"

usage() {
  cat <<'EOF'
Usage: respond.sh <github|gitlab> <thread id> [--reply "<text>"] [--resolve]
                  [--mr <number>] [-R [host/]owner/repo] [--dry-run]

Outward-facing: run it only after the user confirmed this thread's reply.
  GitHub: thread id = review-thread node id (PRRT_…); reply via
          addPullRequestReviewThreadReply, resolve via resolveReviewThread.
  GitLab: thread id = discussion id, plus --mr <MR number>; reply via
          POST …/discussions/<id>/notes, resolve via PUT …?resolved=true.
At least one of --reply / --resolve. The reply is sent first; if it fails,
nothing is resolved. --dry-run prints the requests and sends nothing.

Prints: {"forge","thread","replied":{"url"}|null,"resolved":bool}
   or   {"dry_run":true,"forge","thread","requests":[...]}
Exit: 0 ok, 2 bad args / API error.
EOF
}

die() {
  echo "respond: $*" >&2
  exit 2
}

split_repo_arg() {
  local forge=$1 value=$2 first=${2%%/*}
  local -A default_host=([github]=github.com [gitlab]=gitlab.com)
  [[ $first == *.* ]] && printf '%s\t%s' "$first" "${value#*/}" && return 0
  printf '%s\t%s' "${default_host[$forge]}" "$value"
}

resolve_target() {
  local forge=$1 repo_arg=$2
  [[ -n $repo_arg ]] && split_repo_arg "$forge" "$repo_arg" && return 0
  "$FORGE_DETECT" | jq -r --arg f "$forge" '.[$f] | (map(select(.remote == "origin")) + .)[0] // empty
    | "\(.host)\t\(.slug)"'
}

# GraphQL variables, not shell ones.
# shellcheck disable=SC2016
GH_REPLY='mutation($id: ID!, $body: String!) {
  addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $id, body: $body}) { comment { url } }
}'
# shellcheck disable=SC2016
GH_RESOLVE='mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { isResolved } } }'

github_reply() {
  local host=$1 id=$2 body=$3
  gh api graphql --hostname "$host" -f query="$GH_REPLY" -f id="$id" -f body="$body" |
    jq -c '{url: .data.addPullRequestReviewThreadReply.comment.url}'
}

github_resolve() {
  local host=$1 id=$2
  gh api graphql --hostname "$host" -f query="$GH_RESOLVE" -f id="$id" |
    jq -e '.data.resolveReviewThread.thread.isResolved' >/dev/null
}

gitlab_reply() {
  local host=$1 base=$2 web=$3 body=$4
  glab api --hostname "$host" -X POST "$base/notes" -f body="$body" |
    jq -c --arg web "$web" '{url: "\($web)#note_\(.id)"}'
}

gitlab_resolve() {
  local host=$1 base=$2
  glab api --hostname "$host" -X PUT "$base?resolved=true" | jq -e '.notes | any(.resolved)' >/dev/null
}

main() {
  local positional=() reply="" has_reply=0 resolve=0 mr="" repo_arg="" dry=0
  while (($#)); do
    case "$1" in
      -h | --help) usage && return 0 ;;
      --reply)
        reply=${2?--reply needs text}
        has_reply=1
        shift
        ;;
      --resolve) resolve=1 ;;
      --mr) shift && mr=${1:?--mr needs the MR number} ;;
      -R | --repo) shift && repo_arg=${1:?-R needs [host/]owner/repo} ;;
      --dry-run) dry=1 ;;
      -*) die "unknown flag: $1" ;;
      *) positional+=("$1") ;;
    esac
    shift
  done
  ((${#positional[@]} == 2)) || {
    usage >&2
    exit 2
  }
  local forge=${positional[0]} thread=${positional[1]}
  [[ $forge == github || $forge == gitlab ]] || die "forge must be github or gitlab, got: $forge"
  ((has_reply || resolve)) || die "nothing to do: pass --reply and/or --resolve"
  ((has_reply == 0)) || [[ -n ${reply//[[:space:]]/} ]] || die "--reply text is empty"
  [[ $forge == github || $mr =~ ^[0-9]+$ ]] || die "GitLab needs --mr <MR number>"

  local target host slug
  target=$(resolve_target "$forge" "$repo_arg") || true
  [[ -n $target || $forge == github ]] || die "no gitlab remote found (pass -R)"
  host=${target%%$'\t'*}
  slug=${target#*$'\t'}
  [[ -n $host ]] || host=github.com

  local base="" web=""
  if [[ $forge == gitlab ]]; then
    base="projects/$(jq -rn --arg s "$slug" '$s | @uri')/merge_requests/$mr/discussions/$thread"
    web="https://$host/$slug/-/merge_requests/$mr"
  fi

  if ((dry)); then
    jq -nc --arg forge "$forge" --arg thread "$thread" --arg host "$host" --arg base "$base" \
      --arg reply "$reply" --argjson has_reply "$has_reply" --argjson resolve "$resolve" \
      --arg q_reply "$GH_REPLY" --arg q_resolve "$GH_RESOLVE" '
      {dry_run: true, forge: $forge, thread: $thread, requests: (
        if $forge == "github" then
          [ (select($has_reply == 1) | {cmd: "gh api graphql --hostname \($host)", query: $q_reply,
                                       variables: {id: $thread, body: $reply}}),
            (select($resolve == 1) | {cmd: "gh api graphql --hostname \($host)", query: $q_resolve,
                                     variables: {id: $thread}}) ]
        else
          [ (select($has_reply == 1) | {cmd: "glab api --hostname \($host)", method: "POST",
                                       endpoint: "\($base)/notes", fields: {body: $reply}}),
            (select($resolve == 1) | {cmd: "glab api --hostname \($host)", method: "PUT",
                                     endpoint: "\($base)?resolved=true"}) ]
        end)}'
    return 0
  fi

  local replied=null resolved=false
  if ((has_reply)); then
    if [[ $forge == github ]]; then
      replied=$(github_reply "$host" "$thread" "$reply") || die "reply failed on $forge thread $thread"
    else
      replied=$(gitlab_reply "$host" "$base" "$web" "$reply") || die "reply failed on $forge thread $thread"
    fi
  fi
  if ((resolve)); then
    if [[ $forge == github ]]; then
      github_resolve "$host" "$thread" || die "resolve failed on $forge thread $thread (reply: $replied)"
    else
      gitlab_resolve "$host" "$base" || die "resolve failed on $forge thread $thread (reply: $replied)"
    fi
    resolved=true
  fi
  jq -nc --arg forge "$forge" --arg thread "$thread" --argjson replied "$replied" --argjson resolved "$resolved" \
    '{forge: $forge, thread: $thread, replied: $replied, resolved: $resolved}'
}

main "$@"
