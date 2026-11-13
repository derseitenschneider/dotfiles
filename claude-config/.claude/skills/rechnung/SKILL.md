---
name: rechnung
description: Brian's invoices (Rechnungen) in the look of his Pages templates, with the `rechnung` CLI: concert fees and music work (Plugin), Eleno licences (Eleno), web work (Seitenschneider). Use whenever Brian asks for an invoice, a Rechnung, a Gage or Honorar to bill, or a receipt for a payment already made.
---

# Invoices

Brian's Pages templates cannot be edited on Linux, so `rechnung` (`~/dev/personal/dev-server/rechnung`, `--help`)
redraws them: same fonts, kerning, positions, background and QR slip, tested pixel by pixel against his real
exports (`~/.local/share/rechnung-venv/bin/python -m pytest rechnung/` in that repo). Brian checks every invoice
by eye and expects it to look like the ones he made in Pages. Never adjust the layout freehand; a change to a
template means re-measuring from a new Pages export and keeping the tests green.

## Steps

1. **Design and client folder.** Pick the design by what is billed:
   - `plugin`: concerts, gigs, rehearsal fees, lead sheets, arrangements, studio work. Folder (`marke`) per
     band or client: `HALUNKE`, `NGC` (Art & Act Kulturverein), `TJC`, or a new one in capitals.
   - `eleno`: Eleno licences and anything else Eleno bills. Folder `ELENO`.
   - `seitenschneider`: web work as derseitenschneider. Filed loose, without a folder (as `260109_MSRT.pdf`).

   Done when design and folder are named.
2. **Content from the last invoice to that client.** Find it with `dbx find` in
   `/2-Areas/Buchhaltung/1. Buchhaltungsjahre/<year>/2. Debitoren/Rechnungen` of this and last year, and in
   `0. Belege` (Oracount files some sent invoices there, e.g. `2025-12-23_ngc_1600.00.pdf`). `dbx peek` it and
   copy address, title wording and line format ("Konzert <Ort>, <TT.MM.JJJJ>"). Dates and venues come from
   `kalender`, fees from "Standing arrangements" in `~/ora/data/personal_voice.md` (concert CHF 400; a double
   gig is CHF 200 morning plus CHF 400 evening unless he cannot drive home between them; lead sheet CHF 180).
   A gig Brian did not play (a substitute is listed) is not billed. Done when every line has text and amount
   from one of these sources or from Brian; ask him only for what none of them gives.
3. **Dates.** `datum` is the day Brian sends it. He sends gig invoices on the next business day after the
   last gig. `faellig` defaults to 30 days later. For a receipt of money already received, set `bezahlt`
   instead (label «Bezahlt am», a thank-you line, no QR page).
4. **Spec and render.** Write the spec as JSON in the scratchpad (format per design in the docstring of
   `rechnung/designs/<design>.py`), with `"marke"` and `"datei": "YYMMDD-Kunde-Thema.pdf"`, then
   `rechnung render SPEC.json`. The number is the next one of that design in that year's Debitoren folder
   (`rechnung nummer <design>` lists them); an invoice already filed with a later date still counts.
   `nr` in the spec overrides it.
5. **Look at it.** `pdftoppm -r 100 -png` page 1 and read the image: text inside its columns, total right,
   nothing over the background artwork.
6. **File it.** `rechnung ablegen <pdf> --marke <MARKE>` (omit `--marke` for Seitenschneider), which copies into
   the year's Debitoren folder through the local Maestral sync and refuses to replace different content. When
   it warns that Maestral is not running, restart it (`systemctl --user restart
   maestral-daemon@maestral.service`, then `maestral resume`) and check with `dbx ls` that the file arrived.
7. **Mail draft.** `postfach draft --to <address> --subject "Rechnung <Thema>" --attach <pdf> --body-file <txt>`,
   in Brian's voice (`~/ora/data/personal_voice.md`: "Anbei die Rechnung für …", one sentence on any unusual
   line such as a double gig, "Liebe Grüsse"; the signature is appended). A new mail draft does not replace an
   earlier one: when you redo an invoice, delete your old draft (see Redoing).
8. **Reminder** when the send date is in the future: an Ora reminder, which the morning brief lists on its day:

   ```
   cd ~/ora && .venv/bin/python -c "import asyncio,sys; sys.path.insert(0,'.'); from core.memory import memory; asyncio.run(memory.remember_fact('global','reminder.rechnung_<slug>',{'what':'<what to send to whom, where the draft is, the PDF link>','due':'YYYY-MM-DD','lead_days':0},source='Brian <date> (Claude, Rechnung)'))"
   ```

   Done when the fact is stored; read it back from `memory/db/ora.db`.

## Brian's final message

The preview link `rechnung render` prints, the lines and total, number and dates, where it is filed, the draft,
the reminder. His steps go last: send the draft; then send the PDF to Herr Rüegg's Telegram chat with the
caption «Debitorenrechnung <MARKE>». Oracount finds the identical file already in Debitoren, keeps it and opens
the Offener Posten.

## Redoing an invoice

Render again with the same `datei`, copy over the preview, `rechnung ablegen` the new file (delete the old one
in the Debitoren folder first if its content differs), and replace the mail draft. `postfach` has no delete;
find the draft with `postfach search --folder Drafts --subject …` and delete it by Message-ID:

```
cd ~/ora && .venv/bin/python -c "import asyncio,sys; sys.path.insert(0,'.'); from tools.personal_mail import _mailbox
async def m():
    b=_mailbox(); mail=await b.fetch(<UID>,'Drafts'); print(mail.subject, await b.delete_draft(mail.message_id))
asyncio.run(m())"
```

Apple Mail re-saves an open draft under a new UID, so list Drafts again afterwards and remove any older copy
whose text Brian did not change, leaving one draft.

## The designs

- **Plugin**: Geist 1.1.0 (the version on Brian's Mac; newer Geist kerns differently), labels at 80 % opacity.
- **Eleno**: Helvetica in Pages; drawn with URW Nimbus Sans and Apple's kerning pairs. Positions match, a few
  outlines (G, 7, 4, minus) differ when zoomed in. Columns Position / Einzelpreis / Anz. / Total; a `prozent`
  line is a discount or MwSt on the lines above.
- **Seitenschneider**: Montserrat 7.222, columns Text / Std. / Satz / Total, or «Pauschal».

Page 2 of each design (the QR slip, account without amount) is copied from one of Brian's exports of it.
