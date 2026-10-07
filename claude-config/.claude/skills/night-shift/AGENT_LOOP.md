# Agent Loop

Follow these steps precisely for each spec. Do not skip steps. If a step fails, diagnose and fix before continuing — do not brute-force past failures.

## The Loop

### Step 1: Prep

- Verify clean working tree: `git status --porcelain`
- Run the full test suite and record the result as the **baseline**
- If tests fail at baseline, STOP and report — do not build on a broken foundation

### Step 2: Pick

- Select the next unprocessed spec from `Specs/`
- Order: numeric prefix first (e.g., `001-`, `01-`), then alphabetical
- Skip files prefixed with `draft-`
- Announce which spec you're working on

### Step 3: Analyze

- Read the spec thoroughly
- Identify which files, modules, and systems are involved
- Read the relevant source code to understand current state
- Note any constraints or "do not touch" directives from the spec

### Step 4: Test Plan

- Based on the spec's acceptance criteria and edge cases, design the tests that need to exist
- List them out explicitly before writing any code
- Tests should cover: happy path, edge cases listed in spec, error conditions

### Step 5: Write Tests

- Write the tests from Step 4
- Run them — they should **fail** (red phase of red-green-refactor)
- If any test passes already, the feature may already exist — investigate before continuing
- Commit understanding: do NOT commit yet

### Step 6: Implementation Plan

- With failing tests as the target, plan the implementation
- Identify each file to modify and what changes are needed
- Keep the plan minimal — do only what the spec requires
- Note any dependencies between changes (order matters)

### Step 7: Review Cycle 1 — Plan Review

- Spawn a sub-agent for each review persona defined in `REVIEW_PERSONAS.md`
- Each persona reviews the **implementation plan** (not code yet)
- If a persona raises a concern:
  - Evaluate whether it's valid
  - If valid, revise the plan and re-review
  - If not valid, note the reasoning and proceed
- Loop until all personas approve or concerns are addressed
- Keep review cycles bounded — max 3 iterations per persona

### Step 8: Implement

- Execute the plan from Step 6
- Write the code to make the tests pass
- Update any documentation that's affected (READMEs, inline docs, API docs)
- Do NOT add unnecessary comments, defensive checks, or abstractions

### Step 9: Validate

- Run the linter (if configured)
- Run the type checker (if configured)
- Run the new tests — they should now **pass**
- If anything fails, fix and re-run
- Max 5 fix iterations — if still failing after 5, stop and report the issue

### Step 10: Regression

- Run the **full** test suite (not just new tests)
- Compare against the baseline from Step 1
- If new failures appear, diagnose:
  - If the spec caused an intentional behavior change, update the affected tests
  - If it's an unintended side effect, fix the implementation
- Do not proceed until the full suite is green

### Step 11: Review Cycle 2 — Diff Review

- Generate the diff: `git diff`
- Spawn sub-agents for each review persona from `REVIEW_PERSONAS.md`
- Each persona reviews the **actual diff**
- Same iteration rules as Review Cycle 1 (max 3 iterations per persona)
- Focus: does the code match the plan? Any issues introduced during implementation?

### Step 12: Commit

- Stage all relevant changes
- Write a detailed commit message:
  ```
  feat: [short description from spec title]

  Implements Specs/[filename]:
  - [key change 1]
  - [key change 2]
  - [key change 3]

  Tests: [number] new tests, all passing
  ```
- Create the commit
- This produces a stacked commit — one clean commit per spec

### Step 13: TODOs

- Note anything discovered during implementation that's unrelated to this spec:
  - Bugs found in existing code
  - Tech debt spotted
  - Ideas for improvements
- Write these to stdout so the user can see them in the morning
- Do NOT act on them — they're out of scope

### Step 14: Next

- Create `Specs/done/` if it doesn't exist
- Move the processed spec: `mv Specs/[spec-file] Specs/done/`
- Stage and commit the spec move:
  ```
  chore: move completed spec [filename] to done
  ```
- Return to **Step 2** for the next spec

### Step 15: Wrap Up

When no specs remain (or on interruption):
- Print a summary:
  - Specs completed: list with commit hashes
  - Specs remaining: list (if interrupted)
  - TODOs discovered: collected from Step 13
  - Test suite status: final state
- Do NOT push to remote — the user decides when to push
