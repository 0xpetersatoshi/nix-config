# One Password SSH Agent Config
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

export PATH="$HOME/.poetry/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Added by serverless binary installer
export PATH="$HOME/.serverless/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# dbt
export DBT_PROFILES_DIR=$HOME/.dbt
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# bun completions
[ -s "$HOME/.oh-my-zsh/completions/_bun" ] && source "$HOME/.oh-my-zsh/completions/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# wezterm
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"

# go
export PATH=$PATH:$(go env GOPATH)/bin

export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH
export PATH="/Users/peter/.local/share/solana/install/active_release/bin:$PATH"
