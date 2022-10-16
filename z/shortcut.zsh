
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
bindkey "$terminfo[kcuu1]" atuin_fzf_inline_up
bindkey "$terminfo[kcud1]" atuin_fzf_inline_down
bindkey '^[[A' atuin_fzf_inline_up
bindkey '^[[B' atuin_fzf_inline_down
bindkey '^R' _atuin_search_widget
bindkey '^[r' _atuin_fzf  # Using fzf interactively
export FZF_FINDER_EDITOR_BINDKEY="^T"
export FZF_FINDER_PAGER_BINDKEY=false

bindkey -s '^o' 'nvim $(fzf)^M'


