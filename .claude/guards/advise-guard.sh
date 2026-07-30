#!/usr/bin/env bash
# PreToolUse hook: enforces ADVISE MODE (~/.claude/commands/advise.md). While the
# mode is active for this session, any tool call that could change state is denied.
#
# State file: $CLAUDE_CONFIG_DIR/.advise-active-<session_id>, written by
# ~/.claude/hooks/advise-tracker.sh. No flag file -> nothing is blocked.
#
# Fails open: any unexpected condition exits 0 (allow), so a broken hook can
# never wedge a session.

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
EXIT_HINT='Exit the mode with "/advise off" (or run it yourself with "! <command>").'

WRITE_TOOLS='^(Edit|MultiEdit|Write|NotebookEdit|Update|ApplyPatch|DesignSync)$'
WRITE_MCP='^mcp__.*(create|update|delete|remove|write|send|post|put|patch|deploy|restart|start|stop)'

# Whole-command exceptions: read-only invocations of otherwise mutating tools.
# Each alternative ends at the first ; & | so a chain still gets inspected.
READONLY_OVERRIDES='^[[:space:]]*(git[[:space:]]+(stash[[:space:]]+(list|show)|config[[:space:]]+(--get|--get-all|--list|-l)|remote[[:space:]]+(-v|--verbose|show)|worktree[[:space:]]+list|submodule[[:space:]]+status)|systemctl[[:space:]]+(status|show|cat|list-units|list-unit-files|list-timers|is-active|is-enabled|is-failed))[^;&|]*$'

declare -A MUTATORS=(
  ['runs with elevated privileges']='(^|[;&|(])[[:space:]]*(sudo|doas|su)([[:space:]]|$)'
  ['deletes or truncates files']='(^|[;&|(])[[:space:]]*(rm|rmdir|shred|unlink|truncate)([[:space:]]|$)'
  ['creates, moves or changes files']='(^|[;&|(])[[:space:]]*(mv|cp|ln|touch|mkdir|dd|chmod|chown|chgrp|install|tee|patch|rsync|unzip)([[:space:]]|$)'
  ['edits a file in place']='\b(sed|perl|ruby|gawk|python[0-9.]*)\b[^;&|]*[[:space:]]-i([[:space:]]|\.|$)'
  ['writes formatter or linter output back to disk']='\b(shfmt|prettier|eslint|biome|ruff|black|isort|gofmt|goimports|golangci-lint|rustfmt|clang-format|stylua|taplo)\b[^;&|]*[[:space:]](-w|-i|--write|--fix|--fix-only|--in-place)([[:space:]]|$)'
  ['mutates git state']='\bgit[[:space:]]+(commit|push|add|rm|mv|checkout|switch|restore|reset|revert|merge|rebase|cherry-pick|stash|clean|apply|am|init|clone|pull|fetch|gc|prune|worktree|submodule|config|filter-branch|update-ref|symbolic-ref|update-index|notes|replace|bisect)\b'
  ['creates, deletes or renames a git branch or remote']='\bgit[[:space:]]+(branch|remote)[[:space:]]+(-[dDmMcC]([[:space:]]|$)|--(delete|move|copy|rename|edit-description|set-url|set-head|set-branches|prune)|[^-[:space:]])'
  ['creates or deletes a git tag']='\bgit[[:space:]]+tag[[:space:]]+(-[adfs]([[:space:]]|$)|--(annotate|delete|force|sign)|[^-[:space:]])'
  ['changes JavaScript dependencies or runs a package script']='\b(npm|pnpm|yarn|bun)[[:space:]]+(i|install|ci|add|remove|rm|uninstall|update|upgrade|link|unlink|publish|run|exec|dlx|create|init|dedupe|prune|patch)\b'
  ['downloads and executes a package']='\b(npx|pnpx|bunx)\b'
  ['changes Python dependencies']='\b(pip|pip3|uv|uvx|poetry|pipx)[[:space:]]+(install|uninstall|add|remove|sync|lock|update|upgrade|run|build|publish|init|venv)\b'
  ['builds or changes Rust dependencies']='\bcargo[[:space:]]+(build|b|run|r|install|uninstall|add|remove|update|fix|clean|publish|package|fmt|generate-lockfile|test|t|bench)\b'
  ['builds, tests or changes Go dependencies']='\bgo[[:space:]]+(build|install|get|mod|run|generate|clean|work|fmt|test|tool|vet)\b'
  ['installs software or changes pinned tool versions']='(^|[;&|(])[[:space:]]*(apt|apt-get|aptitude|pacman|yay|paru|dnf|yum|zypper|brew|snap|flatpak|nix-env|gem|bundle|composer|proto|mise|asdf|rustup)([[:space:]]|$)'
  ['runs a build or test runner, which writes caches and artifacts']='(^|[;&|(])[[:space:]]*(make|cmake|ninja|gradle|gradlew|\./gradlew|mvn|just|task|tox|nox|pytest|jest|vitest|mocha|phpunit|rspec|dotnet|tsc|webpack|vite|next|turbo|nx)([[:space:]]|$)'
  ['mutates containers or cluster state']='\b(docker|podman|nerdctl|docker-compose|kubectl|helm)[[:space:]]+(compose[[:space:]]+)?(run|build|rm|start|stop|restart|kill|exec|create|prune|push|pull|commit|tag|save|load|import|cp|up|down|apply|delete|patch|scale|rollout|edit|annotate|label|drain|taint|install|upgrade|uninstall)\b'
  ['changes services, processes or system configuration']='(^|[;&|(])[[:space:]]*(systemctl|service|launchctl|kill|pkill|killall|shutdown|reboot|crontab|mount|umount|iptables|nft|ufw)([[:space:]]|$)'
  ['downloads a file to disk']='(^|[;&|(])[[:space:]]*(wget|scp|sftp|ftp)([[:space:]]|$)|\bcurl\b[^;&|]*[[:space:]]-(o|O|-output|-remote-name)([[:space:]]|$)'
  ['opens an editor']='(^|[;&|(])[[:space:]]*(vi|vim|nvim|nano|emacs|ed|gedit|code)([[:space:]]|$)'
  ['writes to GitHub (PRs, issues, releases, secrets)']='\bgh[[:space:]]+(pr[[:space:]]+(create|merge|close|edit|review|comment|ready|reopen)|issue[[:space:]]+(create|close|edit|comment|reopen|delete)|repo[[:space:]]+(create|clone|delete|edit|fork|sync)|release[[:space:]]+(create|delete|edit|upload)|workflow[[:space:]]+(run|enable|disable)|run[[:space:]]+(rerun|cancel|delete)|secret|variable|gist[[:space:]]+create|api[^;&|]*(-X|--method)[[:space:]]*(POST|PUT|PATCH|DELETE))\b'
  ['writes to GitLab (MRs, issues, releases)']='\bglab[[:space:]]+(mr|issue|release|repo|ci)[[:space:]]+(create|merge|close|update|delete|approve|note|retry|run)\b'
)

json_string() {
  printf '%s' "$1" | jq -Rs . 2>/dev/null
}

deny() {
  local escaped
  escaped=$(json_string "$1")
  [ -n "$escaped" ] || escaped='"ADVISE MODE is active: writes are blocked."'
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' "$escaped"
  exit 0
}

mode_active() {
  local file="$CONFIG_DIR/.advise-active-$1" state
  [ -n "$1" ] || return 1
  [ -L "$file" ] && return 1
  [ -f "$file" ] || return 1
  state=$(head -c 16 "$file" 2>/dev/null | tr -cd '[:lower:]')
  [ "$state" = "active" ]
}

# True when the command redirects into a file. /dev/* targets and fd dups are
# stripped first so "2>/dev/null" and "2>&1" stay allowed.
writes_redirect() {
  local cmd
  cmd=$(printf '%s' "$1" | sed -E 's@[0-9]*>>?[[:space:]]*/dev/(null|stdout|stderr|fd/[0-9]+)@@g; s/[0-9]*>&[0-9-]//g') || return 1
  printf '%s' "$cmd" | grep -Eq '(^|[^-=<>&|!])[0-9]*>>?[[:space:]]*[^&|>[:space:]]'
}

check_bash() {
  local cmd=$1 reason
  printf '%s' "$cmd" | grep -Eq "$READONLY_OVERRIDES" && return 0

  for reason in "${!MUTATORS[@]}"; do
    printf '%s' "$cmd" | grep -Eq "${MUTATORS[$reason]}" || continue
    deny "ADVISE MODE is active (read-only): blocked because this command $reason. Report what you would run and why instead of running it. $EXIT_HINT"
  done

  writes_redirect "$cmd" || return 0
  deny "ADVISE MODE is active (read-only): blocked because this command redirects output into a file. Keep the analysis in the conversation. $EXIT_HINT"
}

main() {
  local input session tool command
  input=$(cat) || exit 0
  session=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9-')
  mode_active "$session" || exit 0

  tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)
  [ -n "$tool" ] || exit 0

  printf '%s' "$tool" | grep -Eq "$WRITE_TOOLS" &&
    deny "ADVISE MODE is active (read-only): $tool cannot be used. Describe the change in words — which file, which function, what changes — instead of making it. $EXIT_HINT"
  printf '%s' "$tool" | grep -Eiq "$WRITE_MCP" &&
    deny "ADVISE MODE is active (read-only): $tool looks like a write operation. Use read-only tools only. $EXIT_HINT"

  [ "$tool" = "Bash" ] || exit 0
  command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
  [ -n "$command" ] || exit 0
  check_bash "$command"
}

main
exit 0
