# option

## common options
setopt auto_cd
setopt multios
setopt auto_pushd
setopt pushd_ignore_dups
setopt listpacked
setopt interactive_comments
setopt transient_rprompt
setopt ksh_option_print
setopt rc_quotes

### glob
setopt extended_glob
setopt no_nomatch

### spell check
setopt correct

### auto slash
zstyle ':completion:*' special-dirs true
setopt autoparamslash

### select word style: smart quick delete and move
autoload -U select-word-style
select-word-style bash

### FUNCNEST
export FUNCNEST=1000

### cd
function chpwd() {
    emulate -L zsh
    exa -bh --icons 
}

