# AppleScript Recipes for Apple Mail

These are tested AppleScript snippets for use with the `mcp__Control_your_Mac__osascript` tool. Each recipe handles one specific mail operation.

## Fetching Inbox Emails

Fetches emails from a specific account's inbox. Returns sender, subject, date, read status, and message ID for pattern matching.

```applescript
tell application "Mail"
    set acct to account "ACCOUNT_NAME"
    set mb to mailbox "INBOX_NAME" of acct
    set msgs to messages of mb
    set output to ""
    set batchSize to 50
    if (count of msgs) < batchSize then set batchSize to (count of msgs)
    repeat with i from 1 to batchSize
        set msg to item i of msgs
        set msgId to id of msg
        set msgFrom to sender of msg
        set msgSubj to subject of msg
        set msgDate to date received of msg
        set msgRead to read status of msg
        set msgFlagged to flagged status of msg
        set output to output & msgId & "|||" & msgFrom & "|||" & msgSubj & "|||" & (msgDate as text) & "|||" & (msgRead as text) & "|||" & (msgFlagged as text) & linefeed
    end repeat
    return output
end tell
```

The `|||` delimiter makes parsing easier. Adjust `batchSize` for larger inboxes.

## Moving an Email to a PARA Folder

Moves a message by ID to a nested local mailbox (e.g., a subfolder under 01-Projects).

```applescript
tell application "Mail"
    set targetMailbox to mailbox "SUBFOLDER_NAME" of mailbox "PARA_CATEGORY"
    set acct to account "ACCOUNT_NAME"
    set mb to mailbox "INBOX_NAME" of acct
    set msgs to (every message of mb whose id is MESSAGE_ID)
    if (count of msgs) > 0 then
        move (item 1 of msgs) to targetMailbox
    end if
end tell
```

For subfolders with sub-subfolders (e.g., 💰 Rechnungen/2026):
```applescript
tell application "Mail"
    set targetMailbox to mailbox "2026" of mailbox "💰 Rechnungen" of mailbox "02-Areas"
    -- ...same move logic
end tell
```

## Trashing an Email

```applescript
tell application "Mail"
    set acct to account "ACCOUNT_NAME"
    set mb to mailbox "INBOX_NAME" of acct
    set msgs to (every message of mb whose id is MESSAGE_ID)
    if (count of msgs) > 0 then
        delete (item 1 of msgs)
    end if
end tell
```

## Flagging an Email

```applescript
tell application "Mail"
    set acct to account "ACCOUNT_NAME"
    set mb to mailbox "INBOX_NAME" of acct
    set msgs to (every message of mb whose id is MESSAGE_ID)
    if (count of msgs) > 0 then
        set flagged status of (item 1 of msgs) to true
    end if
end tell
```

## Listing All Local Mailboxes (PARA Discovery)

```applescript
tell application "Mail"
    set output to ""
    set localBoxes to every mailbox
    repeat with mb in localBoxes
        set mbName to name of mb
        set mbContainer to ""
        try
            set mbContainer to name of container of mb
        end try
        set output to output & mbName & " [" & mbContainer & "]" & linefeed
    end repeat
    return output
end tell
```

## Batch Move (Multiple Emails)

When moving many emails matching a pattern, it's more efficient to do it in one script:

```applescript
tell application "Mail"
    set targetMailbox to mailbox "SUBFOLDER_NAME" of mailbox "PARA_CATEGORY"
    set acct to account "ACCOUNT_NAME"
    set mb to mailbox "INBOX_NAME" of acct
    -- Move all messages from a specific sender domain
    set msgs to (every message of mb whose sender contains "@DOMAIN.COM")
    repeat with msg in msgs
        move msg to targetMailbox
    end repeat
    return (count of msgs) & " messages moved"
end tell
```

## Fetching Only Unread Emails

```applescript
tell application "Mail"
    set acct to account "ACCOUNT_NAME"
    set mb to mailbox "INBOX_NAME" of acct
    set unreadMsgs to (every message of mb whose read status is false)
    -- Process unreadMsgs...
    return (count of unreadMsgs) & " unread messages"
end tell
```

## Important Notes

- **Inbox name varies by account**: MSRT uses "Inbox", most others use "INBOX"
- **Emoji in folder names**: AppleScript handles emoji fine, just use them directly
- **German characters**: ä, ö, ü, ß all work in AppleScript strings
- **Message IDs are integers**: They're unique within a mailbox, not globally unique
- **Error handling**: Always wrap moves/deletes in try blocks when processing batches, since a message might have been moved/deleted by a mail rule between fetch and action
