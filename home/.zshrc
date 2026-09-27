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

# ── shell enhancements ────────────────────────────────────────────────────────
[[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

command -v fzf    &>/dev/null && eval "$(fzf --zsh)"
command -v atuin  &>/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# fzf — Flexoki color scheme + fd as the backend
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="
  --color=bg:#100f0f,bg+:#282726,fg:#cecdc3,fg+:#cecdc3
  --color=hl:#4385be,hl+:#3aa99f,info:#878580,border:#575653
  --color=prompt:#3aa99f,pointer:#d14d41,marker:#879a39,spinner:#3aa99f,header:#4385be
  --height=40% --border --cycle"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

export BAT_THEME="TwoDark"
export PATH="/Library/TeX/texbin:$PATH"

# ── aliases ───────────────────────────────────────────────────────────────────
alias ls='eza --icons --git --group-directories-first'
alias ll='eza --icons --git --group-directories-first -la'
alias lt='eza --icons --tree --git-ignore -L 3'
alias cat='bat --paging=never'
alias find='fd'
alias lg='lazygit'
alias k='kubectl'
alias kctx='kubectx'
alias kns='kubens'
alias top='btm'
alias du='dust'
alias http='xh'
