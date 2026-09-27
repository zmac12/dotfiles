# dotfiles

Personal macOS dotfiles for Zach McQuiston. Managed with a symlink-based install script — no extra tooling required beyond `git`.

## What's inside

| Path | Purpose |
|---|---|
| `Brewfile` | All Homebrew formulae, casks, and VS Code extensions |
| `install.sh` | Bootstrap script for a fresh Mac |
| `home/` | Files symlinked into `~/` |
| `home/bin/` | Personal scripts, linked into `~/bin` (on `PATH`) — e.g. `new-ios-app` |
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

## Swift / iOS

Native app development runs from Neovim, with Xcode kept for the things only it does well
(SwiftUI previews, capabilities, signing, Instruments).

**One-time setup on a new Mac**

1. Install **Xcode** from the App Store, then:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -license accept
   xcodebuild -runFirstLaunch
   xcodebuild -downloadPlatform iOS      # simulator runtime
   ```
2. `brew bundle` installs the CLI side (Brewfile "swift / iOS" section): `xcode-build-server`,
   `xcbeautify`, `xcp`, `xcodegen`, `swiftformat`, `swiftlint`, and `pymobiledevice3`.

**New app**

```bash
new-ios-app BlockRunner          # → ~/Developer/BlockRunner, SwiftUI + Swift Testing
cd ~/Developer/BlockRunner && nvim
```

Projects are defined in `project.yml` (XcodeGen); the `.xcodeproj` is generated and not committed.
Sources use Xcode 16 synchronized folders, so new files need no project edits. Each project has a
`justfile`: `just gen | build | test | xcode | format | lint`.

**Neovim** (`config/nvim/lua/custom/plugins/swift.lua`)

| | |
|---|---|
| LSP | `sourcekit-lsp` via `xcrun` (matches the selected Xcode); `buildServer.json` from `xcode-build-server` makes it understand `.xcodeproj` |
| Build / run / test | [xcodebuild.nvim](https://github.com/wojciech-kulik/xcodebuild.nvim), loaded only inside a Swift project |
| Debug | its nvim-dap integration (lldb-dap from Xcode), sharing the kickstart dap-ui |
| Format / lint | `swiftformat` on save (conform), `swiftlint` (nvim-lint) |

Keys: `<leader>i…` for iOS (`is` setup, `ir` build & run, `ib` build, `it` test, `id` device,
`ii` all actions) and `<leader>dd` / `dt` / `dx` to debug. First time in a project: `<leader>is`.

**On a physical iPhone** (iOS 17+), debugging needs pymobiledevice3's trusted tunnel, which runs
with `sudo`; see `:h xcodebuild.remote-debugger`.

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
