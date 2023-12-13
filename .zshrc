
### ---- ZSH HOME -----------------------------------
export ZSH=$HOME/.config/zsh

### ---- autocompletions -----------------------------------
autoload -Uz compinit && compinit

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/usr/local/google-cloud-sdk/path.zsh.inc' ]; then . '/usr/local/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/usr/local/google-cloud-sdk/completion.zsh.inc' ]; then . '/usr/local/google-cloud-sdk/completion.zsh.inc'; fi

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

### ---- Load conda -----------------------------------
eval "$(conda "shell.$(basename "${SHELL}")" hook)"
