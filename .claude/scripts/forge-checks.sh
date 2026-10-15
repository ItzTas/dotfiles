#!/usr/bin/env bash
# Summarize a GitHub PR's / GitLab MR's checks and non-CI merge blockers as one
# JSON object; with --wait, poll until the state settles. Read-only: never
# merges, reruns or posts anything.
set -euo pipefail

FORGE_DETECT="$(dirname "${BASH_SOURCE[0]}")/forge-detect.sh"

usage() {
  cat <<'EOF'
Usage: forge-checks.sh <github|gitlab> <pr/mr number> [--wait] [--interval S]
                       [--timeout S] [--grace S] [-R [host/]owner/repo]

Prints one JSON object:
  {"forge","repo","number","url","state","checks":[{"name","group","status",
   "conclusion","bucket","link"}],"failing":[names],"pending":[names],
   "blockers":[{"kind","detail"}],"merge":{raw forge merge fields},
   "waited_s","timed_out"}

state:   green   every check completed OK (skipped counts as OK), nothing pending
         failed  a check failed / was cancelled / timed out
         blocked no failed check, but a non-CI blocker (conflicts, draft,
                 missing approval, changes requested, behind base, branch
                 protection, unresolved discussions, blocking manual job...)
         pending something queued/running, or mergeability still computing
         none    no checks reported at all
Checks are listed failing first, then pending, passed, skipped.

--wait      poll until state is not pending (default timeout 1800s, interval
            30s). "none" and a bare branch-protection block are also polled
            during the first --grace seconds (default 120), since a freshly
            pushed PR/MR often has no checks registered yet.
-R          repo override; default is that forge's `origin` remote, else its
            first remote, as found by forge-detect.sh.

Exit: 0 green, 1 failed or blocked, 3 still pending (at timeout, or without
--wait), 4 none, 2 error (bad args, missing CLI, API failure).
EOF
}

die() {
  echo "forge-checks: $*" >&2
  exit 2
}

# Echoes "host<TAB>slug" for the forge's origin remote, else its first remote.
detect_repo() {
  local forge=$1
  "$FORGE_DETECT" | jq -r --arg f "$forge" '.[$f] | (map(select(.remote == "origin")) + .)[0] // empty
    | "\(.host)\t\(.slug)"'
}

resolve_target() {
  local forge=$1 repo_arg=$2
  [[ -n $repo_arg ]] && split_repo_arg "$forge" "$repo_arg" && return 0
  detect_repo "$forge"
}

# Splits a -R value into "host<TAB>slug"; a first segment with a dot is a host.
split_repo_arg() {
  local forge=$1 value=$2 first=${2%%/*}
  local -A default_host=([github]=github.com [gitlab]=gitlab.com)
  [[ $first == *.* ]] && printf '%s\t%s' "$first" "${value#*/}" && return 0
  printf '%s\t%s' "${default_host[$forge]}" "$value"
}

# Shared by both forges: sort checks, derive failing/pending and the state.
# Input: {checks, blockers, transient, ...}. ($vars are jq's, not the shell's.)
# shellcheck disable=SC2016
STATE_JQ='
  def rank: {"fail": 0, "pending": 1, "pass": 2, "skip": 3}[.bucket];
  (.checks | sort_by(rank)) as $checks
  | ($checks | map(select(.bucket == "fail") | .name)) as $failing
  | ($checks | map(select(.bucket == "pending") | .name)) as $pending
  | . + {checks: $checks, failing: $failing, pending: $pending,
         blockers: (.blockers | unique_by(.kind)),
         state: (if ($failing | length) > 0 then "failed"
                 elif (.blockers | length) > 0 then "blocked"
                 elif ($pending | length) > 0 or .transient then "pending"
                 elif ($checks | length) == 0 then "none"
                 else "green" end)}
  | del(.transient)'

github_snapshot() {
  local repo=$1 number=$2 raw
  raw=$(gh pr view "$number" -R "$repo" \
    --json number,url,state,isDraft,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup) || return 1
  jq -c --arg repo "$repo" '
    def bucket: {"SUCCESS": "pass", "SKIPPED": "skip", "NEUTRAL": "skip", "ERROR": "fail",
                 "FAILURE": "fail", "CANCELLED": "fail", "TIMED_OUT": "fail",
                 "ACTION_REQUIRED": "fail", "STARTUP_FAILURE": "fail"}[.] // "pending";
    def lower_or_null: if . == null or . == "" then null else ascii_downcase end;
    def check:
      if .__typename == "StatusContext" then
        {name: .context, group: null, link: .targetUrl, started: (.startedAt // ""),
         status: (if .state == "PENDING" or .state == "EXPECTED" then "pending" else "completed" end),
         conclusion: (if .state == "PENDING" or .state == "EXPECTED" then null else (.state | ascii_downcase) end),
         bucket: (.state | bucket)}
      else
        {name, group: (.workflowName | if . == "" then null else . end), link: .detailsUrl, started: (.startedAt // ""),
         status: (.status | lower_or_null), conclusion: (.conclusion | lower_or_null),
         bucket: (if .status == "COMPLETED" then .conclusion else .status end | bucket)}
      end;
    ((.statusCheckRollup // []) | map(check) | group_by([.group, .name])
      | map(max_by(.started) | del(.started))) as $checks
    | ($checks | any(.bucket == "pending" or .bucket == "fail")) as $ci_open
    | [ (select(.state != "OPEN") | {kind: "not_open", detail: "PR is \(.state)"}),
        (select(.isDraft) | {kind: "draft", detail: "PR is a draft"}),
        (select(.mergeable == "CONFLICTING" or .mergeStateStatus == "DIRTY")
          | {kind: "conflicts", detail: "merge conflicts with the base branch"}),
        (select(.reviewDecision == "CHANGES_REQUESTED")
          | {kind: "changes_requested", detail: "a reviewer requested changes"}),
        (select(.reviewDecision == "REVIEW_REQUIRED")
          | {kind: "approval_required", detail: "required approving review missing"}),
        (select(.mergeStateStatus == "BEHIND")
          | {kind: "behind_base", detail: "branch is behind the base and must be updated"}),
        (select(.mergeStateStatus == "BLOCKED" and ($ci_open | not)
                and (.reviewDecision != "REVIEW_REQUIRED" and .reviewDecision != "CHANGES_REQUESTED"))
          | {kind: "branch_protection",
             detail: "mergeStateStatus BLOCKED: a protection rule (e.g. a required check not reported yet) blocks the merge"})
      ] as $blockers
    | {forge: "github", repo: $repo, number, url, checks: $checks, blockers: $blockers,
       transient: (.mergeable == "UNKNOWN" or .mergeStateStatus == "UNKNOWN"),
       merge: {state, isDraft, mergeable, mergeStateStatus, reviewDecision}}
  ' <<<"$raw" | jq -c "$STATE_JQ"
}

gitlab_api() {
  local host=$1 path=$2
  glab api --hostname "$host" "$path"
}

gitlab_snapshot() {
  local host=$1 slug=$2 number=$3 project mr pipeline_project pipeline_id jobs='[]'
  project=$(jq -rn --arg s "$slug" '$s | @uri')
  mr=$(gitlab_api "$host" "projects/$project/merge_requests/$number") || return 1
  pipeline_id=$(jq -r '.head_pipeline.id // empty' <<<"$mr")
  pipeline_project=$(jq -r '.head_pipeline.project_id // empty' <<<"$mr")
  if [[ -n $pipeline_id ]]; then
    jobs=$(gitlab_api "$host" "projects/${pipeline_project:-$project}/pipelines/$pipeline_id/jobs?per_page=100") || return 1
  fi
  jq -c --arg repo "$host/$slug" --argjson jobs "$jobs" '
    def finished: IN("success", "failed", "canceled", "skipped");
    def job_bucket:
      if .status == "success" then "pass"
      elif .status == "failed" then (if .allow_failure then "skip" else "fail" end)
      elif .status == "canceled" then "fail"
      elif .status == "skipped" then "skip"
      elif .status == "manual" and .allow_failure then "skip"
      else "pending" end;
    def check:
      {name, group: .stage, link: .web_url,
       status: (if (.status | finished) then "completed" else .status end),
       conclusion: (if (.status | finished) then
                      (if .status == "failed" and .allow_failure then "failed_allowed" else .status end)
                    else null end),
       bucket: job_bucket};
    def blocker_map: {
      conflict: "conflicts", need_rebase: "behind_base", draft_status: "draft",
      not_approved: "approval_required", requested_changes: "changes_requested",
      discussions_not_resolved: "unresolved_discussions", not_open: "not_open",
      blocked_status: "blocked_by_dependency", merge_request_blocked: "blocked_by_dependency",
      jira_association_missing: "jira_association_missing", title_regex: "title_check",
      locked_paths: "locked_files", locked_lfs_files: "locked_files",
      security_policy_violations: "security_policy", merge_time: "merge_time",
      commits_status: "commits_check", external_status_checks: "external_status_checks",
      broken_status: "broken"};
    def transient_statuses: ["unchecked", "checking", "preparing", "approvals_syncing", "cannot_be_merged_recheck"];
    def ci_statuses: ["mergeable", "ci_must_pass", "ci_still_running", "can_be_merged"];
    (.detailed_merge_status // (if .merge_status == "cannot_be_merged" then "conflict" else .merge_status end)) as $dms
    | (if ($jobs | length) > 0 then $jobs | map(check)
       elif .head_pipeline then [.head_pipeline | {name: "pipeline", stage: null, web_url, status, allow_failure: false} | check]
       else [] end) as $checks
    | [ (select(.state != "opened") | {kind: "not_open", detail: "MR is \(.state)"}),
        (select(.draft or .work_in_progress) | {kind: "draft", detail: "MR is a draft"}),
        (select(.has_conflicts) | {kind: "conflicts", detail: "merge conflicts with the target branch"}),
        (select($dms != null and ($dms | IN(transient_statuses[], ci_statuses[]) | not))
          | {kind: (blocker_map[$dms] // $dms), detail: "detailed_merge_status: \($dms)"}),
        ($jobs[] | select(.status == "manual" and (.allow_failure | not))
          | {kind: "manual_job", detail: "blocking manual job \(.name) must be started by hand"})
      ] as $blockers
    | {forge: "gitlab", repo: $repo, number: .iid, url: .web_url, checks: $checks,
       blockers: $blockers, transient: ($dms | IN(transient_statuses[])),
       merge: {state, draft, has_conflicts, merge_status, detailed_merge_status,
               blocking_discussions_resolved,
               pipeline: (.head_pipeline | if . then {id, status, web_url} else null end)}}
  ' <<<"$mr" | jq -c "$STATE_JQ"
}

snapshot() {
  local forge=$1 host=$2 slug=$3 number=$4
  [[ $forge == github ]] && github_snapshot "$host/$slug" "$number" && return 0
  [[ $forge == gitlab ]] && gitlab_snapshot "$host" "$slug" "$number" && return 0
  return 1
}

# True while a wait should keep polling: pending, or still settling in the grace window.
keep_waiting() {
  local json=$1 elapsed=$2 grace=$3
  jq -e --argjson in_grace "$((elapsed < grace))" '
    .state == "pending"
    or ($in_grace == 1 and (.state == "none"
        or (.state == "blocked" and all(.blockers[]; .kind == "branch_protection"))))
  ' <<<"$json" >/dev/null
}

exit_code_for() {
  local -A codes=([green]=0 [failed]=1 [blocked]=1 [pending]=3 [none]=4)
  echo "${codes[$1]:-2}"
}

main() {
  local wait=0 interval=30 timeout=1800 grace=120 repo_arg="" positional=()
  while (($#)); do
    case "$1" in
      -h | --help) usage && return 0 ;;
      --wait) wait=1 ;;
      --interval) shift && interval=${1:?--interval needs seconds} ;;
      --timeout) shift && timeout=${1:?--timeout needs seconds} ;;
      --grace) shift && grace=${1:?--grace needs seconds} ;;
      -R | --repo) shift && repo_arg=${1:?-R needs [host/]owner/repo} ;;
      -*) die "unknown flag: $1" ;;
      *) positional+=("$1") ;;
    esac
    shift
  done
  ((${#positional[@]} == 2)) || {
    usage >&2
    exit 2
  }
  local forge=${positional[0]} number=${positional[1]}
  local -A clis=([github]=gh [gitlab]=glab)
  [[ -n ${clis[$forge]:-} ]] || die "forge must be github or gitlab, got: $forge"
  [[ $number =~ ^[0-9]+$ ]] || die "PR/MR number must be numeric: $number"
  [[ "$interval $timeout $grace" =~ ^[0-9]+\ [0-9]+\ [0-9]+$ ]] || die "--interval/--timeout/--grace take whole seconds"
  command -v "${clis[$forge]}" >/dev/null || die "${clis[$forge]} is not installed"

  local target host slug
  target=$(resolve_target "$forge" "$repo_arg")
  [[ -n $target ]] || die "no $forge remote found (pass -R)"
  host=${target%%$'\t'*}
  slug=${target#*$'\t'}

  local start=$SECONDS elapsed=0 failures=0 json="" timed_out=false
  while :; do
    if ! json=$(snapshot "$forge" "$host" "$slug" "$number"); then
      failures=$((failures + 1))
      ((wait == 1 && failures < 3)) || die "could not read $forge PR/MR $number from $host/$slug"
      echo "forge-checks: API call failed, retrying (${failures}/3)" >&2
      sleep "$interval"
      continue
    fi
    failures=0
    elapsed=$((SECONDS - start))
    ((wait == 1)) || break
    keep_waiting "$json" "$elapsed" "$grace" || break
    if ((elapsed >= timeout)); then
      timed_out=true
      break
    fi
    echo "forge-checks: $(jq -r '"\(.state), \(.pending | length) pending"' <<<"$json") after ${elapsed}s; polling again in ${interval}s" >&2
    sleep "$interval"
  done

  jq -c --argjson waited "$elapsed" --argjson timed_out "$timed_out" \
    '. + {waited_s: $waited, timed_out: $timed_out}' <<<"$json"
  return "$(exit_code_for "$(jq -r .state <<<"$json")")"
}

main "$@"
