# Tmux Configuration

## Theme: Catppuccin Mocha

All colors use the Catppuccin Mocha palette to match Ghostty and opensessions.

| Role | Color | Catppuccin name |
|------|-------|-----------------|
| Pane border | `#585b70` | surface2 |
| Active pane border | `#89b4fa` | blue |
| Current window text | `#f9e2af` | yellow |
| Body text | `#cdd6f4` | text |
| Mode indicator (normal) | `#89b4fa` bg | blue |
| Mode indicator (prefix) | `#f38ba8` bg | red |
| Claude waiting bg | `#45273a` | custom dark red |
| Base background (Ghostty) | `#11111b` | crust |

## Claude Code "Needs Input" Indicator

Event-driven system using Claude Code hooks + tmux window options. No polling.

### How it works

1. **Claude stops or needs input** -> `Stop` and `Notification` hooks in `claude-config/.claude/settings.json` set `@claude-waiting 1` on the window and `@session-claude-waiting 1` on the session
2. **Status bar** shows a dark red background on flagged windows (`window-status-format` conditional on `@claude-waiting`)
3. **User visits window** -> `after-select-window` hook runs `~/.config/scripts/claude-clear-waiting.sh` which clears the window flag and checks if the session flag should also clear
4. **User types a prompt** -> `UserPromptSubmit` hook clears both flags

### Files involved

- `tmux/.tmux.conf` lines 48-50, 65-67 — window format conditionals and clear hook
- `claude-config/.claude/settings.json` — Stop, Notification, UserPromptSubmit hooks
- `scripts/.config/scripts/claude-clear-waiting.sh` — clears window flag, checks sibling windows, clears session flag if none remain
- `scripts/.config/scripts/claude-session-check.sh` — checks if a session has any waiting windows (used by choose-tree, currently commented out)

### Manual mark

`prefix + u` manually marks the current window as "unread" (sets `@claude-waiting 1`).

## opensessions (Forked)

Session sidebar plugin. Fork: `derseitenschneider/opensessions` (upstream: `Ataraxy-Labs/opensessions`).

### Our patches

1. **Persistent unseen indicators** (`packages/runtime/src/server/index.ts`, `packages/runtime/src/agents/tracker.ts`) — unseen dots persist until you explicitly switch to that session via the sidebar, instead of clearing on any focus event. Terminal prune timeout increased to 24 hours.
2. **Duplicate sidebar prevention** (`packages/mux/providers/tmux/src/provider.ts`) — `listSidebarPanes` detects existing sidebars by command + edge position as fallback when pane title hasn't been set yet, preventing duplicates from tmux config reloads.

### Config

- tmux option: `@opensessions-width 55`
- Config file: `~/.config/opensessions/config.json` — `{"sidebarWidth": 40}` (config file takes priority)
- Theme: `catppuccin-mocha` (default)
- Sessionizer directory: `SESSIONIZER_DIR` env var set to `$HOME/dev`

### Pulling upstream updates

```bash
cd ~/.tmux/plugins/opensessions
git pull upstream main
# Resolve conflicts in our patched files if any
git push origin main
```

### Known issue

`prefix + C-s` (opensessions focus) overwrites `send-prefix` (sending literal C-s to programs). Not yet reclaimed.

## Keybindings (custom)

| Binding | Action |
|---------|--------|
| `prefix + u` | Mark current window as "unread" |
| `prefix + o, t` | Toggle opensessions sidebar |
| `prefix + o, s` | Focus opensessions sidebar |
| `prefix + o, 1-9` | Switch to session by index |
| `prefix + C-t` | Toggle sidebar (direct) |
| `prefix + M-1..9` | Switch to session by index (direct) |

## Plugin List

- `tmux-plugins/tpm` — plugin manager
- `christoomey/vim-tmux-navigator` — seamless vim/tmux pane navigation
- `MunifTanjim/tmux-mode-indicator` — prefix/mode indicator in status bar
- `tmux-plugins/tmux-resurrect` — save/restore sessions (prefix-Ctrl-s / prefix-Ctrl-r)
- `derseitenschneider/opensessions` — session sidebar (forked)
