#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
STAMP_FILE="$HOME/.local/log/dotfiles-autosync.stamp"
LOG_PREFIX="[dotfiles-autosync]"

notify() {
  local title="$1" body="$2"
  osascript -e "display notification \"$body\" with title \"$title\"" 2>/dev/null || true
}

log() {
  echo "$LOG_PREFIX $(date '+%Y-%m-%d %H:%M:%S') $1"
}

cd "$DOTFILES_DIR"

# Check for unpushed commits from a previous failed push
unpushed=$(git log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')

# If we already committed today and there's nothing unpushed, we're done
today=$(date '+%Y-%m-%d')
last_run=$(cat "$STAMP_FILE" 2>/dev/null || echo "never")
if [ "$last_run" = "$today" ] && [ "$unpushed" -eq 0 ]; then
  exit 0
fi

# If we already committed today but push failed, skip straight to push
if [ "$last_run" = "$today" ] && [ "$unpushed" -gt 0 ]; then
  log "Retrying push for $unpushed unpushed commit(s)"
  if push_output=$(git push 2>&1); then
    log "Push retry succeeded"
    notify "Dotfiles Synced" "Dotfiles synced (push retry succeeded)"
    exit 0
  else
    log "Push retry failed: $push_output"
    exit 1
  fi
fi

# --- Daily run: commit + push ---

log "Starting daily sync"

# Skip brew auto-update to avoid long delays
export HOMEBREW_NO_AUTO_UPDATE=1

# Update Brewfile to capture any new brew installs
log "Dumping Brewfile..."
if ! brew bundle dump --force --file="$DOTFILES_DIR/Brewfile" 2>&1; then
  log "WARNING: brew bundle dump failed, continuing with existing Brewfile"
fi

# Stage all changes
git add -A

# Check if there are staged changes or unpushed commits
if git diff --cached --quiet && [ "$unpushed" -eq 0 ]; then
  log "No changes to sync"
  notify "Dotfiles" "Dotfiles clean, nothing to sync"
  echo "$today" > "$STAMP_FILE"
  exit 0
fi

# Commit if there are staged changes
if ! git diff --cached --quiet; then
  changed_packages=$(git diff --cached --name-only | cut -d'/' -f1 | sort -u | tr '\n' ', ' | sed 's/,$//' | sed 's/,/, /g')
  file_count=$(git diff --cached --name-only | wc -l | tr -d ' ')
  message="auto: $today ($changed_packages)"

  log "Committing: $message"
  if ! git commit --no-gpg-sign -m "$message" 2>&1; then
    log "ERROR: commit failed"
    notify "Dotfiles Sync Failed" "Dotfiles sync failed: commit error"
    exit 1
  fi
else
  log "No new changes, pushing previously unpushed commits"
  changed_packages="(retry)"
  file_count=0
fi

# Mark today as committed (even if push fails, we won't re-commit)
echo "$today" > "$STAMP_FILE"

# Push
log "Pushing to remote..."
if push_output=$(git push 2>&1); then
  log "Sync complete: $file_count files in $changed_packages"
  notify "Dotfiles Synced" "Dotfiles synced: $file_count files in $changed_packages"
else
  log "Push failed (will retry next run): $push_output"
  notify "Dotfiles Sync" "Committed locally, push will retry"
  exit 1
fi
