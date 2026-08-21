function __omniroute_wait
    set -l deadline (math (date +%s) + 20)

    while test (date +%s) -lt $deadline
        __omniroute_up; and return 0
        sleep 0.2
    end

    return 1
end
