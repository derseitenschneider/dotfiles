# Bexio UI through browser-use

What worked when agents created an offer draft (2026-09-29) and invoice drafts (2026-10-01, 2026-10-05 incl.
`bx weiter`, `bx add-pos`, `bx set-texts` on an invoice), plus read-only checks on 2026-10-01. `bx` is `scripts/bx` in this skill. Items no agent has run yet are listed under "Unverified" at the end.

## This machine

- `bx` starts `browser-use --session bexio --profile "Default"`. "Default" is the morntag.com Chrome profile, which
  is logged in to Bexio. Session and profile names are set at the top of `scripts/bx`.
- `browser-use --connect` fails here (Chrome runs without remote debugging).
- Login expired: `bx go` prints NOT LOGGED IN and exits 2. Brian logs in in Chrome, then retry.

## Rules for driving the page

- `browser-use eval` only returns values from synchronous code. `async`, `fetch` and promises come back as `{}`.
  Wait with `bx wait N`.
- Wait after every page load (4 s), after opening a position form (3 s) and after every save (4 s). The `bx`
  commands already do this.
- Never write JavaScript inline in double quotes if it contains `$` or backticks; zsh expands them. Put it in a file
  and run `bx js FILE`, or use the `__bx` helpers through `bx call`. Use `window.jQuery`, not `$`.
- Quote attribute values in selectors: `a[href*="kb_offer/show"]`. Unquoted slashes make the eval return `None`.
- Element indices from `browser-use state` change on every page load. Read them fresh (`bx press` does).
- Two kinds of pages. Documents (`kb_offer`, `kb_invoice`, `kb_order`) are plain DOM under `#contentContainer`.
  Contacts (`kontakt/*`) are Angular with shadow DOM: `#contentContainer` is empty, use `bx state` and `bx shot`.

## URLs

| Page | Path |
|---|---|
| Offers, invoices, orders | `/index.php/kb_offer/list`, `/index.php/kb_invoice/list`, `/index.php/kb_order/list` |
| One document | `/index.php/kb_offer/show/id/<n>`, n = number without zeros (AN-00123 is 123, RE-01234 is 1234, AU-00045 is 45) |
| Next list page (offers) | `/index.php/filter/setPage/f/KbOfferFilter/m/kb_offer/a/list/p/2` |
| New document for a contact | `/index.php/kb_offer/edit/contact_id/<contact id>`, same with `kb_invoice` |
| Tabs of a document | `/index.php/kb_offer/editTexts/id/<n>`, `editPayment` (Konditionen), `editAddress`, `editItemSettings`, `showRelations` (Belegfluss) |
| Contacts | `/index.php/kontakt/list/resetListView/1` |

`/index.php/kb_offer` without `/list` returns HTTP 500. The offer list shows 200 rows per page, the invoice list
100. `bx list` only sees the page that is open.

## Reading

```bash
bx go /index.php/kb_invoice/list && bx list 'client name|other client'
bx go /index.php/kb_offer/show/id/265 && bx read && bx texts && bx conditions
```

`bx read` prints the heading, status, contact link, the previous document, the part-invoice plan of an Auftrag, every
position with its row id (`position_KbPositionCustom4997`, marked `optional` where it is one) and the totals.
`bx texts` and `bx conditions` fetch the tabs in the background and work on drafts and issued documents.

## Contact id

The new-document dialog needs the numeric contact id. It is not the contact number (like 001234) and not the UUID in a
contact page's URL.

- Client has any document: open it, `bx read` prints `contact: /index.php/kontakt/show/id/1001`. The id is 1001.
- Client has no document: open the contacts list, search (one search per fresh page load, the box does not clear),
  read the result from a screenshot, open the contact, click its «Rechnungen» tab and look for the link
  `Neue Rechnung -> /index.php/kb_invoice/edit/contact_id/<id>` with a shadow-DOM walk:
  ```js
  (() => { const all = []; const walk = r => { for (const a of r.querySelectorAll('a[href]')) all.push(a.innerText.trim() + ' -> ' + a.getAttribute('href')); for (const e of r.querySelectorAll('*')) if (e.shadowRoot) walk(e.shadowRoot); }; walk(document); return [...new Set(all)].filter(h => /contact_id/.test(h)).join('\n'); })()
  ```
- No contact at all (also check «Archiviert»): ask Brian before creating one. Creating worked on 2026-10-01 through
  «Neuer Kontakt» on the list, `browser-use input <index>` per field, «Speichern», then «Kontakt hinzufügen» for the
  person. Read field labels from `bx state` and a screenshot, the `mat-input-N` ids are not stable knowledge.

The contact autocomplete inside the dialog ignores automated typing. Always go through the `contact_id` URL.

## Creating the draft

```bash
bx new offer 1001 "Registrierung ohne Zusatz-Plugin" "Vorname Nachname"   # or: bx new invoice …
# prints contact, person, title, date; nothing is created yet
bx weiter
# prints /index.php/kb_offer/show/id/123 | Angebot AN-00123 - Kundenname
```

«Weiter» assigns the number and creates the draft with status Entwurf. Opening the dialog and leaving it without
«Weiter» takes no number. Date and currency keep their defaults (today, CHF).

## Positions

Write each position's HTML to a file in the scratchpad, then:

```bash
bx add-text eckdaten.html                 # text position
bx add-pos hauptposition.html 1700.00     # priced, quantity 1, unit Stk, default account and tax
bx add-text zusatz-intro.html --optional
bx add-pos zusatz-cache.html 400.00 --optional
```

- Positions append in the order they are added, normal and optional ones in separate groups. Add them in the
  final order.
- After «Weiter» a new invoice already shows an empty priced row. `bx add-pos` fills that row.
- `bx add-pos` prints what the form holds (amount, unit, price, account, tax, optional) before it saves.
- There is no document-level save. Each position saves on its own.
- Bexio drops `<p>` and stores entities (`&laquo;`, `&uuml;`). Separate paragraphs with `<br /><br />`. When
  matching stored text, allow for entities.
- Change a saved position: `bx edit-pos position_KbPositionText1019 --expect "Zeitplan" --html zeitplan.html`.
  `--expect` is a phrase the position holds now. If it is missing, nothing is saved. A text change keeps price,
  unit, tax and the optional flag.
- A position cannot be read while its edit form is open.

Under the hood: `addPosition('KbPositionText'|'KbPositionCustom', false)` opens the form
(`form[action*="KbPositionText"]`), the editors are `tinymce.get('kb_position_text_text')` and
`tinymce.get('kb_position_custom_text')`, fields are `kb_position_custom[amount|unit_id|unit_price|is_optional]`
(unit 1 Stk, 2 h, 3 Halbtag, 4 Jahr, 5 Kilometer, 6 Lektion, 7 Monat), then `tinymce.triggerSave()` and the form's
«Speichern».

## Header and footer

```bash
bx set-texts header.html footer.html      # "-" keeps one of them
```

Clicks the «Texte» tab, sets the TinyMCE editors `kb_item_header` and `kb_item_footer`, clicks «Texte speichern».
These calls worked on an offer draft on 2026-09-29. The texts to use are in `texte.md`.

## Invoice from an Auftrag

`/index.php/kb_order/show/id/<n>` shows one of two things in the right column:

- A plan «TEILRECHNUNGEN» (Teilrechnung 1 33.33% gestellt, Teilrechnung 2 offen, …) with the link
  «Teilrechnung 2 erstellen» (`/index.php/kb_order/createNextPartialInvoice/id/<n>`).
- No plan, and the status action «Rechnung erstellen» (`/index.php/kb_order/createInvoice/id/<n>`).

Both are plain links that create a document. Do not open them to "have a look". Invoices made this way hold one
position written by Bexio, keep the Auftrag's title and get the du default header and footer.

## Dead ends

| Tried | What happened | Do instead |
|---|---|---|
| `--connect` | No Chrome with remote debugging | `--profile "Default"` (`bx` does it) |
| `/index.php/kb_offer` | HTTP 500 | `/index.php/kb_offer/list` |
| Typing into the contact autocomplete | No suggestions appear | `/edit/contact_id/<id>` |
| `async` eval, `fetch`, `setTimeout` promise | `{}` or zone-symbol junk | Sync code, `bx wait` |
| `browser-use wait selector/text` on contact pages | Returned before the page was ready | `bx wait 4` and a screenshot |
| `keys "Meta+a"` to clear the contact search | Queries got concatenated | Reload the list per search |
| `<p>` in position HTML | Paragraphs merged into one block | `<br /><br />` |
| Regex with literal `<p>` or umlauts on stored text | No match, stored text has entities and no `<p>` | Loose patterns, and a guard that saves nothing on no match |
| Reading totals with the Texte tab open | Empty | Read on the Positionen tab or after `bx go` |
| Reading header/footer of an issued invoice as fields | Empty, they are plain text there | `bx texts` handles both |

## After the draft (only when Brian asks in so many words)

Issuing is Brian's step. On 2026-10-01 he asked an agent to do it once: `<a title="Rechnung ist gestellt">` on the
show page, no confirm dialog, status went to Offen. The PDF came from `/index.php/kb_invoice/getPdf/id/<n>` with
`curl` and the session cookies (`browser-use cookies export`, delete the cookie file afterwards). On 2026-10-05 the same `getPdf` URL also
returned the PDF of a **draft** (RE-01827): numbered, no draft watermark, QR bill included, good for attaching to a
mail draft Brian sends after issuing. The skill's default stays: stop at the draft.

## Changing a contact's address (2026-10-08, unisite)

- Contact page `/index.php/kontakt/show/id/<id>`: the pencil next to the name is the first `bexio-bubble` button in
  `bx state`. The edit form has Strasse, Haus-Nr., Adresszusatz, PLZ, Ort as shadow-DOM inputs (`mat-input-3` to `-7`
  that day). `bx input <index> "text"` replaces the value. «Speichern» is a `bexio-button`.
- Existing documents keep a copy of the address. Re-selecting the contact address on the «Anschrift» tab does not
  refresh it. Set `kb_item[contact_address_manual]` and `kb_item[delivery_address_manual]` directly and click
  «Eingaben speichern».

## Unverified

The `bx` read commands and `bx new` (without `bx weiter`) were tested on 2026-10-01. On 2026-10-07 `bx weiter`,
`add-text`, `add-pos` and `set-texts` built offer AN-00267 end to end without problems. On 2026-10-08 `bx edit-pos ROW --expect … --price 4800.00`
changed a price and `--html` a text position on the same draft; the totals followed. `bx new` with a contact
person the contact does not have prints «not found. Options:» with an empty list; run it again without the person. The write commands (`weiter`,
`add-text`, `add-pos`, `edit-pos`, `set-texts`) wrap the calls that created those two drafts, but the wrapper
itself has not written a document yet. On the first real run, check each step's output and the page before the next.

No agent has done the following at all. Try them when a real document needs them, check the result, then move the
item up.

- `bx press "Teilrechnung N erstellen" a` and `"Rechnung erstellen"` on an Auftrag: whether a dialog comes first,
  when the number is assigned, what the draft looks like.
- PDF page break: `addPosition('KbPositionPagebreak', true)` is the menu's handler. Page breaks in existing
  offers were added by hand.
- Switching off «Angebot Total anzeigen» (`kb_item[show_total]` on the Einstellungen tab, button «Einstellungen
  übernehmen»). On AN-00267 (2026-10-07) a fresh offer already had it unchecked, so nothing was clicked; Bexio's
  own Positionen view still shows the total. Check the box state before touching it.
- Konditionen: fields are `kb_item[is_valid_from]`, `kb_item[is_valid_until]` (offer) or `kb_item[is_valid_to]`
  (invoice), `kb_item[accomplishment_date]` (Leistungszeitraum, invoice), button «Eingaben speichern». Never edited.
- Reordering (rows are jQuery UI sortable), deleting or duplicating a position, a second position on an invoice.
- Invoice list page 2 (the offer URL pattern with `KbInvoiceFilter` is a guess).
- Whether a deleted draft frees its number.
