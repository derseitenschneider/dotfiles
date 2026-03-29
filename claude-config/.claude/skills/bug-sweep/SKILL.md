---
name: bug-sweep
description: Batch triage Sentry errors and GitHub bug issues — auto-fix clear bugs, flag complex ones. Use when user says "bug sweep", "triage bugs", "sweep errors", "check sentry", or wants to batch-process open bugs from Sentry and GitHub.
---

# Bug Sweep

Fetch unresolved Sentry errors and GitHub `bug` issues, auto-fix clear ones, flag the rest.

## Arguments

Parse arguments from `ARGUMENTS`:
- **Source filter**: `sentry` or `github` (default: both)
- **Time filter**: `Nd` for last N days (default: all unresolved)
- **`--dry-run`**: Assess and report only, no code changes
- Combinable: `sentry 7d --dry-run`

## Workflow

### Phase 1: Prepare

1. Read `.docs/BUG_FIXES.md` — build a set of already-fixed issue IDs (e.g. `ELENO-REACT-18`, `#321`)
2. Run baseline tests. Abort with message if they fail:
   - `cd app && npm run typecheck && npm run test`
   - `cd api && composer stan && composer test`
3. Unless `--dry-run`: create branch `triage/YYYY-MM-DD` off `dev`

### Phase 2: Gather

4. **Sentry**: Use `mcp__sentry__search_issues` with query `is:unresolved`. If Sentry MCP is unavailable, skip and notify user. Apply time filter if specified.
5. **GitHub**: Run `gh issue list --repo derseitenschneider/eleno --label bug --state open --json number,title,body,url`. Apply time filter if specified.
6. **Deduplicate**: Cross-reference Sentry issues and GitHub issues by title/description similarity. Cross-reference both against the BUG_FIXES.md known-fixed set. **Only skip a GitHub issue if its ID appears in BUG_FIXES.md AND the issue is currently closed on GitHub.** If an issue was logged as fixed but is still open (i.e. reopened or the fix was insufficient), do NOT skip it — assess it normally, noting in the report that a prior fix exists.
7. **Cap**: Process max 10 issues per run. If more exist, note the overflow count in the report.

### Phase 3: Assess each issue

For each issue, use `mcp__sentry__get_issue_details` (Sentry) or read the GitHub issue body to understand the bug. Then read the relevant source files.

**Auto-fix criteria** (ALL must be true):
- Root cause is identifiable from stack trace / error message + code reading
- Fix does not require architectural decisions or design changes
- Fix does not alter user-facing UI/UX (unless the bug IS a UI/UX defect)
- Fix is localized (touches 1-3 files)

**If auto-fixable and NOT dry-run**:
1. Apply the fix
2. Commit: `fix(scope): lowercase description (ISSUE-ID)` — follow commitlint: conventional type, scoped to `app`/`api`/`scheduler`, lowercase subject. Reference Sentry ID (e.g. `ELENO-REACT-XX`) or GitHub issue (e.g. `#123`).
3. Add to "Fixed" list

**If NOT auto-fixable OR dry-run**:
1. Add to "Flagged" list with: issue ID, title, root cause hypothesis, why it can't be auto-fixed, suggested approach

### Phase 4: Verify & close

8. Unless `--dry-run`: Run tests again (same as step 2)
9. If any test fails: identify which commit(s) caused it, `git revert <sha>`, move those issues from "Fixed" to "Flagged" with note "fix reverted — broke tests"
10. For each successfully fixed issue:
    - Update `.docs/BUG_FIXES.md` with brief entry (follow existing format in that file)
    - Sentry: `mcp__sentry__update_issue` to mark resolved
    - GitHub: `gh issue close <number> --comment "Fixed in triage/YYYY-MM-DD"`
11. Write triage report (see [TRIAGE-TEMPLATE.md](TRIAGE-TEMPLATE.md)) to `.docs/triage/YYYY-MM-DD.md`

### Phase 5: Report

Print summary to terminal:
```
Bug Sweep complete — YYYY-MM-DD
Fixed: N | Flagged: N | Skipped: N
Branch: triage/YYYY-MM-DD
Report: .docs/triage/YYYY-MM-DD.md
```

## Error handling

- **Sentry MCP unavailable**: Skip Sentry source, notify user, continue with GitHub only
- **`gh` CLI fails**: Skip GitHub source, notify user, continue with Sentry only
- **Both unavailable**: Abort with clear error message
- **Baseline tests fail**: Abort — do not start triage on a broken baseline
