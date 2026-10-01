---
name: bexio
description: Read Bexio and write offer and invoice drafts (Angebote, Rechnungen) for morntag through the logged-in Chrome profile. Covers finding and reading documents, putting a finished offer text into Bexio, direct invoices for small flat jobs, and part or final invoices from an existing Auftrag. Drafts only, Brian issues and sends.
disable-model-invocation: true
argument-hint: "what to do, e.g. 'Rechnung Kunde X Warenkorb' or 'Angebot aus dem Text oben'"
---

# Bexio: Angebote und Rechnungen

Request: $ARGUMENTS

Bexio is driven through the browser UI with `scripts/bx` (in this skill's directory), a wrapper around `browser-use`
that uses Brian's logged-in Chrome profile. Run `scripts/bx help` for the commands. Mechanics, URLs and dead ends are
in [references/ui.md](references/ui.md). German wording, titles, header and footer texts are in
[references/texte.md](references/texte.md). Read both before the first write. If `references/examples.local.md`
exists, read it too: it names real documents to model on and is kept out of git because it holds client names.

## Limits

| | |
|---|---|
| Free | Reading anything. Creating a draft. Editing a draft. |
| Ask Brian first | Creating a contact. Anything where two sources disagree on the price. A client billed in EUR or without 8.1 % VAT. |
| Never | Issuing («… ist gestellt»), sending, deleting a document, marking as paid, reopening an issued document, turning an offer into an Auftrag, Mahnungen, the monthly invoices («Arbeiten August», «Maintenance Paket …»). |

- If `bx go` reports NOT LOGGED IN, stop. Brian logs in himself. Never type credentials.
- Never invent content or a price. The amount comes from a named source or from Brian.
- This skill does not price or reword an offer. `morntag-angebot` does that with the person writing the offer; its Markdown is
  this skill's input.

## The number is assigned on «Weiter»

Bexio assigns AN-/RE-numbers when the new-document dialog is submitted, before any position exists. So:

1. Check the list for an existing draft for this client and job (`bx list 'client name'`). Continue that one.
2. Have title, positions, prices and address form ready as files before `bx weiter`.
3. If something goes wrong after «Weiter», repair the draft. Do not start a second one.

## Jobs

### 1. Read
`bx go /index.php/kb_offer/list` (or `kb_invoice`, `kb_order`), `bx list 'regex'`, then `bx go` the document and
`bx read`, `bx texts`, `bx conditions`. Prices can change without notice because Brian edits drafts himself, so
re-read before quoting an amount.

### 2. Offer draft
Input: a finished offer text in the conversation or a file Brian names. Without one, say so and point to
`morntag-angebot`; for a small job Brian can dictate the positions.

1. Map the text to Bexio fields with the table in `references/texte.md`. Write one HTML file per position in the
   scratchpad. Decide the address form.
2. Find the contact id (`references/ui.md`). No contact: ask Brian before creating one.
3. `bx new offer ID "Titel" "Kontaktperson"`, check the echoed line, `bx weiter`.
4. Add positions in their final order: `bx add-text`, `bx add-pos FILE PRICE`, `--optional` for add-ons.
5. `bx set-texts header.html footer.html`.
6. Finish (below).

### 3. Direct invoice draft (small flat job, no offer or Auftrag behind it)
Find what to bill, in this order: an Auftrag or offer in Bexio for the job, the ClickUp task, the client's folder in
the current repo, the Gmail thread with the agreement. If an Auftrag exists, use job 4.

1. Look at the client's last invoice (`bx list`, `bx read`, `bx texts`) for currency, tax and address form.
2. Write the title and one position text per `references/texte.md`.
3. `bx new invoice ID "Titel" "Kontaktperson"`, check, `bx weiter`. An empty priced row is already open.
4. `bx add-pos position.html 400.00`. Agreed flat prices are net, Bexio adds 8.1 %.
5. `bx set-texts` when the address form is «euch» (the default says «dir»).
6. Finish.

### 4. Invoice from an Auftrag
Brian names the Auftrag (AU-…). `bx read` on `/index.php/kb_order/show/id/<n>` shows either a TEILRECHNUNGEN plan
with a link «Teilrechnung N erstellen», or «Rechnung erstellen». The shares were set when the Auftrag was created.
Do not change them.

1. Confirm that the next part matches what Brian asked for (number and share).
2. `bx press "Teilrechnung N erstellen" a` (or `"Rechnung erstellen"`). This creates the draft and takes a number.
   This click has not been run by an agent yet, see the unverified list in `references/ui.md`. Read what the page
   shows afterwards before doing anything else.
3. Leave Bexio's position («Teilrechnung 1 von Auftrag AU-00045 (33.33%)») and amount as they are.
4. `bx set-texts` for the address form. Finish.

## Finish

1. Verify. Reload the draft (`bx go`), `bx read`, `bx texts`, `bx scan euch` (or `du`). Compare with the source:
   contact and contact person, title, every position text and price, optional flags, total, no «ß». For an offer
   also take `bx shot` and look at the layout; merged paragraphs only show there.
2. Report to Brian: number, client, title, net and gross total, status Entwurf, the link
   `https://office.bexio.com/index.php/kb_offer/show/id/<n>` (or `kb_invoice`), and anything unverified or assumed.
   He reviews, issues and sends.
3. Record. If the current repo has `clients/<slug>/README.md` for this client, add one dated line where the README
   keeps open items or history, e.g. `2026-09-29: Bexio offer AN-00123 drafted (not issued), CHF 1'700 + optional
   400 and 900.` Do not commit unless asked.
4. `bx close`.

ClickUp comments, status changes and the cover mail are separate requests. Do them only when Brian asks in the same
invocation.

## When the UI does not behave as described

Stop writing, take `bx shot`, read the page with `bx state`, and tell Brian what differs. After the run, correct
`references/ui.md` and move items out of its unverified list once they have worked.
