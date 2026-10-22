---
name: clickup
description: How Claude writes to ClickUp for morntag (comments, task descriptions, new tasks, status). Use before any clickup_create_comment, clickup_update_comment, clickup_create_task or clickup_update_task call, before reporting test or QA results on tasks, and whenever a prompt asks to report results in ClickUp, "in den Task schreiben" or "Kommentar auf der Task".
---

# Writing to ClickUp

Rules Brian settled with Simea (PM) on 2026-10-20. Simea watches the tasks, so every comment lands in her
inbox, whoever it is for. The goal is a **distilled** inbox: she reads what needs her and what is done, in
Brian's voice, and nothing she would have to hand back to Brian.

## Steps

1. **Read the task and its whole thread**, including Simea's and the client's comments. A point someone
   already answered in the thread is settled.
2. **Triage in the terminal.** List every finding, open point and anything done beyond what the task asked,
   one line each, sorted into:
   - **Fix now**: broken against the task's obvious intent (dead link, `mailto:` missing, untranslated text,
     Du/Sie mix, wrong field type, hidden form). Claude proposes the fix.
   - **Brian decides**: new or changed behaviour (new fields, settings, design, removing content), anything
     done beyond scope, and every call Brian could make himself. Claude gives a recommendation.
   - **Simea/client decides**: only what Brian cannot decide. These are the only open points that reach
     ClickUp.

   Wait for Brian's answer. Then do the approved fixes and undo or keep extras as he said. Done when every
   item has a bucket and Brian has answered.
3. **Draft the comment** under a header line: `Kommentar für: Simea (Mention) · Status: unverändert`, with
   the reader and mention picked by the rules in **Mentions**. Brian corrects the reader or status there.
4. **Post** when the prompt asks for a ClickUp comment or Brian approves the draft. Every finished task gets
   a comment, even if it is only `@Simea Merki done`.

Questions for Brian stay in the terminal, never in ClickUp. Analyses, plans and interim status stay in the
terminal and the repo docs.

## The reader decides the shape

**Simea or client side** (the default):
- The mention, then one or two sentences: what is done, where to look. Technical cause at most as one plain
  half-sentence, only when it matters to her or the client.
- Extra fixes as a lead-in sentence plus bullets: `Hab dabei noch ein paar Sachen gefixt:`. One line each,
  in her words, what changed for the user.
- Her decisions last: a single one as a question (`…, oder?`, `Jetzt schon oder beim Launch?`), several as
  `Zwei Sachen für dich:` plus bullets, each naming who decides when it is not her.
- About 60 words. Only her decisions justify more.
- Versions, plugin names, paths, field keys, numbers from logs, PR and doc links live in the repo.

**Joshy (dev handover)**: `@joschua merki` first, concise and structured, bullets welcome, technical detail
where he has to act on it, one PR or case-file link allowed.

**Brian (note for later)**: starts with `Notiz:`, same density as for Joshy, no mention.

A task Simea needs to hear about that also carries dev detail gets the Simea shape; the detail goes to the
repo (changes.md, PR). A second comment for Joshy only when he has to do something in that task.

## Brian's voice

The comment reads as if Brian typed it. [examples.md](examples.md) holds his own comments and the approved
rewrites; match them.

- First person (`hab ich gefixt`, `ich mache mir ne Subtask`), du with everyone, clients included.
- Standard German with Swiss spelling (`ss`), his patterns: `done`, `ist erledigt`, `gefixt, war …`,
  `ich machs sonst`, `Your call.`, `…, oder?`, `kann man easy noch anpassen`. Dialect stays Brian's own.
- Plain sentences and plain bullets. Labels, headings, bold, greetings and sign-offs are not his style.
- Commas and periods where an agent would use a dash. Emoji only if Brian puts them in himself.
- ClickUp timestamps the comment, so the text names a date only when it is a different day (when a change
  went live).

## Mentions

- Mention Simea when she has to approve or decide something. No mention means "not for you", and she reads it
  that way.
- Mention her to say a task is done only when she is already in the comment thread, or she created the task
  and assigned it to Brian. A task from the support agent ("Morntag Support-Triage") shows Simea as creator
  because the agent runs under her account. Tell those apart by the first comment, which is the agent's:
  - Only the agent and Brian in the thread: the comment is internal documentation, no mention.
  - Someone else active in the thread who needs to hear the outcome: mention that person.
- When it's unclear who should be mentioned, if anyone, ask Brian in the terminal before posting.
- Syntax: `[@Simea Merki](#user_mention#2438286)` as the very first characters of the comment
  (`[@joschua merki](#user_mention#2438292)`; others via `clickup_resolve_assignees`). `notify_all` stays off.
- The API reads mentions back flattened (`" Text…\n@Name"` or a leading space only). The rendered comment
  is still correct; judge the mention by what you sent.

## Batches

When one session finishes more than about five tasks under one parent (a test run, a rollout), each task
gets a one-liner without mention (`Getestet, alles ok.`, `Erledigt, 2 tote Links gefixt.`). The parent task
gets one summary with the mention: which tasks are done, and Simea's decisions from all of them in one list.

## A task worked over several sessions

If the latest comment is Claude's own and has no reply and no reaction, rewrite it with
`clickup_update_comment` so the task carries one comment. Build the new text from scratch with the markdown
mention first; text read back from the API turns the mention into plain text. If the outcome changed after
Simea was already told it is done (not live after all, a regression), post a new comment with the mention.

## Status, tasks, descriptions

- **Status** only when the prompt names one. Set exactly that (check `available_statuses` via
  `clickup_get_task` with `expand_statuses`). Otherwise propose one in the header line.
- **Tasks and descriptions** only when Brian asks in the prompt; the text follows the shape and voice above.
  The bexio skill's one appended `Bexio-Entwurf:` line is the standing exception.
- **Automation comments** ("Morntag Support-Triage") are context. Read them, never reply, react or quote.

## Before the call

Every line passes: triage answered by Brian, reader chosen, mention first and only if the reader must act or
hear it is done, Simea's comment free of technical detail and around 60 words, open points only Simea's or
the client's, Brian's voice with Swiss spelling, status untouched unless the prompt named one.
