#!/usr/bin/env bash
# Find the latest CI run(s)/pipeline for the current branch (or a given run id /
# URL) on GitHub and/or GitLab and print one JSON summary. Read-only.
set -euo pipefail

FORGE_DETECT="$HOME/.claude/scripts/forge-detect.sh"
WORK="" # scratch dir, created in main and removed on exit
CI_EVENTS='["push","pull_request","pull_request_target","merge_group","workflow_dispatch"]'

usage() {
  cat <<'EOF'
Usage: latest.sh [run/pipeline id | url] [--forge github|gitlab] [--branch B]
                 [-R [host/]owner/repo]

No id: the latest CI for the branch (default: current) on every forge remote.
  GitHub: every workflow run of the newest commit that has push/PR runs
          (falls back to any event), one per workflow+event.
  GitLab: the newest of the branch pipeline and the open MR's pipeline.
An id or a run/pipeline/job URL targets that run instead (a bare id is tried
on each forge present; a GitLab job URL resolves to its pipeline).

Prints: {"branch","state","runs":[{"forge","repo","id","url","name","title",
  "status","conclusion","state","sha","branch","event","created_at",
  "jobs":["name: result"],"failing_jobs":[{"id","name","stage","conclusion",
  "url","failed_steps"}],"allowed_failures":[names]}],"errors":[{"forge","error"}]}
state per run and overall: green | failed | pending | none.
"repo" is what to pass to failed-log.sh -R (a GitLab fork pipeline uses
host/<project id>).

Exit: 0 green, 1 failed, 3 pending, 4 no runs found, 2 error.
EOF
}

die() {
  echo "latest: $*" >&2
  exit 2
}

# Splits a -R value into "host<TAB>slug"; a first segment with a dot is a host.
split_repo_arg() {
  local forge=$1 value=$2 first=${2%%/*}
  local -A default_host=([github]=github.com [gitlab]=gitlab.com)
  [[ $first == *.* ]] && printf '%s\t%s' "$first" "${value#*/}" && return 0
  printf '%s\t%s' "${default_host[$forge]}" "$value"
}

uri() { jq -rn --arg s "$1" '$s | @uri'; }

# --- GitHub -----------------------------------------------------------------

github_run_json() {
  local repo=$1 id=$2
  gh run view "$id" -R "$repo" \
    --json databaseId,workflowName,displayTitle,status,conclusion,headSha,headBranch,event,url,createdAt,jobs
}

github_latest_ids() {
  local repo=$1 branch=$2
  gh run list -R "$repo" --branch "$branch" --limit 30 \
    --json databaseId,workflowName,event,headSha,createdAt |
    jq -r --argjson ci "$CI_EVENTS" '
      (map(select(.event | IN($ci[]))) | if length > 0 then . else null end) as $ci_runs
      | ($ci_runs // .) as $runs
      | ($runs[0].headSha // empty) as $sha
      | $runs | map(select(.headSha == $sha)) | group_by([.workflowName, .event])
      | map(max_by(.createdAt).databaseId)[]'
}

github_runs() {
  local repo=$1 branch=$2 id=$3 dir list ids=() pids=() i
  if [[ -n $id ]]; then
    ids=("$id")
  else
    list=$(github_latest_ids "$repo" "$branch") || return 1
    [[ -z $list ]] || mapfile -t ids <<<"$list"
  fi
  ((${#ids[@]})) || {
    echo '[]'
    return 0
  }
  dir=$(mktemp -d -p "$WORK")
  for i in "${!ids[@]}"; do
    github_run_json "$repo" "${ids[$i]}" >"$dir/$i.json" &
    pids+=($!)
  done
  for i in "${!pids[@]}"; do wait "${pids[$i]}" || return 1; done
  jq -s --arg repo "$repo" '
    def state: if .status != "completed" then "pending"
               elif (.conclusion | IN("success", "neutral", "skipped")) then "green"
               else "failed" end;
    def bad: IN("failure", "cancelled", "timed_out", "startup_failure", "action_required");
    map({forge: "github", repo: $repo, id: .databaseId, url, name: .workflowName,
         title: .displayTitle, status, conclusion, state: state, sha: .headSha,
         branch: .headBranch, event, created_at: .createdAt,
         jobs: [.jobs[] | "\(.name): \(.conclusion // .status)"],
         failing_jobs: [.jobs[] | select(.conclusion | bad)
           | {id: .databaseId, name, stage: null, conclusion, url,
              failed_steps: [.steps[] | select(.conclusion | bad) | .name]}],
         allowed_failures: []})' "$dir"/*.json
}

# --- GitLab -----------------------------------------------------------------

gitlab_api() { glab api --hostname "$1" "$2"; }

# Echoes the newest pipeline JSON for a branch: its own pipeline or its MR's.
gitlab_latest_pipeline() {
  local host=$1 project=$2 branch=$3 dir iid ref rc=0
  dir=$(mktemp -d -p "$WORK")
  ref=$(uri "$branch")
  gitlab_api "$host" "projects/$project/pipelines?ref=$ref&per_page=1&order_by=id&sort=desc" >"$dir/branch.json" &
  local branch_pid=$!
  echo '[]' >"$dir/mr.json"
  if gitlab_api "$host" "projects/$project/merge_requests?source_branch=$ref&state=opened&per_page=1" >"$dir/mrs.json"; then
    iid=$(jq -r '.[0].iid // empty' "$dir/mrs.json")
    [[ -z $iid ]] || gitlab_api "$host" "projects/$project/merge_requests/$iid/pipelines?per_page=1" >"$dir/mr.json" || rc=1
  else
    rc=1
  fi
  wait "$branch_pid" || return 1
  ((rc == 0)) || return 1
  jq -s 'add | max_by(.id) // empty' "$dir/branch.json" "$dir/mr.json"
}

gitlab_runs() {
  local host=$1 slug=$2 branch=$3 id=$4 project pipeline pproject jobs
  project=$(uri "$slug")
  if [[ -n $id ]]; then
    pipeline=$(gitlab_api "$host" "projects/$project/pipelines/$id") || return 1
  else
    pipeline=$(gitlab_latest_pipeline "$host" "$project" "$branch") || return 1
  fi
  [[ -n $pipeline ]] || {
    echo '[]'
    return 0
  }
  pproject=$(jq -r '.project_id // empty' <<<"$pipeline")
  jobs=$(gitlab_api "$host" "projects/${pproject:-$project}/pipelines/$(jq -r .id <<<"$pipeline")/jobs?per_page=100") || return 1
  jq -c --arg host "$host" --arg slug "$slug" --arg project "${pproject:-}" --argjson jobs "$jobs" '
    def state: if (.status | IN("success", "skipped")) then "green"
               elif (.status | IN("failed", "canceled")) then "failed"
               else "pending" end;
    (if $project != "" and ($slug | test("^[0-9]+$") | not) and (.web_url | contains("/\($slug)/-/") | not)
     then "\($host)/\($project)" else "\($host)/\($slug)" end) as $repo
    | [{forge: "gitlab", repo: $repo, id, url: .web_url, name: .name,
        title: null, status, conclusion: null, state: state, sha, branch: .ref,
        event: .source, created_at,
        jobs: [$jobs[] | "\(.name): \(.status)\(if .allow_failure and .status == "failed" then " (allowed)" else "" end)"],
        failing_jobs: [$jobs[] | select((.status == "failed" and (.allow_failure | not)) or .status == "canceled")
          | {id, name, stage, conclusion: .status, url: .web_url, failed_steps: []}],
        allowed_failures: [$jobs[] | select(.status == "failed" and .allow_failure) | .name]}]
  ' <<<"$pipeline"
}

# Resolves a GitLab job id/URL to its pipeline id.
gitlab_job_pipeline() {
  local host=$1 slug=$2 job=$3
  gitlab_api "$host" "projects/$(uri "$slug")/jobs/$job" | jq -r '.pipeline.id'
}

# --- dispatch ---------------------------------------------------------------

# Echoes "forge<TAB>host<TAB>slug<TAB>id" when the argument is a run URL.
parse_url() {
  local url=$1 host rest
  [[ $url =~ ^https?://([^/]+)/(.+)$ ]] || return 1
  host=${BASH_REMATCH[1]}
  rest=${BASH_REMATCH[2]}
  if [[ $rest =~ ^([^/]+/[^/]+)/actions/runs/([0-9]+) ]]; then
    printf 'github\t%s\t%s\t%s' "$host" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    return 0
  fi
  if [[ $rest =~ ^(.+)/-/pipelines/([0-9]+) ]]; then
    printf 'gitlab\t%s\t%s\t%s' "$host" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    return 0
  fi
  if [[ $rest =~ ^(.+)/-/jobs/([0-9]+) ]]; then
    printf 'gitlab\t%s\t%s\tjob:%s' "$host" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    return 0
  fi
  return 1
}

# Writes one forge's runs (or an error object) to $out.
query_forge() {
  local forge=$1 host=$2 slug=$3 branch=$4 id=$5 out=$6 runs
  if [[ $forge == gitlab && $id == job:* ]]; then
    id=$(gitlab_job_pipeline "$host" "$slug" "${id#job:}" 2>"$out.err") || id=""
    [[ -n $id ]] || {
      jq -n --arg e "$(cat "$out.err")" '{errors: [{forge: "gitlab", error: ("job lookup failed: " + $e)}]}' >"$out"
      return 0
    }
  fi
  if [[ $forge == github ]]; then
    runs=$(github_runs "$host/$slug" "$branch" "$id" 2>"$out.err") || runs=""
  else
    runs=$(gitlab_runs "$host" "$slug" "$branch" "$id" 2>"$out.err") || runs=""
  fi
  if [[ -z $runs ]]; then
    jq -n --arg f "$forge" --arg e "$(tail -n 3 "$out.err")" '{errors: [{forge: $f, error: $e}]}' >"$out"
    return 0
  fi
  jq -n --argjson runs "$runs" '{runs: $runs}' >"$out"
}

exit_code_for() {
  local -A codes=([green]=0 [failed]=1 [pending]=3 [none]=4 [error]=2)
  echo "${codes[$1]:-2}"
}

main() {
  local arg="" only="" branch="" repo_arg=""
  while (($#)); do
    case "$1" in
      -h | --help) usage && return 0 ;;
      --forge) shift && only=${1:?--forge needs github|gitlab} ;;
      --branch) shift && branch=${1:?--branch needs a name} ;;
      -R | --repo) shift && repo_arg=${1:?-R needs [host/]owner/repo} ;;
      -*) die "unknown flag: $1" ;;
      *)
        [[ -z $arg ]] || die "unexpected argument: $1"
        arg=$1
        ;;
    esac
    shift
  done

  local ctx targets=() id="" parsed forge
  ctx=$("$FORGE_DETECT") || exit 2
  branch=${branch:-$(jq -r '.branch // empty' <<<"$ctx")}
  if [[ $arg == http* ]]; then
    parsed=$(parse_url "$arg") || die "not a run/pipeline/job URL: $arg"
    targets=("$parsed")
  else
    [[ -z $arg || $arg =~ ^[0-9]+$ ]] || die "id must be numeric or a URL: $arg"
    id=$arg
    local target
    for forge in github gitlab; do
      [[ -z $only || $only == "$forge" ]] || continue
      if [[ -n $repo_arg ]]; then
        target=$(split_repo_arg "$forge" "$repo_arg")
      else
        target=$(jq -r --arg f "$forge" '.[$f] | (map(select(.remote == "origin")) + .)[0] // empty
          | "\(.host)\t\(.slug)"' <<<"$ctx")
      fi
      [[ -n $target ]] && targets+=("$forge"$'\t'"$target"$'\t'"$id")
    done
  fi
  ((${#targets[@]})) || die "no GitHub/GitLab remote found (pass -R or a URL)"
  [[ -n $branch || -n $id || -n $arg ]] || die "detached HEAD: pass --branch or a run id"

  local t n=0 pids=() host slug tid
  WORK=$(mktemp -d)
  trap 'rm -rf "${WORK:?}"' EXIT
  for t in "${targets[@]}"; do
    IFS=$'\t' read -r forge host slug tid <<<"$t"
    query_forge "$forge" "$host" "$slug" "$branch" "$tid" "$WORK/$n.json" &
    pids+=($!)
    n=$((n + 1))
  done
  wait "${pids[@]}"

  local out state
  out=$(jq -cs --arg branch "$branch" '
    (map(.runs // []) | add) as $runs
    | (map(.errors // []) | add) as $errors
    | {branch: $branch,
       state: (if ($runs | any(.state == "failed")) then "failed"
               elif ($runs | any(.state == "pending")) then "pending"
               elif ($runs | length) > 0 then "green"
               elif ($errors | length) > 0 then "error"
               else "none" end),
       runs: $runs, errors: $errors}' "$WORK"/[0-9]*.json)
  echo "$out"
  state=$(jq -r .state <<<"$out")
  return "$(exit_code_for "$state")"
}

main "$@"
