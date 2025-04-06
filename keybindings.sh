############################# Keybinding alternative
zle -N fif         # define the widget to use the keybinding
bindkey -r '^p'    # remove previous keybinding
bindkey '^p' 'fif' # bind Ctrl+P to search
