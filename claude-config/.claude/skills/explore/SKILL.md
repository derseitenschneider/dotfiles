-----

## name: explore
description: >
Use this skill for greenfield feature development where the right approach is unknown.
Instead of planning upfront, this skill builds a minimal spike to test the riskiest
assumption first, QAs it, and iterates — exactly like a real senior dev exploring
unfamiliar territory. Trigger this skill when the user says “explore”, “spike”, “prototype”,
“I’m not sure how to approach”, “greenfield”, or when starting a new feature with no
clear implementation path. The output is a structured handoff document (explore-output.md)
ready to feed into the `implement` skill.

# Explore Skill

A spike-first exploration loop for greenfield features. Discovers the right solution shape
through code, not planning. Produces a handoff document for the `implement` skill.

## Core Philosophy

> “The prototype *is* the plan.”

A text plan on greenfield is almost always wrong — you don’t know what you don’t know.
This skill surfaces real unknowns fast by building the riskiest assumption first, stress-testing
it, and iterating. Each loop, the agent knows more about the actual problem shape.

-----

## Invocation

```bash
/explore "<feature description>"
```

Optional flags:

- `--max-iterations N` — cap the spike loop (default: 3)
- `--spec path/to/file` — additional context (existing codebase notes, constraints, etc.)

-----

## The Loop

```
1. ASSUMPTION EXTRACTION
2. SPIKE        (≤50 lines, riskiest assumption only)
3. QA PASS      (read → run if needed)
4. HUMAN GATE   (on failure: pause and present options)
5. REPEAT       (next assumption, or pivot)
6. HANDOFF      (write explore-output.md)
```

-----

## Phase Instructions

### Phase 1 — Assumption Extraction

Before writing any code, the agent produces a ranked list of assumptions the feature depends on.

**Prompt the agent:**

```
Given this feature: [spec]

List the 3-5 assumptions this feature depends on to work.
Rank them by risk: which one, if wrong, would invalidate the entire approach?
Output format:
  1. [assumption] — risk: [why this could be wrong]
  2. ...
```

The top-ranked assumption becomes the spike target. The list is saved to `explore-output.md`
and updated as the loop progresses.

-----

### Phase 2 — Spike

Build the minimum code that tests assumption #1. Nothing else.

**Hard constraints:**

- ≤ 50 lines
- No error handling
- No abstraction
- No tests
- Throwaway quality

**Spike prompt:**

```
Build a spike to test this assumption: [assumption #1]

Rules:
- Maximum 50 lines
- Prove or disprove the assumption only
- No error handling, no abstraction, no polish
- If you can't fit it in 50 lines, the assumption is too broad — split it and tell me
```

If the agent flags the assumption as too broad, split it and re-enter Phase 2 with the
narrower version.

-----

### Phase 3 — QA Pass

Two-stage QA. Start with a read pass; escalate to execution only if needed.

**Stage A — Read pass:**

```
Review this spike code. For each issue found, classify it:
  - STATIC: visible from reading (logic error, wrong assumption, missing case)
  - NEEDS_RUN: can only be verified by executing

Output:
  RESULT: PASS | FAIL
  ASSUMPTION_HOLDS: yes | no | partial
  STATIC_ISSUES: [list or "none"]
  NEEDS_RUN: [list or "none"]
  LEARNED: [what this spike revealed, regardless of pass/fail]
```

**Stage B — Execution pass (only if NEEDS_RUN is non-empty):**

Run only the flagged parts. Update the QA result with execution findings.

The `LEARNED` field is always written to `explore-output.md`, even on pass.

-----

### Phase 4 — Human Gate

**On PASS:** continue to next assumption automatically. No pause.

**On FAIL:** stop and surface a decision.

```
⚠️  ASSUMPTION FAILED: [assumption]

    What we learned: [LEARNED content]

    Options:
      A) [alternative approach based on what we learned]
      B) [narrowed scope that sidesteps the failed assumption]
      C) Describe a different direction

    Continue with A, B, or C — or type your own direction:
```

Wait for input before proceeding. Log the decision and rationale to `explore-output.md`.

-----

### Phase 5 — Repeat

After each gate (pass or human-resolved fail), move to the next assumption in the ranked list.

Loop until one of:

- All assumptions validated
- `--max-iterations` reached (surface remaining unvalidated assumptions in handoff)
- User decides the approach is clear enough to stop early

-----

### Phase 6 — Handoff

Write `explore-output.md` using the template below. This is the artifact that feeds `implement`.

```markdown
# Explore Handoff: [feature name]

## Status
Assumptions validated: X / Y
Iterations run: N

## Feature Spec
[original input]

## Validated Approach
[the architecture/pattern that survived the spikes]

## Assumption Log
| # | Assumption | Result | Notes |
|---|-----------|--------|-------|
| 1 | ...       | ✅ PASS | ...  |
| 2 | ...       | ❌ FAIL → pivoted to B | ... |

## Key Learnings
[What we discovered that wasn't obvious from the spec]

## Gotchas & Edge Cases
[Concrete things that broke or surprised during spikes]

## Dependency Notes
[Library versions, API quirks, workarounds discovered]

## Discarded Approaches
[What we tried, why we rejected it — saves implement from re-exploring]

## Unvalidated Assumptions
[Only present if loop was capped. Flag for implement to handle.]

## Recommended Implementation Order
[Sequence that de-risks the build, informed by spike findings]
```

-----

## Handoff to Implement

Once `explore-output.md` exists, pass it directly to the `implement` skill:

```bash
/implement --spec explore-output.md
```

The implement skill should treat `explore-output.md` as authoritative. It should not
re-explore assumptions already marked validated.

-----

## Common Failure Modes

|Problem                           |Fix                                                   |
|----------------------------------|------------------------------------------------------|
|Spike exceeds 50 lines            |Assumption is too broad — split it                    |
|QA says PASS but feels wrong      |Trust the human gate — you can trigger a fail manually|
|Loop stalls on the same assumption|Force a human gate, the assumption may be ill-formed  |
|Handoff doc is vague              |Every LEARNED entry must be concrete and actionable   |