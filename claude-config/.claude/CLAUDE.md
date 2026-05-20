# User-wide instructions

## Surfacing files for browser preview

The user runs Claude Code inside Superset.app, which only opens `http(s)://` URLs in the system browser — file paths and `file://` URLs open inside a Superset editor tab (showing source, not rendered).

A local preview server runs at `127.0.0.1:51234` (LaunchAgent `com.morntag.claude-preview`, script `~/.local/bin/claude-preview-server`) and serves any file under `$HOME` with the correct `Content-Type`.

**Rule:** When referencing a file the user might want to view rendered (HTML, SVG, PDF, image, etc.) and the file is under `$HOME`, link to it as:

`http://127.0.0.1:51234/<absolute-filesystem-path>`

Example: `http://127.0.0.1:51234/Users/brianboy/dev/.../report.html`

Not as `plans/.../report.html` or `file:///...`.

For files outside `$HOME` (e.g. `/tmp`, `/etc`) the server returns 403 — fall back to the plain path.

If the server is unreachable: `launchctl list | grep claude-preview` to check, `launchctl load ~/Library/LaunchAgents/com.morntag.claude-preview.plist` to start.
