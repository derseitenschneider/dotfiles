---
name: bug-sweep
description: Batch triage Sentry errors and GitHub bug issues in Eleno: fix the clear ones, flag the rest. Use when user says "bug sweep", "triage bugs", "sweep errors", "check sentry", or wants to batch-process open bugs from Sentry and GitHub.
---

# Bug Sweep

Fetch unresolved Sentry errors and open GitHub `bug` issues for Eleno, fix the clear ones, flag the rest.

## Arguments

From `ARGUMENTS`, combinable (`sentry 7d --dry-run`):
- **Source**: `sentry` or `github` (default: both)
- **Window**: `Nd`, last N days (default: all unresolved)
- **`--dry-run`**: assess and report only, no code changes

## Constants

- Sentry: organization `eleno`, region `https://de.sentry.io`, projects `eleno-react` and `eleno-scheduler`. Pass these to every Sentry tool; `find_organizations` is not needed.
- GitHub: `gh issue list --repo derseitenschneider/eleno --label bug --state open --json number,title,body,url,createdAt`
- PHP API logs (besides what the API sends to Sentry): `ssh hostpoint`, logs in `~/www/api.eleno.net/src/logs` (`app-YYYY-MM-DD.log`, `requests-YYYY-MM-DD.log`).

## Steps

1. **Where to work.** The current worktree, on a branch off a fresh `origin/main` (`git fetch origin main && git switch -c fix/bug-sweep-YYYY-MM-DD origin/main` when the tree is clean). Skip baseline suites: the pre-push `npm run verify` and CI are the safety net.
2. **Gather.** One Sentry search per project (`is:unresolved`, plus the window) with `search_issues`; the GitHub list above. Read `.docs/BUG_FIXES.md` for issue IDs already logged as fixed. A GitHub issue is skipped only when it is logged there AND closed; a logged issue that is open again gets assessed, with the earlier fix named. Merge Sentry and GitHub entries that describe the same bug. At most 10 issues per run; report the overflow count.
3. **Assess each issue.** `get_sentry_resource` or `get_issue_details` for the stack trace, then the source files. Fix it only when all hold:
   - the root cause follows from the trace or the issue text plus the code;
   - the fix needs no design decision and touches 1-3 files;
   - user-facing UI changes only when the UI is the bug (then the root CLAUDE.md "UI evidence" rule applies).
   Everything else is flagged with: ID, title, root-cause hypothesis, why it is not a clear fix, suggested approach.
4. **Fix** (not on `--dry-run`): a regression test where the code allows one, then the fix, one commit per issue: `fix(<app|api|scheduler>): <lowercase subject>` with the trailer `Fixes <SENTRY-SHORT-ID>` or `Fixes #<n>`. Log each fix in `.docs/BUG_FIXES.md` (it reached prod, so it is logged). Run the `reviewer` agent on the branch before reporting.
5. **Report in the terminal**, no triage file unless Brian asks: fixed (ID, title, commit), flagged (as above), skipped (ID, reason), overflow count. Closing issues waits for the ship: after Brian says "ship" and the release is deployed, resolve the Sentry issues with `update_issue` and close the GitHub ones with `gh issue close <n> --comment "Fixed in vX.Y.Z"`.

## When a source fails

Sentry MCP or `gh` unavailable: skip that source, say so in the report, continue with the other. Both unavailable: stop and say which tool failed.
