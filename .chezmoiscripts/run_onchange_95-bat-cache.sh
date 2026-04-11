#!/usr/bin/env bash
# Rebuild bat's theme cache whenever the themes directory changes.
# run_onchange_ means chezmoi tracks the script content hash —
# to trigger on theme file changes, the script body must reference them.
# The actual trigger is managed by naming this file run_onchange_ and
# ensuring chezmoi re-hashes it when themes change (achieved by importing
# theme files via the chezmoi template hash in the companion .tmpl version).
set -euo pipefail

BAT_CMD="bat"
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    BAT_CMD="batcat"
fi

if command -v "$BAT_CMD" &>/dev/null; then
    echo "Rebuilding bat theme cache..."
    "$BAT_CMD" cache --build
    echo "bat cache rebuilt."
fi
