---
name: implement
description: "Structured TDD implementation pipeline: test writer -> implementer -> reviewer with compounding learnings. Callable only — invoke explicitly with /implement or 'use the implement skill'. Never auto-trigger."
---

# Implement Skill

Orchestrate a test-first implementation pipeline using subagents. You are the orchestrator — coordinate agents, enforce the loop, surface blockers.

## Step 0 — Setup

1. **Find the plan.** Search in order: user-provided path, `./plans/*.md`, `.planning/ROADMAP.md` current phase, conversation context. If nothing found, ask the user.
2. **Read CLAUDE.md** files — root and any directory-specific ones the plan touches (e.g., `app/CLAUDE.md`, `api/CLAUDE.md`). These contain conventions, test commands, and mandatory workflows.
3. **Load learnings.** Read `implement-learnings.md` (project root) if it exists. Pass relevant sections to each subagent. If it doesn't exist, create it from the template in [AGENTS.md](AGENTS.md#learnings-template).
4. **Detect test commands.** Based on which directories the plan touches:
   - `app/` → `npm test` (Vitest), `npm run pw` (Playwright E2E)
   - `api/` → `composer test` (Pest PHP)
   - Other → check `package.json`/`composer.json`/`pyproject.toml`
5. **Assess plan specificity.** If the plan provides exact implementation code, skip Step 1 (test-first adds no value when tests are prescribed). Jump to a combined test+implement step instead.

## Step 1 — Test Agent (skip if plan is prescriptive)

Spawn a `testing-expert` subagent. See [AGENTS.md — Test Agent](AGENTS.md#test-agent) for the full prompt. Do NOT use worktree isolation — agents must share the working directory.

Hand it: the plan, relevant codebase context, existing test conventions (read a few existing test files), test command, and learnings from "Test Agent Patterns."

**Gate:** Run the test command. New tests must FAIL. Existing tests must still PASS. If new tests already pass, they're not testing anything new — flag this.

## Step 2 — Implement Agent

Spawn a `fullstack-feature-builder` subagent (or `reliability-engineer` for infra/perf work). See [AGENTS.md — Implement Agent](AGENTS.md#implement-agent). Do NOT use worktree isolation.

Hand it: the plan, failing tests (or test specs from plan), codebase context, CLAUDE.md conventions, and learnings from "Implementer Patterns."

**Gate:** Run full test suite. All tests (new + existing) must PASS. If any pre-existing test breaks, fix before proceeding.

## Step 3 — Review Loop

Spawn a `reliability-engineer` subagent as reviewer. See [AGENTS.md — Reviewer](AGENTS.md#reviewer) for the full prompt and report format.

**Loop rules:**
- `STATUS: PASS` → proceed to Step 4
- `STATUS: ISSUES_FOUND` → **adjudicate as orchestrator first.** Check each issue against the plan:
  - If the plan explicitly describes the flagged behavior as intended → override to PASS with rationale
  - If the issue is genuine → send report to implement agent, fix, re-run tests, re-review
- **Max 2 iterations.** If unresolved after 2 cycles, stop and surface to user.

## Step 4 — UI Review (if applicable)

Only if the plan includes UI changes. Use browser-use (`/browser-use` skill) to visually inspect the affected pages. Start the dev server if not running, navigate to the affected route, and take snapshots to verify layout, content, and responsiveness match the plan's requirements.

## Step 5 — Project Housekeeping

Check CLAUDE.md for mandatory post-implementation steps. Common ones:
- **Bug fixes** → log in `.docs/BUG_FIXES.md` (required by this project)
- **New terms** → check/update `.docs/GLOSSARY.md`
- **Commit** → stage changes and create a descriptive commit

## Step 6 — Update Learnings

Append to `implement-learnings.md` — see [AGENTS.md — Learnings Format](AGENTS.md#learnings-format). Move patterns that haven't recurred in 3+ runs to "Resolved."

## Step 7 — Final Report

```
## Implement Run — [feature name]

Tests written: N | Tests passing: N | Review iterations: N
UI review: [passed / skipped / needs manual check]

### What was built
[1-3 sentence summary]

### Reviewer notes
[Non-critical observations]

### Learnings added
[What was appended]
```

If blocked, replace with explanation and decision needed.
