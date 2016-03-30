if [ "$TERM_PROGRAM" = 'Apple_Terminal' ] && [ -z "$INSIDE_EMACS" ]; then
    save_cwd() {
        local ttyname=`tty`;
        if [[ ! -e ~/.cwd-tty ]]; then
            echo "$ttyname	$PWD" > ~/.cwd-tty
            return
        fi

        local out=()
        local matched=0
        while read LINE ; do
            IFS='	'
            LINE=($LINE)
            unset IFS
            if [[ ${LINE[0]} = $ttyname ]]; then
                out+=("${LINE[0]}	${PWD}")
                matched=1
            else
                out+=("${LINE[0]}	${LINE[1]}")
            fi
        done < ~/.cwd-tty

        if [[ $matched -eq 0 ]]; then
            out+=("$ttyname	$PWD")
        fi
        IFS=$'\n'
        echo "${out[*]}" > ~/.cwd-tty
    }
    PROMPT_COMMAND="save_cwd${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi

