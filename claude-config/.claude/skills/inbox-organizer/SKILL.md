---
name: inbox-organizer
description: "Organize and triage Apple Mail inboxes. For the Gmx account (personal), moves emails into PARA folders. For all other accounts (MSRT, Eleno, Derseitenschneider, bresznik@gmail.com, brianboy.ch), only deletes spam and unnecessary emails — those inboxes serve as their own archive. Learns new patterns over time. Use this skill whenever the user mentions inbox, email cleanup, mail organization, triage emails, clean up email, delete spam, check my email, what's new in my inbox, or Apple Mail management."
---

# Inbox Organizer

Triages the **Gmx** inbox in Apple Mail. Reads emails via AppleScript (`mcp__Control_your_Mac__osascript`), matches them against learned patterns, trashes spam, and leaves actionable items untouched.

## Prerequisites

- The **Control your Mac** MCP (osascript) must be connected
- Apple Mail must be running

## Scope

This skill ONLY processes the **Gmx** account (inbox name: "INBOX"). All other accounts (MSRT, Eleno, Derseitenschneider, bresznik@gmail.com, brianboy.ch) are out of scope.

## Core Rules

### Unread = Todo
The user uses unread status as a todo marker. Unread personal/important emails STAY in the inbox. Spam can be trashed regardless of read status.

### Safelist (never touch these)
Some emails are always actionable and manually managed. The skill must NEVER move or trash them, even if read:

- **Irina** (`irina.rusu89@yahoo.ro`) — personal/family. Always stays.
- **Rechnungen/Invoices** — subject containing Rechnung, Invoice, Zahlung, Payment, Quittung. Always stays until manually filed.
- **Hostpoint** (`hostpoint.ch`) — invoices. Always stays.
- **AWS** (`amazon.com`, `aws.com`) — infrastructure items. Always stays.

### Trash patterns (delete regardless of read status)
- WordPress plugin updates from ANY site (subject contains "Plugins wurden automatisch aktualisiert" or "plugins were automatically updated")
- GitHub release notifications (subject contains "Release")
- Galaxus/Digitec notifications (`galaxus.ch`)
- TLDR Dev newsletter (`tldrnewsletter.com`)
- Cheat Day notifications (`info@cheat-day.ch`)
- Brilliant.org gamification (`brilliant.org`)
- GMX self-marketing (`gmx.net`)
- Instapaper (`instapaper.com`)
- Raiffeisen E-Dokument Kontoauszug (`raiffeisen.ch`, subject contains "E-Dokument" AND "Kontoauszug")

### Leave in inbox (actionable)
- GitHub PR run failures (subject contains "PR run failed" or "Run failed")
- AWS emails — all of them
- Irina — all of them
- Rechnungen — all of them
- Anything unmatched — ask the user

### Sort patterns (move only if READ)
- UptimeRobot (`uptimerobot.com`) → 📱 Eleno (01-Projects)
- Cembra (`cembra.ch`) → 🏦 Banking (02-Areas)

## The Patterns File

The skill maintains a `patterns.json` file that stores learned rules. Read it at the start of every run from the skill directory. If it doesn't exist, initialize from `references/seed_patterns.json`.

Each pattern has:
- **id**, **description**, **condition**, **action**, **mode** (`delete_only`, `sort`, or `safelist`)
- **confirmations**: times the user approved this pattern
- **status**: `"confirm"` (ask first) or `"auto"` (apply silently, after 3+ confirmations)
- **requires_read**: if true, only apply when the email is read

Safelist patterns override everything — if a safelist matches, the email is untouched.

## Workflow

### Step 1: Load patterns
Read the patterns file.

### Step 2: Fetch Gmx inbox
```applescript
tell application "Mail"
    set acct to account "Gmx"
    set mb to mailbox "INBOX" of acct
    set msgs to messages of mb
    set output to ""
    set batchSize to 50
    if (count of msgs) < batchSize then set batchSize to (count of msgs)
    repeat with i from 1 to batchSize
        set msg to item i of msgs
        set output to output & (id of msg) & "|||" & (sender of msg) & "|||" & (subject of msg) & "|||" & (date received of msg as text) & "|||" & (read status of msg as text) & linefeed
    end repeat
    return output
end tell
```

### Step 3: Match each email
Check in order: safelist first (if match → skip), then delete_only patterns, then sort patterns. For sort patterns, respect `requires_read`.

### Step 4: Present summary
Group by: auto-applied, needs confirmation, unmatched. Wait for user approval.

### Step 5: Execute
**Trash:**
```applescript
tell application "Mail"
    set acct to account "Gmx"
    set mb to mailbox "INBOX" of acct
    set msgs to (every message of mb whose id is MESSAGE_ID)
    if (count of msgs) > 0 then delete (item 1 of msgs)
end tell
```

**Move to PARA folder:**
```applescript
tell application "Mail"
    set targetMailbox to mailbox "SUBFOLDER" of mailbox "PARA_CATEGORY"
    set acct to account "Gmx"
    set mb to mailbox "INBOX" of acct
    set msgs to (every message of mb whose id is MESSAGE_ID)
    if (count of msgs) > 0 then move (item 1 of msgs) to targetMailbox
end tell
```

### Step 6: Learn
- Confirmed → increment confirmations (at 3 → auto)
- Redirected → update/create pattern
- New unmatched decision → create pattern
- Save updated patterns.json

### Step 7: Propose new patterns
Look for clusters in unmatched emails (2+ from same domain). Propose conservatively.

## PARA Folder Structure (local "On My Mac" mailboxes)
- **01-Projects**: 🎸 ChorLife, 🎸 TJ Christmas Tour, 🐴 Website Nadine, 📱 Eleno
- **02-Areas**: ✈️ Flüge & Reisen, ❤️ Finn, ❤️ Irina, 🎸 NGC, 🎸Halunke, 🏡 Wohnung, 🏥 Krankenkasse, 🏦 Banking, 🏫 MSRT, 💰 Rechnungen (→ 2025, 2026), 🚙 Auto
- **03-Resources**: 🔒 Passwörter & Verträge
- **04-Archive**: Various completed projects

## Safety
1. Never delete emails less than 1 hour old unless explicitly asked.
2. Log every action.
3. Offer undo within the session.

## Language
Bilingual (German/English). Case-insensitive matching. Handle ä, ö, ü, ß.
