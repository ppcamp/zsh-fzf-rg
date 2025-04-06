############################## fzf config
# See below how to search using fzf
# https://junegunn.github.io/fzf/search-syntax/#multiple-search-terms
# https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings
# https://vitormv.github.io/fzf-themes/
# ~/.fzf/shell/key-bindings.zsh or `fzf --zsh`
# https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-interactive-ripgrep-launcher
#
# export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_DEFAULT_COMMAND="fd --type file --max-depth=10" # --hidden
export FZF_DEFAULT_OPTS="
  --color header:bold
  --cycle
  --multi
  --height 90%
  --reverse
  --info=right
  --header '| ctrl+s (change sort order) | tab (un/select items) | ctrl+/ (change view) |'
  --bind 'ctrl-s:toggle-sort'
  --bind 'ctrl-/:change-preview-window(right,70%|down,99%,border-horizontal|hidden|right)'"
# Note that FZF doesn't support funcitions or aliases, therefore it requires a command
export FZF_CTRL_R_OPTS="
  --header '| ctrl+s (change sort order) | ctrl+y (copy) |'
  --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'
  --bind 'ctrl-r:down,alt-r:up'
  --bind 'ctrl-y:execute(echo -n {2..} | xclip -selection clipboard)+abort'"
#
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --bind 'f1:execute(less -f {})'
  --preview 'bat -n --color=always {}'"
#
export FZF_ALT_C_COMMAND="fd --type directory --max-depth=10 ."
export FZF_ALT_C_OPTS="
  --header '| ctrl+s (change sort order) | ctrl+/ (change view) |'
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'" # requires "tree" to be installed
# --preview 'eza --tree {}'" # requires "tree" to be installed
