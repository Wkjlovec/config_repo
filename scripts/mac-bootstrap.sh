#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.config-migration-backup/$(date +%Y%m%d-%H%M%S)"

info() {
  printf '\n==> %s\n' "$1"
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

backup_path() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR$(dirname "$target")"
    mv "$target" "$BACKUP_DIR$target"
  fi
}

link_path() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"
  backup_path "$target"
  ln -s "$source" "$target"
}

ensure_fish_shell() {
  local fish_path
  fish_path="$(command -v fish || true)"
  if [[ -z "$fish_path" ]]; then
    return
  fi

  if ! grep -qx "$fish_path" /etc/shells; then
    info "Adding fish to /etc/shells, sudo may ask for password"
    printf '%s\n' "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi

  if [[ "$SHELL" != "$fish_path" ]]; then
    info "Changing default shell to fish"
    chsh -s "$fish_path"
  fi
}

info "Using repo root: $REPO_ROOT"

ensure_homebrew

info "Installing packages from Brewfile"
brew bundle --file "$REPO_ROOT/Brewfile"

info "Linking macOS configs"
link_path "$REPO_ROOT/mac/fish/config.fish" "$HOME/.config/fish/config.fish"
link_path "$REPO_ROOT/mac/tmux/tmux.conf" "$HOME/.tmux.conf"
link_path "$REPO_ROOT/mac/nvim" "$HOME/.config/nvim"
link_path "$REPO_ROOT/mac/karabiner" "$HOME/.config/karabiner"
link_path "$REPO_ROOT/mac/hammerspoon" "$HOME/.hammerspoon"
link_path "$REPO_ROOT/mac/zed/settings.json" "$HOME/.config/zed/settings.json"

ensure_fish_shell

info "Done"
printf 'Existing configs were backed up under: %s\n' "$BACKUP_DIR"
printf 'Open Karabiner-Elements, Hammerspoon, Rectangle, Snipaste once to grant macOS permissions.\n'
