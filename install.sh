#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }

link() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dst#$HOME/}")"
    mv "$dst" "$BACKUP_DIR/${dst#$HOME/}"
    yellow "  backed up $(basename "$dst") → $BACKUP_DIR"
  fi
  ln -sf "$src" "$dst"
  green "  linked $dst → $src"
}

# ── 1. Xcode Command Line Tools ──────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  yellow "Installing Xcode Command Line Tools..."
  xcode-select --install
  read -rp "Press enter once the installer finishes..."
fi

# ── 2. Homebrew ──────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  yellow "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

green "Installing Homebrew packages (this may take a while)..."
brew bundle install --file="$DOTFILES/Brewfile" --no-lock

# ── 3. Oh My Zsh ─────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  yellow "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ── 4. uv default Python ─────────────────────────────────────────────────────
if command -v uv &>/dev/null; then
  if ! uv python list 2>/dev/null | grep -q 'cpython-3\.14.*python3 ->'; then
    yellow "Installing uv-managed Python 3.14..."
    uv python install --default 3.14
  fi
fi

# ── 5. Symlink home/ files ────────────────────────────────────────────────────
green "Symlinking dotfiles..."
while IFS= read -r -d '' src; do
  rel="${src#$DOTFILES/home/}"
  dst="$HOME/$rel"
  mkdir -p "$(dirname "$dst")"
  link "$src" "$dst"
done < <(find "$DOTFILES/home" -type f -print0)

# ── 6. Symlink config/ entries ────────────────────────────────────────────────
green "Symlinking ~/.config entries..."
for src in "$DOTFILES/config"/*/; do
  name="$(basename "$src")"
  dst="$HOME/.config/$name"
  link "${src%/}" "$dst"
done
# flat files directly in config/
while IFS= read -r -d '' src; do
  [[ -d "$src" ]] && continue
  rel="${src#$DOTFILES/config/}"
  dst="$HOME/.config/$rel"
  mkdir -p "$(dirname "$dst")"
  link "$src" "$dst"
done < <(find "$DOTFILES/config" -maxdepth 1 -type f -print0)

# ── 7. Secrets template ───────────────────────────────────────────────────────
if [[ ! -f "$HOME/.secrets.zsh" ]]; then
  yellow "Creating ~/.secrets.zsh template (add your project keys here, never commit this)"
  cat > "$HOME/.secrets.zsh" <<'EOF'
# Machine-local secrets — sourced by .zshrc, never committed
# export DJANGO_SECRET_KEY=""
# export OPENAI_API_KEY=""
# export AWS_PROFILE=""
EOF
fi

# ── 8. Set default shell ──────────────────────────────────────────────────────
ZSH_PATH="$(brew --prefix)/bin/zsh"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  if ! grep -qF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  chsh -s "$ZSH_PATH"
  green "Default shell set to $ZSH_PATH"
fi

green ""
green "Done! Open a new terminal to pick everything up."
[[ -d "$BACKUP_DIR" ]] && yellow "Previous files backed up to $BACKUP_DIR"
