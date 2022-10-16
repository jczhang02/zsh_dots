# plugin

## plugin definition
zi wait="0" lucid light-mode for \
    hlissner/zsh-autopair \
    hchbaw/zce.zsh \
    wfxr/forgit \
    jczhang02/conda-zsh-completion \

zi light-mode for \
    as="program" atclone="rm -f ^(rgg|agv)" \
        lilydjwg/search-and-view \
    atclone="dircolors -b LS_COLORS > c.zsh" atpull='%atclone' pick='c.zsh' \
        trapd00r/LS_COLORS \
    src="etc/git-extras-completion.zsh" \
        tj/git-extras

zi wait="1" lucid for \
    OMZL::clipboard.zsh \
    OMZL::git.zsh \
    OMZP::systemd/systemd.plugin.zsh \
    OMZP::git/git.plugin.zsh \
    OMZP::extract \
    OMZP::pip \

zi ice wait lucid has'fzf' pick'fzf-finder.plugin.zsh'
zi light leophys/zsh-plugin-fzf-finder

zi ice mv=":zsh -> _cht" as="completion"
zi snippet https://cheat.sh/:zsh

zi as="completion" for \
    OMZP::docker/_docker \
    OMZP::fd/_fd

zi ice as"program" pick"bin/git-fuzzy"
zi light bigH/git-fuzzy

zi ice lucid wait as'completion' blockf
zi light zchee/zsh-completions

zi ice lucid wait as'completion' blockf has'pandoc'
zi light srijanshetty/zsh-pandoc-completion

zi light Aloxaf/fzf-tab

zi ice wait lucid atinit"ZI[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay"
zi light z-shell/F-Sy-H

zi ice wait lucid atload"!_zsh_autosuggest_start"
zi load zsh-users/zsh-autosuggestions

source $HOME/.config/zsh/z/custom/atuin.zsh

zi light softmoth/zsh-vim-mode
zi light twang817/zsh-manydots-magic

## plugin options
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
zstyle ':fzf-tab:complete:kill:*' popup-pad 0 3
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always --ignore-glob="*.bbl|*.aux|*.blg|*.fdb_latexmk|*.fls|*.log|*.synctex.gz" $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
zstyle ":fzf-tab:*" fzf-flags --color=bg+:23
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*' file-sort modification
zstyle ':completion:*:exa' sort false
zstyle ':completion:files' sort false
zstyle ':fzf-tab:*:*argument-rest*' popup-pad 100 0
zstyle ':fzf-tab:*:*argument-rest*' fzf-preview

### vimmode
KEYTIMEOUT=1

### zsh autosuggest
ZSH_AUTOSUGGEST_STRATEGY=(atuin)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_COMPLETION_IGNORE='( |man |pikaur -S )*'
ZSH_AUTOSUGGEST_HISTORY_IGNORE='?(#c50,)'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="underline"

