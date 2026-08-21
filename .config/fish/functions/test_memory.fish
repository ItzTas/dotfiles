function test_memory
    set -l memory "$argv[1]"

    if test -z "$memory"
        echo "usage test_memory <num>G"
        return
    end

    head -c "$memory" </dev/zero | tail
end
