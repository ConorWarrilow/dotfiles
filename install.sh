#!/usr/bin/env bash
# -------------------------------------------------------------------
# Bootstrap script for chezmoi dotfiles
#
# Run on a fresh machine with:
#   bash -c "$(curl -fsLS https://raw.githubusercontent.com/conorwarrilow/dotfiles/main/install.sh)"
#
# Or if you already have the repo cloned:
#   bash ~/dotfiles/install.sh
# -------------------------------------------------------------------
set -euo pipefail

CHEZMOI_REPO="https://github.com/ConorWarrilow/dotfiles.git"
CHEZMOI_SOURCE_PATH="chezmoi_dots"

info()    { printf '\033[1;34m[i] %s\033[0m\n' "$*"; }
success() { printf '\033[1;32m[✓] %s\033[0m\n' "$*"; }
warning() { printf '\033[1;33m[!] %s\033[0m\n' "$*"; }
error()   { printf '\033[1;31m[✖] %s\033[0m\n' "$*"; }

# -------------------------------------------------------------------
# 1. Install chezmoi if not already present
# -------------------------------------------------------------------
if ! command -v chezmoi &>/dev/null; then
  info "chezmoi not found — installing..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
  success "chezmoi installed to ~/.local/bin/chezmoi"
else
  success "chezmoi already installed: $(chezmoi --version)"
fi

# -------------------------------------------------------------------
# 2. Install zsh if not present (needed for shell setup)
# -------------------------------------------------------------------
if ! command -v zsh &>/dev/null; then
  info "Installing zsh..."
  if command -v apt-get &>/dev/null; then
    sudo apt-get install -y zsh
  elif command -v pkg &>/dev/null; then
    pkg install -y zsh
  fi
fi

# -------------------------------------------------------------------
# 3. Init and apply chezmoi
#    If the repo is already cloned locally, point chezmoi at the
#    chezmoi_dots/ subdirectory.  Otherwise, clone from GitHub.
# -------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/.chezmoi.toml.tmpl" ]]; then
  # Running from within the already-cloned repo
  info "Repo already present — initialising chezmoi from local path..."
  chezmoi init --source "$SCRIPT_DIR" --apply
else
  # Fresh machine — clone the repo and apply
  info "Cloning dotfiles from $CHEZMOI_REPO ..."
  chezmoi init --source "$HOME/.local/share/chezmoi" --apply "$CHEZMOI_REPO"
fi

success "Dotfiles applied!"
info "Run 'chezmoi diff' to see any pending changes."
info "Run 'chezmoi update' to pull latest changes and re-apply."
