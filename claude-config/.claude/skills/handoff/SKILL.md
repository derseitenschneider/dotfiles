---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save it to `${TMPDIR:-/tmp}/handoff-$(date +%Y-%m-%d-%H%M%S).md` — run the `date` command yourself to resolve the timestamp, then use that resolved path.

Suggest the skills to be used, if any, by the next session.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

## Approvals

The next session runs without permission prompts and inherits none of the user's go-aheads from this conversation. Include a section with two lists:

- **Approved by the user:** actions the user explicitly agreed to here that are still open, in the user's scope (which site, which change). Quote or closely paraphrase; do not widen.
- **Not approved yet:** planned or discussed actions that change state outside the working tree (servers, deploys, pushes, sent messages, deletions) and have no explicit go-ahead.

If there is nothing in either list, say so in one line rather than dropping the section.

## Start the next session (Superset only)

If `$SUPERSET_WORKSPACE_ID` is set, do not stop at printing the path. Open a new tab in the same workspace with Claude already running on the handoff:

```bash
superset agents create --local --workspace "$SUPERSET_WORKSPACE_ID" --agent claude --json \
  --prompt "<Topic>: read <resolved handoff path> and pick up the work it describes. Start by summarising in a few lines what you will do first, then wait for my go."
open "superset://v2-workspace/$SUPERSET_WORKSPACE_ID?terminalId=<sessionId from the JSON>"
```

- Substitute the resolved handoff path.
- `<Topic>` is what the next session is about in three to six words (e.g. `Frankenwein side-cart go-live`). The tab title is generated from the prompt, so lead with the topic and keep "Handoff" and dates out of it.
- The `claude` preset runs `claude --dangerously-skip-permissions`. If the launch fails, say so and fall back to printing the path (`Not logged in` means the user has to run `superset auth login`).

### In a new worktree

Use this instead of a tab when the user asks for a worktree, or when you hand off several code tasks for the same repo at once (sessions sharing one checkout switch branches under each other). It creates a Superset workspace with its own git worktree and branch, and starts Claude in it:

```bash
PROJECT_ID=$(superset ws list --local --json | jq -r --arg ws "$SUPERSET_WORKSPACE_ID" '.[] | select(.id == $ws) | .projectId')
superset ws create --local --project "$PROJECT_ID" --json \
  --name "<topic-slug>" --branch "<branch>" --skip-branch-prefix --base-branch main \
  --agent claude --prompt "<Topic>: read <resolved handoff path> and pick up the work it describes. Start by summarising in a few lines what you will do first, then wait for my go."
```

- `<branch>` follows the repo's branch convention (read CLAUDE.md or the pre-push hook, e.g. `feature/<name>`). `--skip-branch-prefix` keeps it exactly as given.
- When writing several handoffs in one turn, add the topic slug to each file name so they don't collide.
- A fresh worktree holds no gitignored files (`vendor/`, `node_modules/`, `.env`, build output) unless the project has a `.superset/config.json` setup script. Say in the handoff which install commands to run first.
- The worktree lives outside the project directory. If the app only runs from the original checkout (e.g. a WordPress plugin mounted into a local site), say so in the handoff: the session can run tests and builds, but browser checks need the original checkout or a staging deploy.
- Add `--tag <client>` when launching several, so they share a sidebar folder.
- The JSON returns `.workspace.id` and `.agents[0].sessionId`. Open it with `open "superset://v2-workspace/<workspace id>?terminalId=<sessionId>"`, or just give the user the workspace names when several were launched.

Either way, end by telling the user the handoff path and, if a tab or workspace was opened, that the new session is waiting for their go.
