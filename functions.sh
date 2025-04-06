############################## function: search folder
function fdd {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!"
    return 1
  fi

  fd -td $* # | fzf
}

############################## function: show process
function psf {
  ps -ef |
    fzf --bind 'ctrl-r:reload(ps -ef)' \
      --header 'Press CTRL-R to reload' --header-lines=1 \
      --height=50% --layout=reverse
}

############################## function: search content of files
#
# thanks to https://github.com/junegunn/fzf/issues/2789#issuecomment-2196524694
# https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-interactive-ripgrep-launcher
function rgfzf {
  #!/usr/bin/env bash
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!"
    return 1
  fi

  # if using vscode, use the following command
  local result=$(rg --color=always --line-number --no-heading --smart-case "${*:-}" |
    fzf -d':' --ansi \
      --preview "bat -p --color=always {1} --highlight-line {2}" \
      --preview-window ~8,+{2}-5)

  # Exit if nothing selected
  [[ -z $result ]] && return 1

  local editor="${EDITOR:-nvim}"

  # Extract filename and line number
  file=$(echo "$result" | awk -F':' '{ print $1 }')
  line=$(echo "$result" | awk -F':' '{ print $2 }')

  # Launch editor depending on what's set
  if [[ $EDITOR == *"code"* ]]; then
    code -g "$file:$line"
  else
    $editor "$file" +$line
  fi
}

############################## function: search for text in files (allow alternate)
#
# fif shows the file that matched with the search, and using fzf
# allows user to see it, similar behavior to 'telescope' nvim ext.
#
# You can also open vscode in the selected line, in the end
#
#   https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-interactive-ripgrep-launcher
# thanks to https://www.reddit.com/r/commandline/comments/fu6zzp/search_file_content_with_fzf/
# thanks to https://github.com/junegunn/fzf/issues/2789#issuecomment-2196524694
function fif {
  # Switch between Ripgrep launcher mode (CTRL-R) and fzf filtering mode (CTRL-F)
  rm -f /tmp/rg-fzf-{r,f}
  local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  local INITIAL_QUERY="${*:-}"
  local result=$(fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --bind "start:reload($RG_PREFIX {q})+unbind(ctrl-r)" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(2. fzf> )+enable-search+rebind(ctrl-r)+transform-query(echo {q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f)" \
    --bind "ctrl-r:unbind(ctrl-r)+change-prompt(1. ripgrep> )+disable-search+reload($RG_PREFIX {q} || true)+rebind(change,ctrl-f)+transform-query(echo {q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r)" \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --prompt '1. ripgrep> ' \
    --delimiter : \
    --header '╱ CTRL-R (ripgrep mode) ╱ CTRL-F (fzf mode) ╱' \
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
  # --bind 'enter:become(code -g {1}:{2})+abort'

  # Exit if nothing selected
  [[ -z $result ]] && return 1

  local editor="${EDITOR:-nvim}"

  # Extract filename and line number
  file=$(echo "$result" | awk -F':' '{ print $1 }')
  line=$(echo "$result" | awk -F':' '{ print $2 }')

  # Launch editor depending on what's set
  if [[ $EDITOR == *"code"* ]]; then
    code -g "$file:$line"
  else
    $editor "$file" +$line
  fi
}
