function cct
    if curl -sf -m 5 -o /dev/null http://127.0.0.1:4000/v1/models
        ANTHROPIC_BASE_URL="http://127.0.0.1:4000" command claude $argv
    else
        command claude $argv
    end

    if not ss -tnp 2>/dev/null | grep -q ':4000'
        systemctl --user stop relay.service 2>/dev/null
    end
end
