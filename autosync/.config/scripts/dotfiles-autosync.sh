#!/usr/bin/env bash
# Two-way sync of the dotfiles repo, the same script on every machine:
#   Mac:       LaunchAgent com.dotfiles.autosync, hourly (/bin/bash 3.2, so no arrays or mapfile here)
#   devserver: systemd user timer dotfiles-autosync.timer, hourly
# Each run commits what changed on this machine, rebases it onto origin and pushes.
#
# - Edits younger than QUIET_MINUTES wait for the next run, so a half-done edit is not pushed.
# - A file another machine stopped tracking (now in its .gitignore) stays on disk here and is
#   untracked here too, instead of being deleted by the pull.
# - Any other conflict aborts the rebase, leaves the repo as it was, and writes BLOCKED_FILE.
#   The Claude SessionStart hook dotfiles-sync-warning.sh and Ora's brain_health report it;
#   a later run that gets through removes it.
# - LAST_OK_FILE holds the time of the last run that got through (Ora alerts when it gets old).
set -euo pipefail

main() {
  if [ -z "${DOTFILES_DIR:-}" ]; then
    if [ -d "$HOME/.dotfiles/.git" ]; then DOTFILES_DIR=$HOME/.dotfiles; else DOTFILES_DIR=$HOME/dotfiles; fi
  fi
  STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}
  BLOCKED_FILE=$STATE_DIR/dotfiles-sync.blocked
  LAST_OK_FILE=$STATE_DIR/dotfiles-sync.last-ok
  BREW_STAMP=$STATE_DIR/dotfiles-brewfile.stamp
  QUIET_MINUTES=${DOTFILES_QUIET_MINUTES:-5}
  HOST=$(hostname -s)
  export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=15"
  export HOMEBREW_NO_AUTO_UPDATE=1

  mkdir -p "$STATE_DIR"
  LOCK_DIR=$STATE_DIR/dotfiles-sync.lock
  if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    if [ -n "$(find "$LOCK_DIR" -prune -mmin +60 2>/dev/null)" ]; then
      rmdir "$LOCK_DIR" 2>/dev/null || true
      mkdir "$LOCK_DIR" || exit 0
    else
      log "another run is busy"
      exit 0
    fi
  fi
  WORK=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-sync.XXXXXX")
  trap 'rm -rf "$WORK"; rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

  cd "$DOTFILES_DIR"
  GITDIR=$(git rev-parse --git-dir)

  if [ -d "$GITDIR/rebase-merge" ] || [ -d "$GITDIR/rebase-apply" ] || [ -f "$GITDIR/MERGE_HEAD" ]; then
    block "a rebase or merge is in progress in $DOTFILES_DIR"
  fi
  branch=$(git symbolic-ref --short -q HEAD || true)
  [ "$branch" = "main" ] || block "checked out is '${branch:-a detached HEAD}', not main"

  # Wait while something is being edited (modified, deleted or new files touched recently).
  busy=$(git ls-files -z -m -o --exclude-standard | xargs -0 -I{} find {} -prune -mmin "-$QUIET_MINUTES" -print 2>/dev/null | head -3 || true)
  if [ -n "$busy" ]; then
    log "edited in the last $QUIET_MINUTES min, next run: $(echo "$busy" | tr '\n' ' ')"
    exit 0
  fi

  dump_brewfile

  git fetch --quiet origin
  upstream=$(git rev-parse '@{u}')

  # Paths this machine tracks that origin does not, and that origin's .gitignore ignores:
  # another machine untracked them on purpose, so they are untracked here and kept on disk.
  git show "$upstream:.gitignore" >"$WORK/upstream.gitignore" 2>/dev/null || : >"$WORK/upstream.gitignore"
  git ls-tree -r --name-only "$upstream" | LC_ALL=C sort >"$WORK/upstream.files"
  git add -A
  git ls-files | LC_ALL=C sort >"$WORK/local.files"
  LC_ALL=C comm -23 "$WORK/local.files" "$WORK/upstream.files" |
    git -c core.excludesFile="$WORK/upstream.gitignore" check-ignore --no-index --stdin >"$WORK/untrack" || true
  if [ -s "$WORK/untrack" ]; then
    tr '\n' '\0' <"$WORK/untrack" | xargs -0 git rm -r --cached -q --ignore-unmatch --
    log "untracked $(wc -l <"$WORK/untrack" | tr -d ' ') path(s) origin ignores now"
  fi

  if ! git diff --cached --quiet; then
    packages=$(git diff --cached --name-only | cut -d/ -f1 | LC_ALL=C sort -u | paste -sd, - | sed 's/,/, /g')
    git commit --quiet --no-gpg-sign -m "auto: $(date '+%Y-%m-%d') $HOST ($packages)"
    log "committed: $packages"
  fi

  if [ "$(git rev-list --count "HEAD..$upstream")" -gt 0 ]; then
    rebase_onto "$upstream"
  fi

  if [ "$(git rev-list --count "$upstream..HEAD")" -gt 0 ]; then
    if ! out=$(git push --quiet origin HEAD:main 2>&1); then
      # Usually the other machine pushed in between; the next run rebases again.
      log "push failed, next run retries: $out"
      exit 1
    fi
    log "pushed $(git rev-parse --short HEAD)"
  fi

  rm -f "$BLOCKED_FILE"
  date '+%Y-%m-%dT%H:%M:%S%z' >"$LAST_OK_FILE"
}

log() {
  echo "[dotfiles-sync] $(date '+%Y-%m-%d %H:%M:%S') $1"
}

block() {
  log "BLOCKED: $1"
  # The first line keeps the date the block started, which is what the alerts count from.
  if [ ! -f "$BLOCKED_FILE" ]; then
    { echo "$(date '+%Y-%m-%d %H:%M') on $HOST: $1"; git status --short 2>/dev/null | head -20; } >"$BLOCKED_FILE"
  fi
  if command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"$1\" with title \"Dotfiles sync blocked\"" 2>/dev/null || true
  fi
  exit 1
}

dump_brewfile() {
  command -v brew >/dev/null 2>&1 || return 0
  today=$(date '+%Y-%m-%d')
  [ "$(cat "$BREW_STAMP" 2>/dev/null || true)" = "$today" ] && return 0
  if brew bundle dump --force --file="$DOTFILES_DIR/Brewfile" >/dev/null 2>&1; then
    echo "$today" >"$BREW_STAMP"
  else
    log "WARNING: brew bundle dump failed, keeping the old Brewfile"
  fi
}

# Rebase local commits onto origin. Conflicts on paths origin untracked are resolved by
# untracking them; anything else aborts. The untracked files' content on disk is kept as it
# was before the rebase, since replaying an old local commit may rewrite them.
rebase_onto() {
  mkdir -p "$WORK/keep"
  if [ -s "$WORK/untrack" ]; then
    while IFS= read -r p; do
      [ -f "$p" ] || continue
      mkdir -p "$WORK/keep/$(dirname "$p")"
      cp -p "$p" "$WORK/keep/$p"
    done <"$WORK/untrack"
  fi

  rounds=0
  git rebase --quiet "$1" >"$WORK/rebase.out" 2>&1 || true
  while [ -d "$GITDIR/rebase-merge" ] || [ -d "$GITDIR/rebase-apply" ]; do
    rounds=$((rounds + 1))
    git diff --name-only --diff-filter=U | LC_ALL=C sort >"$WORK/conflicts"
    LC_ALL=C sort "$WORK/untrack" >"$WORK/untrack.sorted"
    others=$(LC_ALL=C comm -23 "$WORK/conflicts" "$WORK/untrack.sorted")
    if [ -n "$others" ] || [ ! -s "$WORK/conflicts" ] || [ "$rounds" -gt 50 ]; then
      git rebase --abort || true
      restore_kept
      why=${others:-$(tail -3 "$WORK/rebase.out")}
      block "rebase onto origin stopped: $(echo "$why" | tr '\n' ' ')"
    fi
    tr '\n' '\0' <"$WORK/conflicts" | xargs -0 git rm --cached -q --
    if git diff --cached --quiet; then
      git rebase --skip >"$WORK/rebase.out" 2>&1 || true
    else
      GIT_EDITOR=true git rebase --continue >"$WORK/rebase.out" 2>&1 || true
    fi
  done
  restore_kept
  if ! git merge-base --is-ancestor "$1" HEAD; then
    block "could not rebase onto origin: $(tail -3 "$WORK/rebase.out" | tr '\n' ' ')"
  fi
  log "rebased onto origin, now at $(git rev-parse --short HEAD)"
}

restore_kept() {
  (cd "$WORK/keep" && find . -type f) | while IFS= read -r p; do
    p=${p#./}
    mkdir -p "$(dirname "$p")"
    cp -p "$WORK/keep/$p" "$p"
  done
}

# Defined above, run here: bash has read the whole function before the rebase rewrites this file.
main "$@"; exit $?
