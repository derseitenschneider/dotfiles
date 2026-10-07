---
name: night-agent:status
description: Show open issues labeled 'nightagent' (read-only)
allowed-tools: [Read, Glob, Grep, Bash]
---

# Night Agent — Status

Show the current work queue and processing state. This is **read-only** — do not modify anything.

## Steps

1. **Read config** — Load `~/.night-agent/config.json`. If missing, tell the user to run `install.sh`.

2. **Fetch issues** — `gh issue list --label "nightagent" --state open --repo {github.repo} --json number,title,labels`

3. **Separate by outcome** — Split issues into:
   - **Actionable**: no outcome label (`nightagent-done`, `nightagent-needs-human`, `nightagent-skipped`)
   - **Previously processed**: has an outcome label

4. **Check branches** — List any `night-agent/*` branches:
   ```bash
   git branch -a --list '*night-agent/*'
   ```

5. **Check for last report** — If `~/.night-agent/reports/` has reports, show the date of the most recent one.

6. **Display**:

```
## Night Agent — Status

**Repo:** {repo}

### Queue (actionable)

| # | Title | Labels |
|---|-------|--------|
| 12 | Add search functionality | nightagent |
| 15 | Fix auth timeout | nightagent, bug |

{N} actionable issues

### Previously Processed

| # | Title | Outcome |
|---|-------|---------|
| 10 | Fix widget | done |
| 11 | Add caching | needs-human |
| 9 | Redesign nav | skipped |

### Branches

{list of night-agent/* branches}

**Last report:** {date or "none"}
```

Do NOT start any work. This is purely informational.
