
### ---- ZSH HOME -----------------------------------
export ZSH=$HOME/.config/zsh

### ---- autocompletions -----------------------------------
autoload -Uz compinit && compinit

### ---- load conda ---------
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/peter/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/peter/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/peter/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/peter/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/usr/local/google-cloud-sdk/path.zsh.inc' ]; then . '/usr/local/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/usr/local/google-cloud-sdk/completion.zsh.inc' ]; then . '/usr/local/google-cloud-sdk/completion.zsh.inc'; fi

### ----- Source kube-ps1 -----------------------------------
source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
PS1='$(kube_ps1)'$PS1

### ---- Source other configs -----------------------------------
[[ -f $ZSH/aliases.zsh ]] && source $ZSH/aliases.zsh
[[ -f $ZSH/exports.zsh ]] && source $ZSH/exports.zsh

### ---- Source plugins -----------------------------------
# https://github.com/zsh-users/zsh-syntax-highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# https://github.com/zsh-users/zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

### add local bin to path
export PATH=$HOME/bin:$PATH

# ngrok
if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi

### ---- kitty key bindings -----------------------------------
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line

### ---- Load Starship -----------------------------------
eval "$(starship init zsh)"
