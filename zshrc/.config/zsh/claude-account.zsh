# Claude Code account switch.
# Private account for private repos, work (morntag Team) account everywhere else.
# "Private" = inside ~/dev/personal, or any git checkout/worktree whose origin
# repo name is in CLAUDE_PRIVATE_REPOS. Works on Mac and devserver alike.
CLAUDE_PRIVATE_CONFIG_DIR="$HOME/.claude-private"
CLAUDE_PRIVATE_REPOS=(eleno ora oracount songindex brianboy cc-usage dev-server whisper-local budget-calculator life)

_claude_account_switch() {
  local private=0
  case "$PWD/" in
    "$HOME/dev/personal/"*) private=1 ;;
    *)
      local origin name
      origin=$(git config --get remote.origin.url 2>/dev/null) || origin=""
      if [[ -n "$origin" ]]; then
        name=${origin:t:r}
        (( ${CLAUDE_PRIVATE_REPOS[(Ie)$name]} )) && private=1
      fi
      ;;
  esac
  if (( private )); then
    export CLAUDE_CONFIG_DIR="$CLAUDE_PRIVATE_CONFIG_DIR"
  elif [[ "$CLAUDE_CONFIG_DIR" == "$CLAUDE_PRIVATE_CONFIG_DIR" ]]; then
    unset CLAUDE_CONFIG_DIR
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _claude_account_switch
_claude_account_switch

# Manual overrides, regardless of directory.
claude-private() { CLAUDE_CONFIG_DIR="$CLAUDE_PRIVATE_CONFIG_DIR" command claude "$@"; }
claude-work()    { env -u CLAUDE_CONFIG_DIR claude "$@"; }
claude-account() { [[ "$CLAUDE_CONFIG_DIR" == "$CLAUDE_PRIVATE_CONFIG_DIR" ]] && echo private || echo work; }
