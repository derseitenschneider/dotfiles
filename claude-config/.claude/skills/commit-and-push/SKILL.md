---
name: commit-and-push
description: Stage changes, create a conventional-commit-formatted git commit, and optionally push. Detects project commitlint config for repo-specific rules. After pushing, a hands-off watchdog monitors the triggered CI and auto-fixes failures (bounded) without needing approval. Use when creating git commits, committing changes, or pushing code.
---

# Commit and Push

## Context gathering

Before committing, collect this context:

- `git status` (never use `-uall`)
- `git diff HEAD` (staged + unstaged changes)
- `git branch --show-current`
- `git log --oneline -10` (match existing style)
- Check for `commitlint.config.*` or `.commitlintrc*` in the project root

## Commitlint detection

If a commitlint config file exists, read it and follow its `type-enum`, `scope-enum`, and `subject-case` rules exactly. Those rules override the defaults below.

## Conventional commit format

```
type(scope): lowercase subject
```

### Types

`build` `chore` `ci` `docs` `feat` `fix` `perf` `refactor` `revert` `style` `test`

### Scope

- If commitlint config defines scopes, use one of those
- Otherwise, scope is optional — use a short word describing the area changed (e.g., `auth`, `db`, `ui`)
- If changes span many areas, use the primary scope or omit

### Subject rules

- **Lowercase** — `add feature` not `Add feature`
- **No trailing period**
- **Imperative mood** — `add`, `fix`, `update` (not `added`, `fixed`, `updated`)
- **Under 72 characters**
- Describe the **why** briefly, not just the what

### Body

Only add a body when the commit is complex enough to justify it. Separate from subject with a blank line.

## Workflow

1. Stage all modified and untracked files: `git add -A`
2. Create the commit using a HEREDOC for the message:
   ```
   git commit -m "$(cat <<'EOF'
   type(scope): subject here
   EOF
   )"
   ```
3. If the user said "push" or the skill name includes "push": push with `git push`
4. If push fails due to no upstream: `git push -u origin HEAD`
5. After a successful push, run the **Watchdog** (below) to monitor and self-heal CI.

## Watchdog (post-push CI monitoring)

After a successful push, monitor the CI it triggers and self-heal failures **hands-off**: do not ask for approval to apply fixes, and do not stop merely to report a failure — fix it. Only surface something when you give up (see "Stop and summarize").

**Skip the watchdog** (note it in one line, don't treat as an error) when any of these holds: no `gh` CLI or it isn't authenticated (`gh auth status`), the repo has no GitHub remote, GitHub Actions isn't configured, or the push triggered no workflow run.

### Monitor

1. Capture the pushed commit: `git rev-parse HEAD`.
2. Find the run(s) for it (allow a few seconds for runs to register; retry briefly if none appear yet):
   `gh run list --branch "$(git branch --show-current)" --limit 10 --json databaseId,headSha,workflowName,status` and select the runs whose `headSha` matches the pushed commit. Track **all** workflows the push triggered, not just the first.
3. Watch each to completion **in the background** so you aren't blocked and it survives the user stepping away — `gh run watch <run-id> --exit-status` run as a background task; you'll be re-invoked when it finishes (or poll on a self-paced interval if backgrounding isn't available).

### React on failure — delegate the heal to a sub-agent

When a run concludes as failure, **delegate the diagnose-and-fix to a fresh sub-agent** (Agent/Task tool) rather than doing it inline. CI logs are large and noisy; isolating each heal in its own context keeps the diagnosis sharp and the orchestrator's context lean. This matters most when the main conversation is **already deep in token usage** — the sub-agent starts from a clean context — so always prefer delegation, and treat it as mandatory once the main context is large.

The orchestrator (this skill run) keeps loop control: it launches the watch, detects the failure, spawns the heal sub-agent, then re-watches the resulting run and enforces the cap. Each sub-agent does **one** heal round and returns a concise result — never the raw logs.

Hand the sub-agent:
- the failing run id(s) and the command to read logs (`gh run view <run-id> --log-failed`);
- the repo's commit conventions (the commitlint type/scope/subject rules already detected);
- the watchdog guardrails (a **new** commit only — never amend, `--no-verify`, or force-push; code edits + commit + push only);
- a one-line note of what previous rounds already tried, so it doesn't repeat a failed fix.

Have it fix only clear, code-side issues (lint/format, type error, broken or stale test, import/path/case mismatch, missing file, simple build break) and **return**: root cause, what it changed, and the new commit SHA it pushed — or, if it can't fix it safely from code, why (so the orchestrator can stop and summarize).

After the sub-agent reports a pushed fix, watch the new run. Repeat until green, **capped at 3 heal rounds** across the whole skill invocation (the orchestrator counts the rounds, not the sub-agents).

### Stop and summarize (do not loop) when

- 3 self-heal rounds have not gone green, **or**
- the failure is not safely auto-fixable from code: infrastructure/runner errors, missing secrets or credentials, external-service/network flakiness, anything that needs a human decision or a destructive/irreversible action, or a failure you cannot confidently diagnose.

Leave a concise summary — what failed, what you tried, what's needed — and stop. Don't keep pushing speculative fixes.

### Watchdog guardrails

- Never `git push --force`, never `--no-verify`, never skip hooks; every fix is a new commit.
- The 3-round cap is per skill invocation (across all the runs and re-pushes), not per run — this bounds cost and prevents runaway loops, which matters especially when the repo auto-releases or deploys on green pushes to the default branch.
- If a fix would require any action outside normal code edits + commit + push (changing secrets, settings, infra, force-pushing, reverting others' work), stop and summarize instead.

## Rules

- Never mark commits as AI-generated
- Never use `--no-verify` or skip hooks
- If a pre-commit hook fails, fix the issue and create a NEW commit (never amend)
- Prefer brief single-line messages — use body only when genuinely needed
- The watchdog runs autonomously after a push: fix CI failures and re-push without asking, within the 3-round cap and the guardrails above
