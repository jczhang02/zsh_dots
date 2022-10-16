# zsh config, managed by ZI
# JC Zhang <jczhang@live.it>

## Option: <Preset Proxy if necessary>
# export ALL_PROXY=http://127.0.0.1:9766

## Default: < Attach Tmux New Client >
### disable dolphin, emacs, kate, vscode embedded terminal to attach tmux client
if [[ -z $TMUX && $- == *i* ]]; then
    if [[ ! "$(</proc/$PPID/cmdline)" =~ "/usr/bin/(dolphin|emacs|kate)|visual-studio-code|nvim|vim" ]]; then
        exec tmux
    fi
else
    if [[ "$(</proc/$PPID/cmdline)" =~ "konsole" ]]; then
        unset TMUX TMUX_PANE
    fi
fi

## Default < Load Instant Prompt>
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## Plugin < Load ZI >
typeset -A ZI
export ZI[BIN_DIR]="${HOME}/.config/zsh/zi/bin"
### load ZI executable file
source "${ZI[BIN_DIR]}/zi.zsh"

### load ZI inter-completation support
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

## Path < Preset path >
source $HOME/.config/zsh/z/path.zsh

## Option < Preset option >
source $HOME/.config/zsh/z/option.zsh

## Plugin < Preset plugin >
source $HOME/.config/zsh/z/plugin.zsh

## Alias < preset alias>
source $HOME/.config/zsh/z/alias.zsh

## Completation < preset completions>
source $HOME/.config/zsh/z/completion.zsh

## Keys < preset shortcuts >
source $HOME/.config/zsh/z/shortcut.zsh

## Module < preset module >
source $HOME/.config/zsh/z/module.zsh

## Default < p10k prompt >
source $HOME/.config/zsh/z/p10k.zsh
zi ice depth=1
zi light romkatv/powerlevel10k
