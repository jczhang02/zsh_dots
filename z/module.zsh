# --- Load zprof ---
zmodload zsh/zprof

# --- Load miniconda ---
source /opt/miniconda/etc/profile.d/conda.sh

# --- Load thefuck plugin
eval $(thefuck --alias)

export MAMBA_EXE="/home/jc/.local/bin/micromamba";
export MAMBA_ROOT_PREFIX="/home/jc/.conda";

__mamba_setup="$('/home/jc/.local/bin/micromamba' shell hook --shell zsh --prefix '/home/jc/.conda' 2> /dev/null)"

eval "$__mamba_setup"

source /usr/share/nvm/init-nvm.sh
