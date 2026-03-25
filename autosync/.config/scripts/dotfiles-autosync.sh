#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
LOG_PREFIX="[dotfiles-autosync]"

notify() {
  local title="$1" body="$2"
  osascript -e "display notification \"$body\" with title \"$title\"" 2>/dev/null || true
}

log() {
  echo "$LOG_PREFIX $(date '+%Y-%m-%d %H:%M:%S') $1"
}

cd "$DOTFILES_DIR"

# Update Brewfile to capture any new brew installs
log "Dumping Brewfile..."
if ! brew bundle dump --force --file="$DOTFILES_DIR/Brewfile" 2>&1; then
  log "WARNING: brew bundle dump failed, continuing with existing Brewfile"
fi

# Stage all changes
git add -A

# Check if there are staged changes
if git diff --cached --quiet; then
  log "No changes to sync"
  notify "Dotfiles" "Dotfiles clean, nothing to sync"
  exit 0
fi

# Build commit message with changed stow package names
changed_packages=$(git diff --cached --name-only | cut -d'/' -f1 | sort -u | tr '\n' ', ' | sed 's/,$//' | sed 's/,/, /g')
file_count=$(git diff --cached --name-only | wc -l | tr -d ' ')
date_stamp=$(date '+%Y-%m-%d')
message="auto: $date_stamp ($changed_packages)"

# Commit and push
log "Committing: $message"
if ! git commit --no-gpg-sign -m "$message" 2>&1; then
  error="commit failed"
  log "ERROR: $error"
  notify "Dotfiles Sync Failed" "Dotfiles sync failed: $error"
  exit 1
fi

log "Pushing to remote..."
if ! push_output=$(git push 2>&1); then
  log "ERROR: push failed: $push_output"
  notify "Dotfiles Sync Failed" "Dotfiles sync failed: push error"
  exit 1
fi

log "Sync complete: $file_count files in $changed_packages"
notify "Dotfiles Synced" "Dotfiles synced: $file_count files in $changed_packages"
