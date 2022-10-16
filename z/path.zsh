# Preset path & export

fpath+=("XDG_CONFIG_HOME/zsh/functions")

export EDITOR="/usr/bin/nvim"
export BROWSER="/usr/bin/firefox"
export TERMINFO="/usr/share/terminfo/"

### rust mirror
export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
### go path
export GOPATH="/home/jc/.local/share/gomodule"
### better python expression
export FORCE_COLOR=1
### ranger load rc
export RANGER_LOAD_DEFAULT_RC=false
### fzf/fd default opt
export SPROMPT="%B%F{yellow}zsh: correct '%R' be '%r' [nyae]?%f%b "
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'

### paths
PATH=$HOME/.npm-global/bin:$PATH
PATH=$HOME/.local/bin:$PATH
PATH=$HOME/.cargo/bin:$PATH
PATH=$HOME/.local/share/gomodule/bin:$PATH
PATH=$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH
PATH=$HOME/.scripts/mail/:$PATH
