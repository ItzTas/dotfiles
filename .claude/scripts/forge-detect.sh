#!/usr/bin/env bash
# Detect which forges (GitHub / GitLab) the current repo's remotes point to.
# Prints one JSON object on stdout. Read-only; never touches the network unless
# --remote-head is given.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: forge-detect.sh [--remote-head] [-C <dir>]

Classifies every git remote as github, gitlab or other and prints JSON:
  {"repo_root", "branch", "upstream", "default_branch",
   "github": [{"remote","host","slug","url"}], "gitlab": [...], "other": [...],
   "cli": {"gh": bool, "glab": bool}}

Host rules: github.com or a host containing "github" -> github; gitlab.com or a
host containing "gitlab" -> gitlab. Extra hosts can be declared with the
space-separated env vars FORGE_GITHUB_HOSTS / FORGE_GITLAB_HOSTS. SSH host
aliases (e.g. git@gh-work:o/r) are resolved with `ssh -G` (no connection).

default_branch comes from refs/remotes/<remote>/HEAD (origin first). With
--remote-head it falls back to `git ls-remote --symref` (network).

Exit: 0 ok, 2 not a git repo / bad args.
EOF
}

# Resolve an ssh alias to its real HostName; echoes the input when it isn't one.
resolve_ssh_alias() {
  local host=$1 real
  case "$host" in *.* | localhost) printf '%s' "$host" && return 0 ;; esac
  real=$(ssh -G "$host" 2>/dev/null | awk '$1 == "hostname" { print $2; exit }') || true
  printf '%s' "${real:-$host}"
}

# Echoes "host<TAB>path" for a remote URL, or nothing for a local path.
split_url() {
  local url=$1 rest host path
  url=${url%/}
  url=${url%.git}
  if [[ $url =~ ^[a-z+]+:// ]]; then
    rest=${url#*://}
    host=${rest%%/*}
    host=${host##*@}
    path=${rest#*/}
    [[ $url == ssh://* || $url == git+ssh://* ]] && host=$(resolve_ssh_alias "${host%%:*}")
    printf '%s\t%s' "${host%%:*}" "$path"
    return 0
  fi
  if [[ $url =~ ^([^@/]+@)?([^:/]+):(.+)$ ]]; then
    host=$(resolve_ssh_alias "${BASH_REMATCH[2]}")
    printf '%s\t%s' "$host" "${BASH_REMATCH[3]}"
  fi
}

classify_host() {
  local host=$1 h
  for h in github.com ${FORGE_GITHUB_HOSTS:-}; do [[ $host == "$h" ]] && echo github && return 0; done
  for h in gitlab.com ${FORGE_GITLAB_HOSTS:-}; do [[ $host == "$h" ]] && echo gitlab && return 0; done
  [[ $host == *github* ]] && echo github && return 0
  [[ $host == *gitlab* ]] && echo gitlab && return 0
  echo other
}

remote_entries() {
  local remote url split host path kind
  for remote in $(git remote); do
    url=$(git remote get-url "$remote" 2>/dev/null) || continue
    split=$(split_url "$url")
    host=${split%%$'\t'*}
    path=${split#*$'\t'}
    kind=other
    [[ -n $split ]] && kind=$(classify_host "$host")
    jq -cn --arg kind "$kind" --arg remote "$remote" --arg host "$host" --arg slug "$path" --arg raw "$url" \
      'def nonempty: if . == "" then null else . end;
       {kind: $kind, remote: $remote, host: ($host | nonempty), slug: ($slug | nonempty),
        url: (if $host != "" then "https://\($host)/\($slug)" else $raw end)}'
  done
}

default_branch() {
  local want_network=$1 remote ref
  for remote in origin $(git remote); do
    ref=$(git symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" 2>/dev/null) || continue
    printf '%s' "${ref#"$remote"/}"
    return 0
  done
  [[ $want_network == 1 ]] || return 0
  remote=$(git remote | head -n1)
  [[ -n $remote ]] || return 0
  git ls-remote --symref "$remote" HEAD 2>/dev/null | awk '/^ref:/ { sub("refs/heads/", "", $2); print $2; exit }'
}

main() {
  local want_network=0
  while (($#)); do
    case "$1" in
      -h | --help) usage && return 0 ;;
      --remote-head) want_network=1 ;;
      -C) shift && cd "${1:?-C needs a directory}" ;;
      *) echo "forge-detect: unknown argument: $1" >&2 && return 2 ;;
    esac
    shift
  done

  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "forge-detect: not inside a git repository" >&2
    return 2
  }

  remote_entries | jq -cs \
    --arg root "$root" \
    --arg branch "$(git branch --show-current)" \
    --arg upstream "$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)" \
    --arg default "$(default_branch "$want_network")" \
    --argjson gh "$(command -v gh >/dev/null && echo true || echo false)" \
    --argjson glab "$(command -v glab >/dev/null && echo true || echo false)" \
    'def nonempty: if . == "" then null else . end;
     def of(k): map(select(.kind == k) | del(.kind));
     {repo_root: $root, branch: ($branch | nonempty), upstream: ($upstream | nonempty),
      default_branch: ($default | nonempty),
      github: of("github"), gitlab: of("gitlab"), other: of("other"),
      cli: {gh: $gh, glab: $glab}}'
}

main "$@"
