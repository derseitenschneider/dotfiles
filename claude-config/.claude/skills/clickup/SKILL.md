---
name: clickup
description: How Claude writes to ClickUp for morntag (comments, task descriptions, new tasks, status). Use before any clickup_create_comment, clickup_update_comment, clickup_create_task or clickup_update_task call, and whenever a prompt asks to report results in ClickUp, "in den Task schreiben" or "Kommentar auf der Task".
---

# Writing to ClickUp

Rules Brian settled on 2026-10-08. They apply to every text Claude puts into ClickUp from any project. The
reader is Brian or a teammate who knows the client and can find the repo documentation if they want detail.

## When to write

- **One comment per task, when the work is done.** Analyses, plans, interim status and corrections stay in
  the terminal and in the repo docs. If something turned out wrong earlier, the one final comment states
  the final truth; it never references the earlier version.
- **Questions go to the terminal.** Anything Brian has to decide is asked in the session, never in ClickUp.
- **Post only when the prompt asks for a ClickUp comment.** Otherwise draft the text in the terminal and
  let Brian decide whether it goes up.
- **Status changes only when the prompt names one.** Set exactly that status (check `available_statuses`
  via `clickup_get_task` with `expand_statuses`). Otherwise leave the status and suggest one in the terminal.
- **Tasks and descriptions only on request.** Creating a task or editing a description happens when Brian
  asks for it in the prompt; the text follows the same shape and language rules as a comment.
- **Automation comments** ("Morntag Support-Triage") are context. Read them, never reply, react or quote.

## Shape of the Abschlusskommentar

[examples.md](examples.md) holds the comments Brian kept. Match them.

- **No title, no greeting.** The comment starts with a plain sentence, never with a bold or heading-like line and never with «Hoi», «Hallo» or similar (Brian, 2026-10-08). If it
  addresses someone, the @-mention is the very first thing in the comment, then the sentence: outcome word
  plus date, e.g. `Accessibility-Check umgesetzt, Stand 8.10.2026.`, `Geprüft 2026-09-18: …`,
  `Behoben am 29.09.2026.` A second sentence may name the version or site it is live on.
- **Two sections** when work was done and something stays open: `Erledigt` and `Offen`, each a plain-text
  label on its own line followed by a bullet list. No bold, no markdown headings. A check with no change
  needed is a single paragraph without sections.
- **Erledigt bullets** carry the facts that change what the reader does: what changed, on which sites or
  versions, what was deliberately left alone with the reason in a few words. Name a skipped item only where
  a reader would otherwise assume it was done, one line each.
- **Offen bullets**: one per open point, with who decides when that is not Brian. Never a prose clause.
- **No documentation links.** PRs, audit folders and case files are not mentioned in comments unless Brian
  asks for the link in the prompt. The comment carries the facts, the repo carries the details.
- **Length is judgment**, measured against the examples. The test for each bullet: does it change what the
  reader does? Process narration (how a survey was run, which flags were needed, backups taken, environment
  quirks) stays out.

## Language

German, du-form, Swiss spelling (`ss`, never `ß`), for every list including internal ones. Plugin names,
constants, paths and commands stay as written in code.

## Mentions

`notify_all` stays at its default (off). When the comment answers a person's comment or hands them a
decision, @-mention them as the first token of the comment: `[@Name](#user_mention#<id>)` with the numeric
id from `clickup_resolve_assignees`. No other mentions, and never a mention in the middle or at the end.

## A task worked over several sessions

Before posting, read the task's comments. If the latest comment is Claude's own Abschlusskommentar and has
no reply and no reaction, rewrite it with `clickup_update_comment` so the task still carries one comment.
Otherwise post one new comment with the delta.

## Before the call

Done means every line passes: no title, mention first if any, opening sentence with date, `Erledigt` and
`Offen` as plain labels with bullets, only facts that change what the reader does, skipped items with
reason, no documentation links, German with Swiss spelling, status untouched unless the prompt named one.
