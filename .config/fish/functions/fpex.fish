function fpex
    set -l lines (podman ps --format "id: {{.ID}}\t name: {{.Names}}\t img: {{.Image}}")

    set -l container (printf '%s\n' $lines | fzf --header "exec -it" \
        --preview 'echo "Status:"; podman ps -a --filter "id=$(echo "{2}" | xargs)" --format "{{.Status}}"; echo ""; echo "Command:"; podman ps -a --filter "id=$(echo "{2}" | xargs)" --format "{{.Command}}"; echo ""; echo "Logs:"; echo ""; podman logs --tail 10 {2}')

    if test -z "$container"
        return
    end

    set -l container_id (printf '%s\n' $container | awk '{print $2}' | string trim)

    podman exec -it "$container_id" bash
end
