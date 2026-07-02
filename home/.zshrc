export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
export PATH=$PATH:/usr/local/go/bin

COMPLETION_WAITING_DOTS="true"

plugins=(git docker docker-compose git-flow)

source $ZSH/oh-my-zsh.sh

# Secrets (never committed) — put project keys, tokens, etc. in ~/.secrets.zsh
[[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh

# added by Snowflake SnowSQL installer v1.2
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH
autoload -U +X bashcompinit && bashcompinit
[[ -f ~/.dbt-completion.bash ]] && source ~/.dbt-completion.bash

# golang
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# uv is the default Python toolchain
# ~/.local/bin holds uv-managed python/python3 shims and `uv tool` installs; keep it first.
export UV_PYTHON_PREFERENCE=managed

eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Applications/SnowSQL.app/Contents/MacOS:$HOME/bin:/usr/local/bin:$HOME/.cargo/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:$HOME/go/bin"
export MODULAR_HOME="$HOME/.modular"
export PATH="$HOME/.modular/pkg/packages.modular.com_mojo/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# tool completions (installed on-demand)
[[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"

# opencode
[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"
