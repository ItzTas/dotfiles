function fdex
    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function) \
            "  picks a running docker container with fzf and opens a bash shell in it"
        return 0
    end

    for dep in docker fzf
        if not command -q $dep
            echo "$dep is not installed" >&2
            return 1
        end
    end

    set -l lines (docker ps --format "id: {{.ID}}\t name: {{.Names}}\t img: {{.Image}}")

    set -l container (printf '%s\n' $lines | fzf --header "exec -it" \
        --preview 'echo "Status:"; docker ps -a --filter "id=$(echo "{2}" | xargs)" --format "{{.Status}}"; echo ""; echo "Command:"; docker ps -a --filter "id=$(echo "{2}" | xargs)" --format "{{.Command}}"; echo ""; echo "Logs: "; echo ""; docker logs --tail 10 {2}')

    if test -z "$container"
        return
    end

    set -l container_id (printf '%s\n' $container | awk '{print $2}' | string trim)

    docker exec -it "$container_id" bash
end
