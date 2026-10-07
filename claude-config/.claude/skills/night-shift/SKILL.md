---
name: night-shift
description: Autonomous overnight implementation agent. Reads specs from Specs/, writes tests first, implements with quality gates, and produces stacked commits. Run from inside a project directory.
---

# Night Shift

Autonomous spec-driven implementation skill. Picks up specs from the project's `Specs/` directory and works through them one at a time: tests first, plan, review, implement, validate, commit.

## Invocation

Run `/night-shift` from inside any project directory that has a `Specs/` folder with ready specs.

## Startup Sequence

1. **Verify environment**
   - Confirm `Specs/` directory exists in the current project
   - Find all non-draft specs (files not prefixed with `draft-`)
   - If no ready specs found, report this and stop
   - Ensure working tree is clean (`git status --porcelain` should be empty). If not, warn and stop.

2. **Load context**
   - Read the project's `CLAUDE.md` if it exists
   - Read any architecture docs referenced in CLAUDE.md
   - Note the project's test framework, linter, and build commands

3. **Report**
   - List the specs that will be processed, in order
   - Show baseline test suite status

4. **Begin the loop**
   - Load `AGENT_LOOP.md` from this skill directory and follow it precisely
   - Process specs one at a time in alphabetical order (or by numeric prefix if present)

## Spec Format

Specs live in `<project>/Specs/`. Files prefixed with `draft-` are ignored.

Specs should follow the template in `spec-template.md` but any markdown file without the `draft-` prefix will be picked up.

## Stopping

- The skill runs until all specs are processed or you interrupt with Ctrl+C
- On interruption or completion, it writes a summary of what was accomplished
- Partially-implemented specs are NOT committed — only complete work gets a commit

## Output

Everything happens in your terminal. Watch the process, scroll back through reasoning, interrupt if something goes wrong. No hidden tmux sessions, no external state files.
