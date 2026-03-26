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

# Skip brew auto-update to avoid long delays
export HOMEBREW_NO_AUTO_UPDATE=1

# Update Brewfile to capture any new brew installs
log "Dumping Brewfile..."
if ! brew bundle dump --force --file="$DOTFILES_DIR/Brewfile" 2>&1; then
  log "WARNING: brew bundle dump failed, continuing with existing Brewfile"
fi

# Check for unpushed commits from a previous failed push
unpushed=$(git log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
if [ "$unpushed" -gt 0 ]; then
  log "Found $unpushed unpushed commit(s) from previous run"
fi

# Stage all changes
git add -A

# Check if there are staged changes
if git diff --cached --quiet && [ "$unpushed" -eq 0 ]; then
  log "No changes to sync"
  notify "Dotfiles" "Dotfiles clean, nothing to sync"
  exit 0
fi

# Commit if there are staged changes
if ! git diff --cached --quiet; then
  changed_packages=$(git diff --cached --name-only | cut -d'/' -f1 | sort -u | tr '\n' ', ' | sed 's/,$//' | sed 's/,/, /g')
  file_count=$(git diff --cached --name-only | wc -l | tr -d ' ')
  date_stamp=$(date '+%Y-%m-%d')
  message="auto: $date_stamp ($changed_packages)"

  log "Committing: $message"
  if ! git commit --no-gpg-sign -m "$message" 2>&1; then
    error="commit failed"
    log "ERROR: $error"
    notify "Dotfiles Sync Failed" "Dotfiles sync failed: $error"
    exit 1
  fi
else
  log "No new changes, pushing previously unpushed commits"
  changed_packages="(retry)"
  file_count=0
fi

# Push with retries (network may not be ready after wake)
max_retries=3
for attempt in $(seq 1 $max_retries); do
  log "Pushing to remote (attempt $attempt/$max_retries)..."
  if push_output=$(git push 2>&1); then
    break
  fi
  log "Push attempt $attempt failed: $push_output"
  if [ "$attempt" -eq "$max_retries" ]; then
    log "ERROR: push failed after $max_retries attempts"
    notify "Dotfiles Sync Failed" "Dotfiles sync failed: push error (committed locally)"
    exit 1
  fi
  sleep 30
done

log "Sync complete: $file_count files in $changed_packages"
notify "Dotfiles Synced" "Dotfiles synced: $file_count files in $changed_packages"
