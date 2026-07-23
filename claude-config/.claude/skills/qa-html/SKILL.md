---
name: qa-html
description: "Build an interactive QA console as a local HTML page (served via the local preview server) so a human can hand-test a feature or release in the browser, then export their findings as a worklist-first Markdown handoff led by an editable fix prompt for a fixing agent. Callable only — invoke explicitly with /qa-html or 'use the qa-html skill'. Never auto-trigger."
disable-model-invocation: true
---

# QA console (local HTML)

Produces a browser checklist the user works by hand, and a paste-ready briefing for the agent that fixes what they find. The shell (CSS, state, export) is a bundled asset — **never regenerate it**. You author only the QA items and a little chrome.

## Workflow

1. **Establish the surface under test.** From whatever the user points at: the conversation, `git diff`, a PR, a release tag, a plan doc. Read enough to know what actually changed and where it can break. Ask only if the target is genuinely ambiguous.
2. **Author the items.** Group into sections by surface. One observable check per item. See [AUTHORING.md](AUTHORING.md) — read it before writing items, it carries the rules and a worked example.
3. **Copy the shell and inject.** Copy `assets/qa-console.html` to a working file **under `$HOME`** so the preview server can reach it — a gitignored spot near the project (e.g. `~/dev/wp-local/sites/<site>/qa-<run>.html`) unless the user names a path. Never the scratchpad (`/tmp` paths get 403 from the preview server). Edit only the four marked spots — never touch the CSS or the code below `INJECT: end`:
   - `<title>` at the top of the file
   - `<!-- INJECT: header chrome -->` — eyebrow, `<h1>`, version/branch badge
   - `<!-- INJECT: intro copy -->` — what this run covers, anything the tester must know up front
   - `/* INJECT: begin … end */` in the script — `CONFIG`, `FLAGS`, `DEFAULT_FIX_PROMPT`, `QA`
4. **Wrap for standalone serving.** The shell ships headless (it was written for a publisher that wrapped it). Served raw, browsers fall into quirks mode and the CSS degrades. Prepend this line — once, at the very top, before `<title>`:
   `<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">`
5. **Hand off locally.** Give the user the preview-server link: `http://127.0.0.1:51234/<absolute-filesystem-path>` (see the user's global CLAUDE.md for the server; `launchctl load ~/Library/LaunchAgents/com.morntag.claude-preview.plist` if unreachable). Tell them: statuses and notes save to *their browser*, so export from the same browser; edit the fix prompt before exporting if the scope is off; **Copy for agent** then paste into a fresh session. Do **not** publish as an Artifact unless the user explicitly asks to share the console with someone else — if they do, strip the doctype line again (the publisher wraps the file) and follow the Artifact tool's rules.

## Item schema

```js
{ id:"auth-fr", t:"French signup card renders fully localized",
  how:"Open the app in a French browser. No German or English leaking on the card.",
  key:"resolveLocale.ts", flags:["unreviewed"] }
```

| Field | Required | Notes |
| --- | --- | --- |
| `id` | yes | Stable, human-meaningful, unique across the whole run. **localStorage is keyed by it.** |
| `t` | yes | The claim being verified, as a statement that can be true or false. |
| `how` | yes | Concrete steps a human can follow without reading code. |
| `key` | no | Short mono tag — a file, constant, or column name. Not a sentence. |
| `flags` | no | Keys of `FLAGS`. Vocabulary is yours to define per run. |

Sections are `{ id, title, items:[…] }`. `FLAGS` entries are `{ label, tone }` with tone `pass | needs | fail | na | info`.

## The fix prompt

The export leads with it, so it is the whole point. Write `DEFAULT_FIX_PROMPT` as a self-contained briefing — assume the receiving agent has **only that paste**: no repo context, no conversation. Name the feature, the repo and branch, the paths it may touch, that worklist items are human-observed defects, the reproduce → fix → test → log loop (pointing at the repo's own bug-fix convention), and that it must ask before straying outside the surface under test. The shipped default is a fill-in-the-blanks skeleton — replace the `<placeholders>` with real values, do not ship it as-is.

The user can edit it in the page; their edit persists and wins over your default. "Restore default" brings yours back.

## Rules that bite

- **Never rename an `id`.** localStorage is keyed by it, so a rename silently orphans that item's saved status and notes. Adding, reordering, and re-wording items is safe. If an item's meaning changes fundamentally, a new id is correct — say so to the user.
- **`CONFIG.slug` must be unique per QA run** (e.g. `i18n-launch-v1`, `billing-refactor-v1`). This bites harder locally than it did online: every console served from `127.0.0.1:51234` shares **one** localStorage origin, so two runs with the same slug clobber each other's state even from different files.
- **State never leaves the browser.** It is in localStorage, not in the file, and not visible to you. A different browser or a cleared profile means a blank sheet. Tell the user this when you hand over the link.
- **Updating a console:** edit the file in place at the same path — the URL and the saved state both key off it. Moving or renaming the file changes the URL but *not* the state (same origin, keyed by slug), so statuses survive a move as long as the slug stays put.
- **Self-contained only.** No CDN fonts, no fetch, no external assets — the console must work offline and would also break if it is ever published as an Artifact (whose CSP blocks every external host). The shell already complies.
- **The shell is headless by design** (no `<!doctype>` / `<html>` / `<head>` / `<body>`): local serving needs the doctype line from workflow step 4; Artifact publishing needs it removed. Never end up with both worlds' requirements in one file.
