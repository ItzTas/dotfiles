function pstatus --description "Print the exit status of every stage of the last pipeline"
    set -l stages $pipestatus

    if test (count $stages) -le 1
        echo "status $stages"
        test "$stages" -eq 0
        return
    end

    set -l failed 0

    for i in (seq (count $stages))
        set -l code $stages[$i]
        set -l mark ok

        if test $code -ne 0
            set mark FAIL
            set failed 1
        end

        printf '%s  %s  %s\n' (string pad -w 3 -- $i) (string pad -w 4 -r -- $mark) $code
    end

    test $failed -eq 0
end
