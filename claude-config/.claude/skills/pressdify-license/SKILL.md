---
name: pressdify-license
description: Renew a pressdify client's licence: Morntify database, Bexio invoice draft, ClickUp due dates. One summary, one «go».
disable-model-invocation: true
argument-hint: "domain, or a ClickUp link that names it, e.g. 'lavita-goldach.ch' or 'renew peteracker'"
---

# pressdify licence renewal

Request: $ARGUMENTS

Scripts live in this skill's `scripts/` directory; `morntify help` and `invoice help` list the
commands. `invoice` uses the bexio skill's `bxapi` (token from 1Password). The ClickUp step uses the
`clickup_*` MCP tools.

Brian keeps the overview: the skill writes nothing before his «go», and never touches a document
status or a ClickUp status. He issues and sends the invoice himself.

## Limits

| | |
|---|---|
| Free | Every read in step 1. |
| After «go» | `morntify renew`, `invoice draft`, the due date on the two ClickUp tasks. |
| Never | Issuing or sending the invoice. Any ClickUp status, comment, assignee or description. Creating a Bexio contact or a ClickUp task. Any task that is not one of the client's pair, in particular a support ticket the request came from. |

Unknown domain, two matching rows, no invoice, no ClickUp pair, a price Brian names that differs
from the last invoice: stop and ask. Never invent a price.

## 1. Gather

The domain is the request, or read from the ClickUp task the request links (the task name or the mail
in its description names the site). Then, read-only:

1. `morntify customer DOMAIN`: the row and what the API answers now. The usual trigger is
   `used == bought` (API code 412) or `end` in the past (411).
2. `invoice last DOMAIN`: the last licence invoice, with its warnings. Price, contact, person and
   du/euch form come from it, never from memory. A warning about currency or tax means «ask Brian».
3. ClickUp pair: `clickup_search` for `pressdify DOMAIN` (tasks). Each client has a task named after
   the domain under the task «pressdify Lizenzen» in «Projects Overview Kanban», with two subtasks:
   one of type Rechnung assigned to Corinne (send the bill) and «Lizenz erneuern Datenbank» assigned
   to Brian. Read both with `clickup_get_task`; note their due dates.

## 2. Summary

One message, then wait. Lists, not tables; Brian reads on his phone.

- **Customer**: bought, used, start → end, what the API says.
- **Last invoice**: number as a link (`https://office.bexio.com/index.php/kb_invoice/show/id/<id>`),
  date, contact and person, position text, net and gross, du/euch, any warning.
- **ClickUp pair**: both tasks as links with their current due date.
- **Proposed**: the renewal (new year from the sending day: used 0, start = that day, end = +1 year;
  or a top-up if Brian asked for one), the invoice (title, position, price, Datum = sending day,
  Zahlbar bis = +29 days), the new due date for the pair (= new end date).

The sending day is today unless the request names another. Brian answers «go», or corrects a date,
the mode or the price. A corrected price only comes from him.

## 3. Write, after «go»

1. `morntify renew DOMAIN --from DATE` (or `--top-up N`). Check the printed `after` row and that the
   API answers `aboActive: true` with the new dates and credits. Anything else: stop, report.
2. `invoice draft DOMAIN --date DATE --pdf PATH` (plus `--price` only when Brian named one;
   `--from RE-NNNNN` when the last invoice is not the right model). Read the PDF: the invoice on page
   one, the QR bill on page two, nothing cut.
3. `clickup_update_task` on both subtasks with `due_date` = the new end date. Read both back.

## 4. Report

- The DB row after: used, start → end; the API answer.
- The draft: number as a link, title, position, Datum and Zahlbar bis, net and gross, pages.
- The two tasks as links with the new due date.
- Anything assumed or unverified.

His steps last: issue and send the invoice in Bexio.
