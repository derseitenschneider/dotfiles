---
name: playwright-cli
description: Token-efficient browser automation using playwright-cli. Interactive browsing with persistent sessions, text snapshots instead of screenshots, and ref-based element interaction. Use when user wants to browse the web, scrape pages, fill forms, test UIs, or automate browser tasks via playwright-cli (not the Chrome extension).
---

# Browser Automation (playwright-cli)

Uses `playwright-cli` for interactive browser control via Bash. Text snapshots instead of images = dramatically fewer tokens than MCP or screenshot-based approaches.

## Setup

Run [setup.sh](scripts/setup.sh) if `playwright-cli` is not installed.

## Core loop

Every interaction follows: **open → snapshot → act → snapshot**.

```bash
playwright-cli open https://example.com    # opens browser + navigates (required first step)
playwright-cli snapshot                    # YAML accessibility tree with element refs
# Read the .yml file to see page structure and refs
playwright-cli click e21                   # act on ref from snapshot
playwright-cli snapshot                    # verify result
playwright-cli goto https://other.com      # navigate within existing session
```

**Important:** Use `open` to start a session. Use `goto` to navigate within an already-open session. `goto` will fail if no browser is open.

Snapshot YAML files are saved to `.playwright-cli/` — read them with the Read tool.

## Element refs

Snapshots assign refs like `e1`, `e21` to interactive elements. Use these for all actions:

```bash
playwright-cli click e5
playwright-cli fill e12 "search query"
playwright-cli check e21
playwright-cli select e8 "option-value"
playwright-cli hover e3
```

## Sessions

State persists across Bash calls within a session. Use named sessions for parallel work:

```bash
playwright-cli -s=main open https://app.com
playwright-cli -s=main snapshot
playwright-cli -s=admin open https://app.com/admin
playwright-cli -s=admin snapshot
playwright-cli list                  # show active sessions
playwright-cli close-all             # cleanup when done
```

## Persistent profiles

Preserve cookies/storage across restarts:

```bash
playwright-cli open https://app.com --persistent --profile=./my-profile
```

## Key commands

| Action | Command |
|---|---|
| Open browser + navigate | `open <url>` |
| Navigate (existing session) | `goto <url>` |
| Text snapshot | `snapshot` |
| Screenshot | `screenshot [ref] [--filename=f.png]` |
| Click | `click <ref>` |
| Type (append) | `type "text"` |
| Fill (replace) | `fill <ref> "text"` |
| Press key | `press Enter` |
| Check/uncheck | `check <ref>` / `uncheck <ref>` |
| Select dropdown | `select <ref> "value"` |
| Upload file | `upload <file>` |
| Evaluate JS | `eval "document.title"` |
| Tab management | `tab-list` / `tab-new [url]` / `tab-select <idx>` |
| Console logs | `console` |
| Network requests | `network` |
| Save state | `state-save auth.json` / `state-load auth.json` |

## Principles

1. **Snapshot first, always.** Never act blind — read the page structure before clicking.
2. **Text over images.** Use `snapshot` not `screenshot` unless visual inspection is truly needed.
3. **Read the YAML.** Snapshot prints a file path — use the Read tool to see element refs.
4. **Clean up sessions.** Run `close-all` when done to avoid orphaned browsers.
5. **Use named sessions** when working with multiple pages or flows in parallel.
