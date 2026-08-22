function fish_should_add_to_history
    set -l cmd $argv[1]

    string match -qr '^\s' -- $cmd; and return 1

    set -l noise clear ls ll la l pwd exit reset c v y
    contains -- (string trim -- $cmd) $noise; and return 1

    set -l secret_patterns \
        '(?i)[\w-]*(api[_-]?key|secret|passwd|password|token|credentials?)[\w-]*\s*[=:]' \
        '(?i)--(password|token|api[_-]?key|secret)([= ]|$)' \
        '(?i)^\s*set\s+(-\S+\s+)*[\w-]*(api[_-]?key|secret|passwd|password|token|credentials?)[\w-]*\s+\S' \
        '\bsecret-tool\s+store\b' \
        '(?i)\bauthorization:\s*(bearer|basic)\b' \
        '(?i)\b(gh|glab)\s+auth\s+login\b.*--with-token'

    for pattern in $secret_patterns
        string match -qr -- $pattern $cmd; and return 1
    end

    return 0
end
