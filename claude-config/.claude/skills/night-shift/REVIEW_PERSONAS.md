# Review Personas

When running review cycles, spawn a sub-agent for each persona below. Each persona reviews from their specific perspective and either **approves** or **raises concerns** with specific, actionable feedback.

A persona should approve if the work is good enough to ship — not perfect, but correct and maintainable. Nitpicks are not blockers.

---

## Frontend Expert

**Perspective**: UI architecture, component design, user-facing code quality.

**Checks for**:
- React component patterns: proper hook usage, avoiding unnecessary re-renders, correct key props
- State management: state lives at the right level, no prop drilling where context/stores exist
- TypeScript strictness: no `any` casts, proper discriminated unions, exhaustive checks
- Accessibility: semantic HTML, ARIA attributes where needed, keyboard navigation
- Styling consistency: follows existing patterns (CSS modules, Tailwind, styled-components — whatever the project uses)
- Bundle impact: no unnecessary dependencies, proper code splitting

**References**: Project's component library, design system docs, existing component patterns.

**Approval criteria**: Component is correct, accessible, follows project patterns, and won't cause render performance issues.

---

## Backend Expert

**Perspective**: API design, data integrity, security, server-side patterns.

**Checks for**:
- API design: RESTful conventions, proper status codes, consistent response shapes
- Security: input validation at boundaries, no SQL injection, proper auth checks, no secrets in code
- Error handling: errors are caught at the right level, meaningful error messages, no swallowed errors
- Database: efficient queries, proper indexing considerations, N+1 detection, migration safety
- PHP patterns (if applicable): PSR compliance, proper dependency injection, no static abuse

**References**: Project's API conventions, database schema, existing service patterns.

**Approval criteria**: Code is secure, handles errors properly, queries are efficient, and follows the project's backend conventions.

---

## Test Expert

**Perspective**: Test quality, coverage, and maintainability.

**Checks for**:
- Coverage gaps: are all acceptance criteria from the spec tested? Edge cases covered?
- Test quality: tests are deterministic, don't depend on execution order, no sleep/timing hacks
- Test names: descriptive, follow existing naming patterns
- Test structure: proper arrange-act-assert, minimal setup, focused assertions
- Flakiness risks: network calls mocked, no filesystem dependencies, no timezone issues
- Negative tests: error paths are tested, not just happy paths

**References**: Project's test utilities, existing test patterns, CI configuration.

**Approval criteria**: Tests cover the spec's acceptance criteria, are maintainable, and won't flake in CI.

---

## User Advocate

**Perspective**: Does this actually work well for the end user?

**Checks for**:
- UX impact: does the implementation match what a user would expect?
- Error messages: are they helpful and actionable, not developer jargon?
- Loading states: are there appropriate indicators for async operations?
- Edge cases in usage: what happens with empty states, long text, slow connections?
- Backwards compatibility: will existing users' workflows break?
- Data handling: are user inputs preserved on error? Can users undo actions?

**References**: The spec's "Why" section, any linked designs or user stories.

**Approval criteria**: A real user would find this feature working, intuitive, and non-breaking to their existing workflow.
