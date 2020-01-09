if [[ $TERM_PROGRAM = 'Apple_Terminal' ]] && [[ -z $INSIDE_EMACS ]]; then
  save_cwd() {
    local ttyname=`tty`;
    if [[ ! -e ~/.cwd-tty ]]; then
      echo "$ttyname	$PWD" > ~/.cwd-tty
      return
    fi

    local out=()
    local matched=0
    local LINE
    while read LINE ; do
      newline="${ttyname}	${PWD}"
      case $LINE in
        ${newline})
          return;;
        ${ttyname}"	"*)
            out+=("$newline")
            matched=1;;
        *)
          out+=("$LINE");;
      esac
    done < ~/.cwd-tty

    if [[ $matched -eq 0 ]]; then
      out+=("$ttyname	$PWD")
    fi
    IFS=$'\n'
    echo "${out[*]}" > ~/.cwd-tty
    unset IFS
  }

  if [[ -n $ZSH_VERSION ]]; then
    autoload add-zsh-hook
    add-zsh-hook precmd save_cwd
  else
    PROMPT_COMMAND="save_cwd${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
  fi
fi

