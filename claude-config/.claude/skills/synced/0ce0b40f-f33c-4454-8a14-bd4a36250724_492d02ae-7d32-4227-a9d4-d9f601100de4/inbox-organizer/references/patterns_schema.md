# Patterns JSON Schema

## Top-level structure

```json
{
  "version": 1,
  "last_updated": "YYYY-MM-DD",
  "patterns": [...],
  "folder_structure": {...},
  "accounts": {...}
}
```

## Pattern object

```json
{
  "id": "unique-kebab-case-id",
  "description": "Human-readable description of what this pattern matches",
  "condition": {
    "type": "sender_address | sender_domain | subject_keyword | account",
    "value": "string or array of strings",
    "subject_contains": ["optional", "additional", "subject", "filters"]
  },
  "action": {
    "type": "move | trash | flag | archive",
    "target_folder": "Folder name (for move action)",
    "target_parent": "Parent PARA folder (for move action)"
  },
  "confirmations": 0,
  "status": "confirm | auto",
  "created": "YYYY-MM-DD",
  "account_hint": "Optional - limit this pattern to a specific account"
}
```

## Condition types (in order of specificity)

1. **sender_address**: Exact email address match (most specific)
2. **sender_domain**: Domain part of email address
3. **subject_keyword**: Array of keywords to match in subject line (case-insensitive)
4. **account**: Match all emails in a specific account (least specific)

## Action types

1. **move**: Move to a specific PARA folder
2. **trash**: Move to the account's trash/deleted folder
3. **flag**: Set the flagged status (mark as important)
4. **archive**: Move to the account's archive folder

## Status lifecycle

- `"confirm"` — Ask the user before applying (confirmations < 3)
- `"auto"` — Apply silently (confirmations >= 3)

When a user confirms an action, increment `confirmations`. At 3, flip `status` to `"auto"`.

## Folder structure

Maps PARA categories to their subfolders. Used to validate move targets.

## Accounts

Maps account names to their inbox mailbox name. Some use "Inbox", others "INBOX". Accounts with `null` inbox have no active inbox.
