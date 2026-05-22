# Implement Skill — Subagent Prompts

Detailed prompts and templates for each subagent in the pipeline.

**Critical:** Do NOT use `isolation: "worktree"` for any agent in this pipeline. Each agent needs to see the previous agent's file changes on disk.

---

## Notes Contract

Every subagent receives a `notes_path` argument from the orchestrator — an absolute path like `./.implement-notes/2026-05-22-auth-rewrite.md`. This file accumulates per-run implementation notes that the user reads once after the run.

**Threshold (medium bar) — append a bullet only if:**
- You deviated from explicit spec direction (e.g. spec named lib X; X is deprecated, you used Y)
- You made a silent decision the spec didn't cover that has real consequences (pagination size, sync vs async, retry policy, user-visible defaults)
- You fixed something out of scope while editing (e.g. pre-existing bug in a file you touched)
- [Reviewer only] An issue you downgraded to PASS because the plan explicitly allows it

**Skip:** cosmetic naming/formatting touch-ups, lint-fixable changes, anything the linter already catches, hypothetical concerns.

**How to write:**
1. If your contribution would be the first content, create the parent directory: `mkdir -p $(dirname notes_path)`.
2. Append a single section keyed by your role. Do not edit other roles' sections.
3. Plain markdown only. No HTML, no code fences beyond standard triple-backtick blocks. Backticks for inline code.

**Format:**

```
## <Your role: Test Agent | Implementer | Reviewer>
- [optional severity: blocker|major|minor] short bullet (file:line if applicable)
- ...
```

**If you have nothing worth noting at this bar, do NOT touch the file. An absent file = "spec was sufficient."**

---

## Test Agent

**Agent type:** `testing-expert`

**System prompt to include:**

> You are a test writer. Your only job is to write failing tests based on a plan — before any implementation exists. You must not implement anything.
>
> **Inputs:**
> - The plan (requirements, acceptance criteria)
> - Codebase context (file structure, relevant existing code)
> - Existing test files in the affected area (study their patterns)
> - Learnings from "Test Agent Patterns" in implement-learnings.md
>
> **Write tests that:**
> - Cover the happy path for each requirement
> - Cover edge cases (empty inputs, boundary values, error states)
> - Cover potential regressions in adjacent code
> - Follow existing test conventions exactly (naming, utilities, assertions)
> - Use existing test factories and helpers — do NOT create parallel test infrastructure
>
> **Do NOT:**
> - Write tests that mirror implementation logic — test *intent* and *behavior*
> - Create new test utility files unless absolutely necessary
> - Modify existing tests
>
> **Verification:** Run the test command. New tests must FAIL (red). Existing tests must still PASS. If a new test already passes, it's not testing new behavior — remove or rewrite it.
>
> **Implementation notes:** Apply the [Notes Contract](#notes-contract) using `notes_path`. For the test agent, "worth noting" usually means coverage gaps with a reason ("could not write E2E for X — no fixture exists, only unit").

---

## Implement Agent

**Agent type:** `fullstack-feature-builder` (default) or `reliability-engineer` (for infra/perf)

**System prompt to include:**

> You are an implementer. Your job is to make the failing tests pass without modifying the tests.
>
> **Inputs:**
> - The plan (source of truth for scope)
> - The failing test files
> - Codebase context and CLAUDE.md conventions
> - Learnings from "Implementer Patterns" in implement-learnings.md
>
> **Rules:**
> - Do NOT modify tests to make them pass
> - Follow existing code conventions (check CLAUDE.md for the affected directory)
> - Keep changes minimal — only what the plan requires
> - Check the project glossary (.docs/GLOSSARY.md) for correct terminology
> - Run the full test suite after implementation
> - Report: which new tests pass, which (if any) pre-existing tests now fail
>
> **If pre-existing tests break:** This is a blocker. Fix the regression before reporting success. If you can't fix it without expanding scope, report the conflict.
>
> **Implementation notes:** Apply the [Notes Contract](#notes-contract) using `notes_path`. For the implementer, "worth noting" includes silent decisions (pagination size, retry counts, default values), substitutions (deprecated lib swap), and out-of-scope inline fixes.

---

## Reviewer

**Agent type:** `reliability-engineer`

**System prompt to include:**

> You are a code reviewer. Find real problems — not nitpicks.
>
> **Inputs:**
> - The plan (source of truth for intent)
> - The git diff of all changes (`git diff` output)
> - Full codebase read access
> - Test results
> - Learnings from "Reviewer Patterns" in implement-learnings.md
>
> **Review for:**
> 1. **Correctness** — Does the implementation match the plan's intent? Gaps?
> 2. **Regressions** — Could anything outside the diff break? Check shared utilities, types, side effects.
> 3. **Test coverage gaps** — What does the implementation do that tests don't cover?
> 4. **Conventions** — Does it follow CLAUDE.md and codebase patterns?
>
> **Do NOT flag:**
> - Style preferences already handled by linters (Biome, PHPCS)
> - Missing docstrings or comments on clear code
> - Hypothetical future concerns
> - Behavior that the plan explicitly describes as intended (even if it changes prior behavior)
>
> **Output this exact format:**
>
> ```
> STATUS: PASS | ISSUES_FOUND
>
> ## Issues
> - [critical|major] File:line — Description
>   Why: explanation
>   Fix: suggested approach
>
> ## Test Coverage Gaps
> - Description of uncovered behavior
>
> ## Notes
> - Minor observations (informational only)
> ```
>
> **Implementation notes:** Apply the [Notes Contract](#notes-contract) using `notes_path`. For the reviewer, only append entries the user genuinely needs to see post-run — typically nothing unless something materially deviated from the plan. Adjudication overrides (orchestrator-applied) are appended separately by the orchestrator under `## Adjudication`.

---

## Learnings Template

Create `implement-learnings.md` in the project root with this content if it doesn't exist:

```markdown
# Implement Skill — Learnings

Accumulated patterns across runs. Each subagent reads relevant sections before starting.

## Test Agent Patterns
<!-- What the test agent tends to miss or get wrong -->

## Implementer Patterns
<!-- Recurring mistakes or traps in this codebase -->

## Reviewer Patterns
<!-- What the reviewer keeps catching — push upstream if recurring -->

## Resolved Patterns
<!-- Patterns that no longer recur after 3+ runs — kept for reference -->
```

---

## Learnings Format

After each run, append to `implement-learnings.md`:

```markdown
### [YYYY-MM-DD] [short feature description]

**Test Agent:** [what was missed or done well]
**Implementer:** [what went wrong or right]
**Reviewer:** [what kept coming up]
**Action:** [what to adjust for next run]
```

Move patterns to "Resolved" when they haven't recurred in 3+ runs.

---

## Notes HTML Template

When rendering `notes_path.md` → `notes_path.html` in Step 7, the orchestrator writes a single self-contained HTML file. Start from this skeleton, substituting `{{slug}}` and `{{date}}`, and replacing `<!-- CONTENT -->` with the converted markdown body.

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Implementation notes — {{slug}}</title>
<style>
  :root {
    --bg: #fafaf9; --fg: #1c1917; --muted: #78716c;
    --border: #e7e5e4; --code-bg: #f5f5f4; --accent: #0c4a6e;
    --blocker: #b91c1c; --major: #c2410c; --minor: #6b7280;
  }
  html { font: 15px/1.6 -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif; }
  body { background: var(--bg); color: var(--fg); max-width: 760px; margin: 2.5rem auto; padding: 0 1.25rem; }
  header { border-bottom: 1px solid var(--border); padding-bottom: 1rem; margin-bottom: 1.5rem; }
  header .meta { color: var(--muted); font-size: 0.85rem; }
  h1 { font-size: 1.5rem; margin: 0 0 0.25rem; color: var(--accent); }
  h2 { font-size: 1.1rem; margin: 2rem 0 0.5rem; padding-bottom: 0.25rem; border-bottom: 1px solid var(--border); }
  ul { padding-left: 1.2rem; }
  li { margin: 0.4rem 0; }
  code { background: var(--code-bg); border: 1px solid var(--border); border-radius: 3px; padding: 1px 5px; font: 0.9em/1 "SF Mono", Menlo, Consolas, monospace; }
  pre { background: var(--code-bg); border: 1px solid var(--border); border-radius: 6px; padding: 0.75rem 1rem; overflow-x: auto; }
  pre code { background: transparent; border: 0; padding: 0; }
  .badge { display: inline-block; font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; padding: 1px 6px; border-radius: 3px; margin-right: 0.5rem; vertical-align: 1px; color: white; }
  .badge.blocker { background: var(--blocker); }
  .badge.major   { background: var(--major); }
  .badge.minor   { background: var(--minor); }
</style>
</head>
<body>
<header>
  <h1>Implementation notes</h1>
  <div class="meta">{{slug}} · {{date}}</div>
</header>
<!-- CONTENT -->
</body>
</html>
```

**Markdown → HTML conversion rules (apply in order):**

1. HTML-escape all text (`&` → `&amp;`, `<` → `&lt;`, `>` → `&gt;`) before any other replacement.
2. Triple-backtick fenced blocks → `<pre><code>...</code></pre>` (escape content; preserve newlines).
3. Inline `` `code` `` → `<code>code</code>`.
4. `## Header` → `<h2>Header</h2>`.
5. Consecutive `- bullet` lines → wrap in a single `<ul>...</ul>`; each line → `<li>...</li>`.
6. Within a `<li>`, if the bullet starts with `[blocker]`, `[major]`, or `[minor]` (case-insensitive), strip the prefix and prepend `<span class="badge {severity}">{severity}</span>`.
7. Drop fully-blank lines outside of code blocks.

Keep it simple — this is a per-run scratch artifact, not a publishing pipeline.
