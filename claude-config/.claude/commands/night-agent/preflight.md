---
name: night-agent:preflight
description: Validate that everything is ready for a night agent run
allowed-tools: [Read, Glob, Grep, Bash]
---

# Night Agent — Preflight

Run pre-flight checks before starting the night agent. This is **read-only** — do not modify anything.

## Checks

1. **Config exists** — `~/.night-agent/config.json` exists and is valid JSON. Parse it, verify `github.repo` is set.

2. **GitHub CLI** — `gh auth status` succeeds.

3. **Repo clean** — `git status --porcelain` produces no output.
   - If dirty, warn: "Uncommitted changes detected. The agent will stash them, but committing or stashing manually first is recommended."

4. **Issues exist** — `gh issue list --label "nightagent" --state open --repo {repo} --json number,title,labels`
   - Filter out issues that have outcome labels (`nightagent-done`, `nightagent-needs-human`, `nightagent-skipped`).
   - Show the count and list titles of actionable issues.
   - If none, warn: "No actionable nightagent issues found."

5. **Baseline tests pass** — Detect and run the project's test command.
   - If tests fail, warn: "Baseline tests are failing. The agent will record these as pre-existing but may have trouble distinguishing new failures."

6. **Stale branches** — Check if any `night-agent/*` branches exist locally or on remote.
   - If found, list them and warn: "Existing night-agent branches found. Consider merging or deleting them first."

## Output

Display a checklist:

```
## Night Agent — Preflight

[pass] Config valid (repo: {repo})
[pass] GitHub CLI authenticated
[WARN] Repo has uncommitted changes
[pass] 3 actionable issues queued
[pass] Baseline tests passing
[WARN] 2 existing night-agent branches found

Result: Ready with warnings
```

Possible results: **Ready** / **Ready with warnings** / **Not ready**

Do NOT start any work. This is purely diagnostic.
