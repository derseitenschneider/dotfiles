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

## Preview links over Tailscale

Brian often reads a session from another device (his phone, or a session running on the other machine), where `127.0.0.1` links do not open. Anything he should view rendered (HTML, images, video, PDF) goes under `~/claude-previews/` and is linked as:

`https://<machine>.taile1eb2e.ts.net:8444/<path below ~/claude-previews>`

`<machine>` is the machine this session runs on: `macbook-air-von-brian` (Mac) or `devserver` (Linux); check with `hostname`. Example: `~/claude-previews/qa-videos/x/index.html` becomes `https://devserver.taile1eb2e.ts.net:8444/qa-videos/x/index.html`.

Use this form instead of `http://127.0.0.1:51234/...` for everything under `~/claude-previews`. Files elsewhere under `$HOME` are not reachable over Tailscale: copy them into `~/claude-previews` first. Request the link with `curl` before giving it to Brian, and expect HTTP 200.

How it is served: `~/.local/bin/claude-previews-server` on `127.0.0.1:51235` (LaunchAgent `com.morntag.claude-previews-tailnet` on macOS, systemd user unit `claude-previews.service` on Linux) behind `tailscale serve` on port 8444, reachable inside the tailnet only. It supports HTTP Range, so video plays on iOS. To repair or reinstall: `curl -fsS https://devserver.taile1eb2e.ts.net:8444/setup-claude-previews.sh | bash`.
