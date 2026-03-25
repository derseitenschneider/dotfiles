# Triage report template

Used by the skill to generate `.docs/triage/YYYY-MM-DD.md`.

```markdown
# Bug Sweep — YYYY-MM-DD

**Source**: [Sentry + GitHub | Sentry only | GitHub only]
**Branch**: `triage/YYYY-MM-DD`
**Baseline tests**: passed

## Fixed (N)

| # | Issue ID | Title | Commit | Files |
|---|----------|-------|--------|-------|
| 1 | ELENO-REACT-XX | description | `abc1234` | `path/to/file.ts` |

## Flagged (N)

### ISSUE-ID: Title
- **Source**: Sentry / GitHub #N
- **Root cause hypothesis**: ...
- **Why not auto-fixed**: [architectural decision needed | UI/UX impact | unclear root cause | multi-service | ...]
- **Suggested approach**: ...
- **Relevant files**: ...

## Skipped (N)

| # | Issue ID | Reason |
|---|----------|--------|
| 1 | ELENO-REACT-YY | Already fixed — see BUG_FIXES.md 2026-03-23 |
| 2 | #999 | Duplicate of ELENO-REACT-YY |

## Overflow

N additional issues were not processed (cap: 10). Run `/bug-sweep` again to continue.
```
