---
name: commit-and-push
description: Stage changes, create a conventional-commit-formatted git commit, and optionally push. Detects project commitlint config for repo-specific rules. Use when creating git commits, committing changes, or pushing code.
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

## Rules

- Never mark commits as AI-generated
- Never use `--no-verify` or skip hooks
- If a pre-commit hook fails, fix the issue and create a NEW commit (never amend)
- Prefer brief single-line messages — use body only when genuinely needed
