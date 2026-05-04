# Fix Nerd Font glyphs in Superset terminal

## Context

User switched from Ghostty (which had a fully styled prompt with Nerd Font glyphs) to Superset for daily terminal work. The Superset terminal renders boxes `[]` instead of glyphs in the Starship prompt — visible in the screenshot before "brianboy" and before "main".

### Key finding: Superset is **not** macOS Terminal.app

The user calls it "superset.sh", but it's actually `/Applications/Superset.app` — an Electron app (com.superset.desktop) that ships its own terminal renderer (xterm.js + node-pty bundled in `app.asar.unpacked/node_modules/node-pty`). It is the GUI agent terminal that hosts Claude Code, OpenCode, etc. (see `~/.superset/bin/{claude,opencode,codex,...}` shims and `~/.superset/app-state.json` showing tabs like "Claude Code"). It does not delegate to Terminal.app.

This means:
- "Make Ghostty the default terminal for superset.sh" is **not possible** — Superset embeds its own terminal; it doesn't shell out to a system terminal app.
- Editing `~/Library/Preferences/com.apple.Terminal.plist` would not help either, for the same reason.

### Why glyphs are missing

Ghostty rendered Nerd Font glyphs because Ghostty ships fonts compiled into its binary (it does not need the font installed system-wide). Superset's xterm.js renderer relies on **system-installed fonts**, and:

- `~/Library/Fonts/` is empty.
- `/Library/Fonts/` has no Nerd Fonts.
- No Homebrew font casks are installed (`/Users/brianboy/.dotfiles/Brewfile` has zero `font-*` entries).
- `fc-list` finds no CaskaydiaCove / Nerd Font.

So `CaskaydiaCove NFM` referenced by `/Users/brianboy/.dotfiles/ghostty/.config/ghostty/config:1` only worked because Ghostty bundled it. Superset has nothing to fall back to for glyphs like `` (git branch), the OS icon, etc., used in `/Users/brianboy/.dotfiles/starship/.config/starship.toml`.

## Plan

### 1. Install CaskaydiaCove Nerd Font system-wide

```bash
brew install --cask font-caskaydia-cove-nerd-font
```

This matches the family Ghostty already uses (`CaskaydiaCove NFM Regular`), so the visual experience stays consistent across Ghostty and Superset. The installed PostScript names will be e.g. `CaskaydiaCoveNerdFontMono-Regular` — Superset's font input will accept either `CaskaydiaCove Nerd Font Mono` or `CaskaydiaCove NFM`.

### 2. Add the cask to the Brewfile so it's reproducible

Edit `/Users/brianboy/.dotfiles/Brewfile` to add:

```ruby
cask "font-caskaydia-cove-nerd-font"
```

Place it near other casks. After installing, also run `brew bundle dump --file=- | diff Brewfile -` (per the project's CLAUDE.md workflow) to confirm nothing else drifted.

### 3. Configure Superset to use the font

Superset stores its settings in Electron localStorage / IndexedDB inside `~/Library/Application Support/Superset/` (not a flat editable JSON — the only files there are Chromium-managed `Preferences`, `SharedStorage`, sqlite blobs). So this step has to be done **through Superset's in-app Settings UI**, not by writing a config file:

1. Open Superset → Settings (⌘,) → Terminal / Appearance.
2. Set the terminal font family to: `CaskaydiaCove Nerd Font Mono` (or the exact family string Superset shows in its picker after step 1).
3. Match Ghostty: font size **18**, line height **1.20** (Ghostty uses `adjust-cell-height = 20%`).
4. If Superset exposes a theme picker, choose a Catppuccin Mocha variant to match Ghostty's `/Users/brianboy/.dotfiles/ghostty/.config/ghostty/themes/catppuccin-mocha`.

I'll guide you through this interactively after the font installs — exact menu labels depend on Superset's current version (1.8.0 per its `Info.plist`).

### 4. (Out of scope) "Make Ghostty the default terminal for Superset"

Not feasible — Superset doesn't expose a setting for an external terminal; it *is* the terminal. If matching Ghostty exactly matters more than using Superset's agent features, the alternative is to stop using Superset and run `claude` / `opencode` directly inside Ghostty. Worth flagging but not part of this fix.

## Files touched

- `/Users/brianboy/.dotfiles/Brewfile` — add one `cask` line.
- (No dotfile changes for Superset itself — it's configured through its GUI.)

## Verification

1. After `brew install`: `fc-list | grep -i caskaydia` should return entries; `ls ~/Library/Fonts/ | grep -i Caskaydia` should show the TTFs.
2. Restart Superset (Electron caches font lists at startup), open a new terminal tab, run `starship prompt`. The git branch glyph, OS icon, and directory icons should render — no boxes.
3. Cross-check: open Ghostty side-by-side; the prompt glyphs and font weight/size should look identical.
4. `brew bundle check` from the dotfiles repo should pass cleanly.

## Open question for you

Confirm the font choice: stick with **CaskaydiaCove** (matches your Ghostty config) or switch both Ghostty and Superset to a different Nerd Font (e.g., JetBrainsMono Nerd Font, FiraCode Nerd Font)? The fix is the same shape either way — only the cask name changes.
