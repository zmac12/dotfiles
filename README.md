# dotfiles

Personal macOS dotfiles for Zach McQuiston. Managed with a symlink-based install script — no extra tooling required beyond `git`.

## What's inside

| Path | Purpose |
|---|---|
| `Brewfile` | All Homebrew formulae, casks, and VS Code extensions |
| `install.sh` | Bootstrap script for a fresh Mac |
| `home/` | Files symlinked into `~/` |
| `config/starship.toml` | Starship prompt — Flexoki Tokyo Night powerline theme |
| `config/nvim/` | Neovim — Kickstart.nvim with custom plugins |
| `config/zed/` | Zed editor settings |
| `config/karabiner/` | Karabiner-Elements — caps lock ↔ escape swap |

## Fresh Mac setup

```bash
git clone git@github.com:zmac12/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

The script will:
1. Install Xcode Command Line Tools (if missing)
2. Install Homebrew and run `brew bundle`
3. Install Oh My Zsh
4. Install uv-managed Python 3.14 as the system default
5. Symlink all dotfiles (existing files are backed up to `~/.dotfiles_backup/`)
6. Create `~/.secrets.zsh` from a template
7. Set the default shell to Homebrew zsh

## Secrets

Machine-local secrets (API keys, project tokens, etc.) live in `~/.secrets.zsh`, which is sourced by `.zshrc` but never committed. A template is created on first install:

```bash
# ~/.secrets.zsh
export DJANGO_SECRET_KEY=""
export OPENAI_API_KEY=""
export AWS_PROFILE=""
```

## Python

[uv](https://docs.astral.sh/uv/) is the default Python toolchain — no pyenv, no virtualenv.

| Task | Command |
|---|---|
| Run a tool without installing | `uvx ruff check .` |
| Install a global CLI | `uv tool install ruff` |
| New project | `uv init && uv add <pkg>` |
| Virtual env | `uv venv && source .venv/bin/activate` |
| Install a different Python | `uv python install 3.12` |

## Updating

After changing a config file in `~/dotfiles`, commit and push:

```bash
cd ~/dotfiles
git add -p
git commit -m "your message"
git push
```

On another machine, pull and re-run the install (symlinks are idempotent):

```bash
cd ~/dotfiles && git pull && ./install.sh
```
