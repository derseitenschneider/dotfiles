---
name: fix-workflow
description: Detect failed GitHub Actions runs, reproduce failures locally, auto-fix code issues, and report actionable steps for infrastructure failures. Use when user says "fix workflow", "fix CI", "fix pipeline", "why did CI fail", "check actions", or wants to investigate failed GitHub Actions runs.
---

# Fix Workflow

Diagnose and fix failed GitHub Actions runs. Code failures are reproduced locally and fixed. Infrastructure failures produce an actionable report.

## Arguments

Parse arguments from `ARGUMENTS`:
- **Run ID or URL**: Target a specific run (default: auto-detect all recent failures)
- **`--dry-run`**: Diagnose and report only, do not apply fixes

## Phase 1: Prerequisites

1. Verify `gh` CLI is authenticated: run `gh auth status`. If not authenticated, stop and tell the user to run `gh auth login`.
2. Check working tree: run `git status --porcelain`. If dirty, warn the user that fixes will mix with existing changes and ask whether to proceed.

## Phase 2: Discover Failed Runs

1. If a run ID/URL was provided, use it directly. Extract the numeric ID from a URL if needed.
2. Otherwise: `gh run list --status=failure --limit 10 --json databaseId,workflowName,headBranch,createdAt,event,url`
3. If no failures found, report "No failed workflow runs found" and stop.
4. **Deduplicate**: Group by `(workflowName, headBranch)`. Keep only the most recent run per group.

## Phase 3: Diagnose Each Failed Run

Process each failed run sequentially:

### 3a: Gather context
- `gh run view <id> --json workflowName,headBranch,headSha,conclusion,jobs,url`
- `gh run view <id> --log-failed` — capture the error output
- If `--log-failed` returns empty, report: "Logs unavailable — re-run with `gh run rerun <id>`" and skip this run.

### 3b: Match to workflow file
- Read each `.github/workflows/*.yml` in the repo. Match by comparing the YAML `name:` field to the `workflowName` from the run JSON. If no match by name, try matching by filename.

### 3c: Identify failing step
- From the `--log-failed` output, identify which job and step failed.
- In the matched workflow YAML, find that step. Extract its `run:` command and `working-directory` (or the job-level `defaults.run.working-directory`).

### 3d: Classify the step
- **Locally reproducible**: Step has a `run:` key AND does not reference `${{ secrets.* }}` AND the command does not connect to remote services (no `curl` to production URLs, no FTP, no SSH to servers).
- **Infrastructure-only**: Step uses `uses:` (a GitHub Action), references secrets, or connects to remote services.
- Consult [REFERENCE.md](REFERENCE.md) for classification guidance and edge cases.

## Phase 4: Fix or Report

### Locally reproducible failures

1. Run the extracted command in the correct working directory (relative to repo root).
2. Analyze the local error output. Read the relevant source files, understand the root cause.
3. Apply the fix directly to the source files.
4. Re-run the same command to verify the fix works.
5. If the fix fails, iterate (max 3 attempts). After 3 failures, fall back to reporting.
6. If `--dry-run`, skip steps 3-5 and report what you would fix.

### Infrastructure-only failures

Do NOT attempt to fix. Generate a report with:
- Workflow name, run URL, branch, failing step name
- Error message from the logs
- Root cause hypothesis
- Actionable steps (see [REFERENCE.md](REFERENCE.md) for common remediation patterns)

## Phase 5: Summary

```
Fix Workflow complete
Fixed: N | Reported: N | Skipped: N

Fixed:
- [workflow] step "X" on branch Y — one-line description of fix

Needs manual action:
- [workflow] step "X" on branch Y — one-line description + action

Files modified: [list]
```

Remind the user: "Fixes applied to working tree but NOT committed. Review with `git diff`."

## Error Handling

- **`gh` not authenticated**: Stop with instructions to run `gh auth login`
- **No workflow files found**: Stop with "No `.github/workflows/` directory found"
- **Logs expired/empty**: Skip run, suggest `gh run rerun <id>`
- **Fix attempts exhausted**: Fall back to actionable report
