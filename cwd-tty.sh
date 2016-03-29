if [ "$TERM_PROGRAM" = 'Apple_Terminal' ] && [ -z "$INSIDE_EMACS" ]; then
    save_cwd() {
        local ttyname=`tty`;
        if  grep $ttyname ~/.cwd-tty > /dev/null 2>&1; then
            sed -i '' -e "s:^\($ttyname	\).*:\1 $PWD:"  ~/.cwd-tty
        else
            echo "$ttyname	$PWD" >> ~/.cwd-tty
        fi
    }
    PROMPT_COMMAND="save_cwd${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi

