
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
# thanks to https://github.com/junegunn/fzf/issues/2789#issuecomment-2196524694
# https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-interactive-ripgrep-launcher
function rgfzf {
  #!/usr/bin/env bash
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!"
    return 1
  fi

 rg --color=always --line-number --no-heading --smart-case "${*:-}" |
   fzf -d':' --ansi \
     --preview "bat -p --color=always {1} --highlight-line {2}" \
     --preview-window ~8,+{2}-5 |
   awk -F':' '{ print $1 ":" $2 }' |
   xargs -r -I {} code -g {}
}


############################## function: search for text in file
# fif shows the file that matched with the search, and using fzf
# allows user to see it, similar behavior to 'telescope' nvim ext.
#
# You can also open vscode in the selected line, in the end
#
#   https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-interactive-ripgrep-launcher
# thanks to https://www.reddit.com/r/commandline/comments/fu6zzp/search_file_content_with_fzf/
# thanks to https://github.com/junegunn/fzf/issues/2789#issuecomment-2196524694
function fif {
  # if [ ! "$#" -gt 0 ]; then
  #   echo "Need a string to search for!"
  #   return 1
  # fi
  #
  # rg --line-number --no-heading --smart-case "${*:-}" |
  #   awk -F: '{ printf "\033[1;32m%s\033[0m:\033[1;34m%s\033[0m\n", $1, $2 }' |
  #   fzf -d':' --ansi \
  #     --preview "bat -p --color=always {1} --highlight-line {2}" \
  #     --preview-window ~8,+{2}-5 |
  #   xargs -r -I {} code -g {}

  # Switch between Ripgrep launcher mode (CTRL-R) and fzf filtering mode (CTRL-F)
  rm -f /tmp/rg-fzf-{r,f}
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="${*:-}"
  fzf --ansi --disabled --query "$INITIAL_QUERY" \
      --bind "start:reload($RG_PREFIX {q})+unbind(ctrl-r)" \
      --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(2. fzf> )+enable-search+rebind(ctrl-r)+transform-query(echo {q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f)" \
      --bind "ctrl-r:unbind(ctrl-r)+change-prompt(1. ripgrep> )+disable-search+reload($RG_PREFIX {q} || true)+rebind(change,ctrl-f)+transform-query(echo {q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r)" \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --prompt '1. ripgrep> ' \
      --delimiter : \
      --header '╱ CTRL-R (ripgrep mode) ╱ CTRL-F (fzf mode) ╱' \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
      --bind 'enter:become(code -g {1}:{2})+abort'
}


############################# Keybinding alternative
zle -N fif # define the widget to use the keybinding
bindkey -r '^p' # remove previous keybinding
bindkey '^p' 'fif' # bind Ctrl+P to search