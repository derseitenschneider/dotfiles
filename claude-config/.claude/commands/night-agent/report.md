---
name: night-agent:report
description: Generate or view the night agent session report
allowed-tools: [Read, Write, Glob, Grep, Bash]
---

# Night Agent — Report

Generate or view a session report.

## Steps

1. **Read config** — Load `~/.night-agent/config.json`.

2. **Gather state** from:
   - TodoRead — current task states
   - Git log across `night-agent/*` branches — commits made during this session
   - Issues with outcome labels

3. **Check for existing report** — Look for today's report at `~/.night-agent/reports/YYYY-MM-DD.md`. If it exists, display it and ask if the user wants to regenerate.

4. **Generate report** using: @~/.claude/night-agent/templates/session-report.md

5. **Write** to `~/.night-agent/reports/YYYY-MM-DD.md` (create `reports/` if needed).

6. **Post to GitHub** — If `github.report` is `"issue"`:
   ```bash
   gh issue create \
     --title "Night Agent Report — {DATE}" \
     --label "nightagent-report" \
     --body "{report content}" \
     --repo {github.repo}
   ```

7. **Display** the full report.
