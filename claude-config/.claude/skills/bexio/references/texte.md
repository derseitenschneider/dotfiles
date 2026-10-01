# Texts and house style

Taken from real morntag documents in Bexio, read 2026-10-01. Which documents, with client names, is in
`examples.local.md` next to this file (kept out of git). Client-facing text is German with Swiss spelling: «ss», never «ß». Quotes are «Guillemets».

## Address form

| Client | Form |
|---|---|
| Organisation, team, or unclear | ihr / euch / euer, in header, every position and footer |
| One person who is clearly on du terms (the mail thread says «du») | du / dir / dein |

- When unsure, use «euch». Do not ask.
- No name in the greeting. Every header starts with «Guten morntag!».
- Bexio's default header and footer are in the du form. For «euch» clients they must be replaced.
- Check with `bx scan euch` or `bx scan du` before the draft counts as finished. `scan du` also lists «ihr» in the
  sense of "her/their"; read the hits.

## Titles

Short noun phrase that names the thing. Page and feature names in «». No client name, no «Angebot» or «Rechnung».

- «Seite «Newsletter»»
- «Fehlerbehebung Filter «Produkte finden»»
- «Seitlicher Warenkorb im Shop»
- «Registrierung ohne Zusatz-Plugin»
- «Projekt «Relaunch Website»»

An invoice from an Auftrag keeps the Auftrag's title.

## Header and footer

HTML as Bexio stores it. Line breaks are `<br />`, paragraphs `<br /><br />`.

### Offer

Default (du):
```html
Guten morntag! <br /><br />Vielen Dank für deine Anfrage.<br />Gerne unterbreiten wir dir folgendes Angebot:
```
```html
Wir hoffen, unser Angebot entspricht deinen Vorstellungen und stehen bei Fragen gerne zur Verfügung.<br /><br />Sämtliche Beträge sind in CHF ausgewiesen. Bei Bezahlung in EUR wird der Tageskurs per Rechnungsdatum verwendet.<br /><br />Lieb grüsst<br />Team morntag
```

For «euch»:
```html
Guten morntag! <br /><br />Vielen Dank für eure Anfrage.<br />Gerne unterbreiten wir euch folgendes Angebot:
```
```html
Wir hoffen, unser Angebot entspricht euren Vorstellungen und stehen bei Fragen gerne zur Verfügung.<br /><br />Sämtliche Beträge sind in CHF ausgewiesen. Bei Bezahlung in EUR wird der Tageskurs per Rechnungsdatum verwendet.<br /><br />Lieb grüsst<br />Team morntag
```

The thanks sentence follows the occasion. If the offer text brings its own opening, use that. If the client did not
ask for the offer, «Vielen Dank für eure Anfrage.» is wrong. Past offers used «Vielen Dank für euer Interesse.»
or thanked for the workshops of the Vorprojekt.

### Invoice

Default (du), correct as it is for du clients:
```html
Guten morntag! <br /><br />Vielen Dank für die Zusammenarbeit!<br />Wir erlauben uns, dir folgendes in Rechnung zu stellen:
```
```html
Bei Fragen stehen wir dir gerne zur Verfügung.<br /><br />Lieb grüsst<br />Team morntag
```

For «euch»:
```html
Guten morntag! <br /><br />Vielen Dank für die Zusammenarbeit!<br />Wir erlauben uns, euch folgendes in Rechnung zu stellen:
```
```html
Bei Fragen stehen wir euch gerne zur Verfügung.<br /><br />Lieb grüsst<br />Team morntag
```

## Offer: from the Markdown to Bexio

The offer text comes from `morntag-angebot` (or from Brian) and goes in unchanged, apart from the address form.
Bexio order of positions as in past morntag offers:

| In the offer text | In Bexio |
|---|---|
| «Guten morntag! … folgendes Angebot:» | Header (Texte tab), not a position |
| Eckdaten, or «Hinweise zum Vorprojekt» | Text position, first. A PDF page break follows it when it is long. |
| Each priced item or option | Priced position, quantity 1, unit Stk, net price |
| Add-ons the client can book on top | Priced positions with `--optional`, after a one-line optional text position that introduces them |
| Zeitplan, Zahlungsmodalitäten, Leistungsumfang & Abgrenzung, Reisekosten, Plugins, Projektabschluss, Fakturierung | One text position each, after the priced ones, in this order. Only the sections the text has. |
| «Total / Zzgl. MWST / Betrag inkl. MWST» | Left out. Bexio computes it. Compare Bexio's total with the text's total. |
| «Wir hoffen … Lieb grüsst Team morntag» | Footer |

Position HTML:

- Text position: `<strong>Zeitplan</strong><br />` then the body.
- Priced position: `<strong>Registrierung über WooCommerce</strong><br />` then `<ul><li>…</li></ul>` or text.
- Paragraphs are separated with `<br /><br />`. Bexio drops `<p>` and glues the paragraphs together.
- Write «&» as `&amp;`.

Two more rules:

- The Zeitplan names dates («Start: Anfang November 2026»), not «sobald ihr bestätigt habt». Brian asked for
  this.
- Alternatives A/B/C are all normal priced positions, and «Angebot Total anzeigen» is switched off on the
  Einstellungen tab, because the total would add the alternatives up. Past offers with three options did it this way.
  Add-ons are optional positions and the total stays on.

## Invoice positions

Direct invoice for a small job: one priced position, quantity 1, unit Stk, the agreed flat price net.

The text says what the client got, in words the client would use. One line is enough for a small thing. Up to
three short paragraphs when the work needs explaining. No hours, no internal task names, no tool names the client
never saw. End with «Pauschal wie vereinbart.» when a flat price was agreed beforehand.

One line for a small job:
> Erstellung Seite «Newsletter» inkl. Formular

Three paragraphs for a job that needs explaining:
> Warenkorb-Symbol im Menü mit Anzahl Artikel, auf Computer und Handy.
>
> Seitlicher Warenkorb, der sich beim Hinzufügen eines Artikels automatisch öffnet, ohne Neuladen der Seite. Artikel
> lassen sich mit dem X entfernen, die Buttons «Kasse» und «Warenkorb anzeigen» führen weiter zur Bestellung.
>
> Umsetzung und Abnahme auf einer Testkopie, live seit 1. Oktober 2026. Pauschal wie vereinbart.

Invoice from an Auftrag: Bexio writes the position («Teilrechnung 1 von Auftrag AU-00045 (33.33%)»). Leave it.

## Numbers

- Prices are net. VAT is 8.1 % and Bexio adds it (tax «UN81», account «3200 Erlös aus Produktion», both form
  defaults). Report net and gross to Brian.
- Enter prices plain: `1700.00`. Bexio shows `1'700.00`.
- Offers are valid 14 days and invoices are due after 29 days by Bexio's defaults. Leave both unless Brian says
  otherwise.
- Some clients are billed in EUR without VAT. The skill does not set currency or tax. If the
  client's last invoice is not CHF with 8.1 %, ask Brian.
