---
name: "wp-po-translator"
description: "Übersetzt WordPress .po-Dateien ins Deutsche gemäss den offiziellen WP-DE-Polyglots-Richtlinien (Style Guide, Glossar, Rechtschreibung, Komposita) — im Human-in-the-Loop-Verfahren mit Batch-Review durch Simea. Verwende diesen Skill wenn Simea sagt «übersetze diese .po-Datei», «mach die Übersetzungen», «füll die leeren msgstr aus», «übersetze das WordPress-Plugin», «passe das .po-File an» oder wenn eine .po-Datei hochgeladen wird und Übersetzung gefragt ist. Auch verwenden wenn eine Liste von zu übersetzenden Strings aus einer .po-Datei vorliegt und ins Deutsche übertragen werden soll."
---

# WP .po Übersetzer (DE / DE Formal / CH) – Human-in-the-Loop

Übersetzt WordPress .po-Dateien ins Deutsche gemäss den offiziellen WP-DE-Polyglots-Richtlinien.

**Standardmässig immer zwei Varianten:** German (du) und German Formal (Sie), gemeinsam pro String besprochen.
Für German (Switzerland) gilt ein eigener Prozess – siehe unten.

**Zentrale Regel: Nichts wird ungeprüft in die finale Datei geschrieben.** Alle übersetzten Strings werden Simea in Batches zur Freigabe vorgelegt, bevor sie ins .po-File eingetragen werden. Ausnahme: reine 1:1-Strings ohne Anrede-Bezug (siehe Schritt 3b) – diese werden automatisch übernommen, aber ebenfalls in Batches aufgelistet, damit Simea sie sieht.

**Batches immer als Tabelle darstellen** (siehe Schritt 3a/3b) – Listenform ist für Simea bei grösseren Batches kaum überschaubar.

**Anführungszeichen für de_DE/de_DE_formal: immer „...“ (deutsche Anführungszeichen), NIE «...»** – «...» sind Guillemets und gehören nur zur de_CH-Konvertierung (siehe Workflow German Switzerland unten). Auch in laufenden Batches sofort korrigieren, falls «...» versehentlich verwendet wurde, und rückwirkend bereits freigegebene Strings prüfen/korrigieren.

**Effizienter Batch-Rhythmus:** Wenn Simea Feedback zu einem Batch gibt, die Korrekturen übernehmen, den Batch als freigegeben speichern UND in derselben Antwort direkt den nächsten Batch mitliefern – nicht separat auf ein zusätzliches "weiter" warten. Das minimiert Wartezyklen bei grossen Dateien.

---

## Massgebliche Quellen (immer diese, nie aus dem Gedächtnis)

| Was | Link |
|---|---|
| Glossar informell (de_DE) | https://translate.wordpress.org/locale/de/default/glossary/ |
| Glossar formell (de_DE_formal) | https://translate.wordpress.org/locale/de/formal/glossary/ |
| WP-DE Style Guide | https://de.wordpress.org/team/handbook/polyglots-team/style-guide/ |
| Handbuch German (Switzerland) | https://de-ch.wordpress.org/team/handbook/uebersetzungen/ |
| PO Converter (de_DE → de_CH) | https://po.wpswitzerland.ch/ |

**Nachschlage-Regel:** Die Kurzliste weiter unten deckt die Begriffe ab, bei denen erfahrungsgemäss falsch übersetzt wird. Für jeden Begriff, der **nicht** in der Kurzliste steht und bei dem die Übersetzung nicht eindeutig ist, im verlinkten Glossar nachschlagen – nicht raten und nicht aus dem Sprachgefühl übersetzen. Wenn der Abruf nicht möglich ist (kein Netzzugriff), das Simea sagen und die betroffenen Begriffe im Batch als offene Rückfrage markieren, statt sie stillschweigend zu übersetzen.

Die Glossar-Übersetzungen der Nomen und Adjektive sind zwischen informell und formell praktisch identisch; nur Kommentare und Hinweistexte unterscheiden sich stellenweise. Bei Verb-Einträgen („aktiviere" vs. „aktivieren") entsprechend du-/Sie-Form wählen.

---

## Wichtigste Regeln (WP-DE Style Guide)

### Anrede
- **German (de_DE):** Informelles „du" (kleingeschrieben)
- **German Formal (de_DE_formal):** Formelles „Sie" (grossgeschrieben)
- **German Switzerland (de_CH / de_CH_formal):** Kein direktes Übersetzen – Import-Prozess, siehe unten

### Stil
- Keine wörtliche Übersetzung – Inhalt sinngemäss auf Deutsch übertragen
- Aktive, kurze, prägnante Sätze
- Keine Umgangssprache (fürs → für das, nochmal → noch einmal)
- Kein Fachjargon ausser Glossar-Begriffe

### Rechtschreibung
- Typografische Anführungszeichen: „..." statt "..." (siehe oben – nie «...» bei de_DE)
- `&` → „und" (ausser in HTML-Attributen/Entitäten)
- Zahlen mit Trennpunkt ab vierstellig: 1.000.000
- Gedankenstrich (–) statt Bindestrich (-) bei Einschüben

### Komposita (Bindestrich-Regeln)
- Englisch+Deutsch gemischt: immer Bindestrich → „Alt-Text", „KI-Engine", „API-Schlüssel"
- Reine deutsche Komposita: zusammenschreiben → „Mediathek", „Benutzeroberfläche"
- Produktnamen bleiben unverändert: WordPress, ChatGPT, Yoast SEO, Elementor, Divi

---

## Glossar-Kurzliste: die häufigsten Fehlerquellen

Diese Begriffe werden von KI-Übersetzungen (und von Menschen) regelmässig falsch übersetzt, weil die naheliegende Übersetzung nicht die offizielle ist. Sie gelten verbindlich. Alles andere: im verlinkten Glossar nachschlagen.

```
Appearance → Design (Menüpunkt, nicht „Aussehen")
aside → Kurzmitteilung
autosave → Automatische Speicherung
black list / blacklist → Sperrliste
safelist / whitelist → Freigabeliste
bulk action(s) → Mehrfachaktion(en) / Mehrfachauswahl
button(s) → Button(s)  ← NIE „Schaltfläche"
capability/capabilities → Berechtigung(en)
Collaborator(s) → Beteiligter/Beteiligte
custom → individuell  (nicht „benutzerdefiniert")
Custom Post Type(s) → Individueller Inhaltstyp / Individuelle Inhaltstypen
default → Standard
deprecated → veraltet
drag and drop → Drag-and-drop
editor → Editor (technisch) / Redakteur (Benutzerrolle)
Editor (Benutzerrolle) → Beteiligter
excerpt(s) → Textauszug/Textauszüge
feature → Funktion
featured image(s) → Beitragsbild(er)
GDPR → DSGVO
GMT → UTC
Happiness Engineer(s) → unübersetzt lassen
hover → bei Mauszeigerkontakt
location → Position
log in / log out → anmelden / abmelden
login → Anmeldung · logout → Abmeldung
LTR → Links-nach-rechts-Schreibrichtung
RTL → Rechts-nach-links-Schreibrichtung
margin(s) → Außenabstand/Außenabstände
padding → Innenabstand
border radius → Eckenradius
moderation → Freigabe / Moderation / Freischaltung (je nach Kontext)
pattern(s) → Vorlage(n)
pending → ausstehend
plain → einfach
post → Beitrag  ·  page → Seite  ·  site → Website
post type(s) → Inhaltstyp(en)
post thumbnail(s) → Beitrags-Vorschaubild(er)
Quick Edit → Schnellbearbeitung
reader(s) → Besucher/Leser (je nach Kontext) / Reader (Feature-Name)
review → Rezension
scheme(s) → Vorlage(n)
screen → Ansicht / Bildschirm (je nach Kontext)
Screen Options → Ansicht anpassen
screen reader(s) → Screenreader
Site Editor → Website-Editor
Site Health → Website-Zustand
slug(s) → Titelform(en)
sticky → oben gehalten  ·  not sticky → nicht oben gehalten
string(s) → Zeichenfolge(n)
tag → Schlagwort / Tag (technisch, z. B. HTML-Tag)
tagline → Untertitel
template(s) → Template(s)
term(s) → Begriff(e)
tool(s) → Werkzeug(e)  ·  toolbar(s) → Werkzeugleiste(n)
Twitter → X
upgrade → Upgrade (Nomen) / „Upgrade installieren", „Führe ein Upgrade durch"
         ← NIE „upgraden"; bei holprigen Konstruktionen Simea fragen
user → Benutzer  ·  username(s) → Benutzername(n)
view → anzeigen (Verb) / Aufruf (Nomen)
```

### Projektspezifische Begriffe (von Simea bestätigt)
| Englisch/Kontext | Deutsch |
|---|---|
| "WooCommerce Customers" (Listenname) | „WooCommerce Kunden" |
| "Advanced" als Tab/Menüpunkt in "Settings → Advanced" | „Fortgeschritten" (NICHT „Erweitert") – gilt nur für diesen spezifischen Menüpunkt, nicht für das Adjektiv "advanced" allgemein (z. B. "advanced segmentation" bleibt „erweitert") |

---

## Workflow: German + German Formal (Human-in-the-Loop)

### Schritt 1: Datei lesen
```bash
cat /mnt/user-data/uploads/datei.po
```

Beim Parsen der .po-Datei unbedingt korrektes UTF-8-Handling verwenden (keine `unicode_escape`-Dekodierung auf dem vollen String anwenden – das zerstört Mehrbyte-Zeichen wie „ä"). Nur die PO-eigenen Escapes (`\n`, `\t`, `\"`, `\\`) manuell auflösen, den Rest des Strings unverändert lassen.

### Schritt 2: Leere Strings extrahieren und gruppieren
```python
import re
with open("datei.po", encoding="utf-8") as f:
    content = f.read()
# msgid/msgstr-Paare inkl. Multiline robust matchen, dann pro Paar prüfen ob msgstr leer ist
```

Die extrahierten Strings **thematisch gruppieren**, bevor Batches gebildet werden – z. B.:
- Buttons / UI-Labels
- Fehlermeldungen / Warnungen
- Einstellungen / Optionen-Beschreibungen
- Tooltips / Hilfetexte
- Changelog-Einträge
- Sonstige / technische Strings

Zusätzlich innerhalb der Gruppen unterscheiden zwischen Strings mit echtem Anrede-Bezug (enthalten you/your/we'll etc. oder sind eindeutig an den Nutzer gerichtete Imperative) und reinen 1:1-Strings (siehe Schritt 3b).

Innerhalb jeder Gruppe in Batches von **10–15 Strings** (für Strings mit Anrede-Bezug) bzw. **20 Strings** (für reine 1:1-Strings, siehe Schritt 3b) aufteilen. Bei grossem Gesamtvolumen (hunderte Strings) dürfen Anrede-Batches auch bis zu 15 Strings umfassen, wenn Simea das signalisiert (z. B. „ich habe Zeit, probiere gut zu gruppieren").

### Schritt 3a: Batches mit Anrede-Bezug – Review-Runden im Chat

Für jeden Batch von 10–15 Strings (die eine du/Sie-Unterscheidung betreffen) **immer als Markdown-Tabelle** posten, mit den Spalten `# | EN | DU | SIE`:

```
**Batch 3/7 – Fehlermeldungen (Strings 21–30)**

| # | EN | DU | SIE |
|---|---|---|---|
| 21 | Please enter your email address. | Bitte gib deine E-Mail-Adresse ein. | Bitte geben Sie Ihre E-Mail-Adresse ein. |
| 22 | ... | ... | ... |
```

Regeln dazu:
1. Strings ohne echten Anrede-Unterschied (z. B. rein technische Fehlermeldungen, Button-Labels ohne Personalpronomen), die versehentlich in diesem Batch gelandet sind, trotzdem mit auflisten – in der Spalte EN mit *(keine Anrede)* oder *(Button-Label)* kennzeichnen, in der SIE-Spalte „identisch" eintragen statt den Text zu wiederholen.
2. Bei Unsicherheit (Kontext unklar, mehrdeutiger Begriff, Ton unklar) eine **Rückfrage direkt bei der Zeile** stellen, statt zu raten (z. B. als zusätzliche Zeile oder Anmerkung unter der Tabelle). Bei Rückfragen zu Formulierungsalternativen 2–3 konkrete Varianten mit kurzer Einschätzung/Empfehlung anbieten, nicht nur offen fragen.
3. Auf Simeas Antwort warten. Sie kann: Batch komplett bestätigen, einzelne Zeilen (nach Nummer) korrigieren, oder Rückfragen beantworten.
4. Erst nach Bestätigung eines Batches gelten dessen Strings als freigegeben und werden zur finalen Liste hinzugefügt – inklusive etwaiger Korrekturen, die Simea zurückmeldet.
5. **Sobald Simea Feedback zu Batch N gibt**, die Korrekturen übernehmen, Batch N als freigegeben speichern, UND in derselben Antwort direkt Batch N+1 vorlegen (nicht separat nachfragen, ob es weitergehen soll).
6. Wenn Simea eine generelle Stil-/Glossar-Korrektur gibt (z. B. „Button nie mit Schaltfläche übersetzen", „immer „..." statt «...»"), diese Regel: (a) auf alle bereits freigegebenen/gespeicherten Strings rückwirkend anwenden und korrigieren, (b) in diesem Skill (Glossar-Kurzliste) dauerhaft vermerken, (c) ab sofort in allen folgenden Batches befolgen. Falls die rückwirkende Anwendung viele bereits freigegebene Strings betrifft (z. B. ein Glossar-Fund, der erst spät auffällt), Simea kurz auf den Umfang hinweisen, bevor automatisch überall geändert wird.

### Schritt 3b: Reine 1:1-Strings (ohne Anrede-Bezug)
Strings ohne du/Sie-Unterscheidung (Produktnamen, Versionsnummern, rein technische Begriffe, Changelog ohne direkte Anrede):

1. Automatisch übersetzen bzw. unverändert übernehmen.
2. Trotzdem in Batches von **20** als Tabelle auflisten, zur Kenntnisnahme – kein Einzel-OK pro String nötig:

```
**Batch 12/20 – 1:1-Strings: technische Begriffe (Strings 101–120)**

| # | EN | DE (du = Sie) |
|---|---|---|
| 101 | Export task not found. | Exportaufgabe nicht gefunden. |
| 102 | ... | ... |
```

3. Simea kann pauschal bestätigen oder einzelne Einträge (nach Nummer) herauspicken und korrigieren.
4. Erst nach dieser Kenntnisnahme werden auch diese Strings zur finalen Liste hinzugefügt.

### Schritt 4: Freigegebene Übersetzungen sammeln
Laufend (nach jedem freigegebenen Batch) die Übersetzungen in zwei JSON-Dateien sammeln (nicht erst ganz am Schluss – bei grossen Dateien mit vielen Batches sonst Datenverlustrisiko):

```bash
# de.json: { "Original English string": "Deutsche Übersetzung (du)", ... }
# de_formal.json: { "Original English string": "Deutsche Übersetzung (Sie)", ... }
```

Nur Strings enthalten, die Simea explizit oder pauschal (bei 1:1-Batches) freigegeben hat. Bei rückwirkenden Korrekturen (Schritt 3a.6) die betroffenen Einträge in beiden Dateien direkt nachbessern.

### Schritt 5: Übersetzungen ins .po eintragen

```python
import json, re

def apply_translations(po_content, translations, fill_empty_only=False):
    content = po_content
    for msgid, msgstr in translations.items():
        po_msgid = msgid.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
        po_msgstr = msgstr.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
        if fill_empty_only:
            pattern = r'(msgid "' + re.escape(po_msgid) + r'"\nmsgstr )""'
        else:
            pattern = r'(msgid "' + re.escape(po_msgid) + r'"\nmsgstr )"[^"]*"'
        content, _ = re.subn(pattern, r'\g<1>"' + po_msgstr.replace('\\', r'\\') + '"', content)
    return content

with open("datei.po", encoding="utf-8") as f:
    original = f.read()

de_translations = json.load(open("de.json", encoding="utf-8"))
de_formal_translations = json.load(open("de_formal.json", encoding="utf-8"))

# German (du): nur leere füllen
de = apply_translations(original, de_translations, fill_empty_only=True)
with open("datei-de.po", "w", encoding="utf-8") as f:
    f.write(de)

# German Formal (Sie): leere füllen + bestehende du-Strings ersetzen
de_formal = apply_translations(original, de_formal_translations, fill_empty_only=False)
de_formal = de_formal.replace('"Language: de\\n"', '"Language: de_DE_formal\\n"')
with open("datei-de_DE_formal.po", "w", encoding="utf-8") as f:
    f.write(de_formal)
```

### Schritt 6: Verifizieren

```python
for path, label in [("datei-de.po", "German"), ("datei-de_DE_formal.po", "Formal")]:
    with open(path, encoding="utf-8") as f:
        content = f.read()
    empty = re.findall(r'msgid "(.+)"\nmsgstr ""', content)
    print(f"{label}: {len(empty)} leere msgstr")

# Formal: auf du-Formen prüfen
with open("datei-de_DE_formal.po", encoding="utf-8") as f:
    content = f.read()
for block in content.split("\n\n"):
    ms = re.search(r'msgstr (.+)', block, re.DOTALL)
    if ms and re.search(r'\b(du |dein|dich|dir |deine|deiner|deinen|deinem)\b', ms.group(1), re.IGNORECASE):
        mid = re.search(r'msgid "(.{0,60})"', block)
        print(f"du-Form noch vorhanden: {mid.group(1) if mid else '?'}")

# Zusätzlich: auf «...» (Guillemets) in de_DE-Dateien prüfen – dürfen dort nicht vorkommen
for path in ["datei-de.po", "datei-de_DE_formal.po"]:
    content = open(path, encoding="utf-8").read()
    if "«" in content or "»" in content:
        print(f"WARNUNG: Guillemets in {path} gefunden – sollten „...\" sein")
```

### Schritt 7: Abschluss-Übersicht und Ausgabe
Vor dem finalen Export eine kurze **Gesamtübersicht** aller übersetzten Strings zur letzten Kontrolle zeigen (Anzahl Batches, Anzahl Strings, Anzahl automatisch übernommener 1:1-Strings). Erst nach Simeas finalem OK exportieren:

```bash
cp datei-de.po /mnt/user-data/outputs/datei-de.po
cp datei-de_DE_formal.po /mnt/user-data/outputs/datei-de_DE_formal.po
```

---

## Workflow: German (Switzerland)

> **WICHTIG:** de_CH wird **nicht** direkt übersetzt. Die Schweizer Übersetzungen entstehen durch Konvertierung der de_DE-Übersetzungen – und erst NACH Simeas finaler Freigabe der de_DE-Dateien (Schritt 7).

### Offizieller Prozess (gemäss https://de-ch.wordpress.org/team/handbook/uebersetzungen/)

1. **de_DE informal** erstellen/vervollständigen (Human-in-the-Loop-Workflow oben)
2. **de_DE formal** erstellen (Human-in-the-Loop-Workflow oben)
3. Die fertigen, freigegebenen de_DE-Dateien durch den **PO Converter** laufen lassen:
   - Tool: **https://po.wpswitzerland.ch/**
   - Wandelt automatisch um: ß → ss, Anführungszeichen „..." → «...», EUR-Formatierung → CHF-Konventionen usw.
   - Ergebnis: de_CH informal und de_CH formal
4. Konvertierte Dateien auf translate.wordpress.org importieren
5. Allfällige Helvetismen manuell nachbessern (Velo statt Fahrrad etc.) – nur wenn nötig

### Was der PO Converter automatisch macht
| de_DE | de_CH |
|---|---|
| ß | ss |
| „Anführungszeichen" | «Anführungszeichen» |
| Tausendertrennzeichen (.) | Schweizer Konvention |
| EUR | CHF (kontextabhängig) |

### Was Claude bei de_CH-Anfragen tut
Wenn Simea eine de_CH-Übersetzung braucht:
1. Die de_DE-Dateien (informal + formal) wie gewohnt im Human-in-the-Loop-Verfahren erstellen und final freigeben lassen
2. Erst danach darauf hinweisen, dass diese anschliessend über **https://po.wpswitzerland.ch/** zu de_CH konvertiert werden

---

## Besonderheiten

### 1:1-Strings (nicht verändern, aber trotzdem auflisten)
Siehe Schritt 3b. Strings ohne Anrede-Bezug werden in beiden Varianten identisch übernommen:
- Technische Begriffe, Produktnamen, Versionsnummern
- Rein deskriptive Sätze ohne Anrede (Changelog, Fehlermeldungen ohne „du/Sie")
- Bereits übersetzte Strings ohne du/Sie-Formen
- Button-Labels und kurze UI-Labels ohne Personalpronomen (z. B. "Add new custom field", "Send to a segment") – infinitiv-/imperativähnliche Kurzform ohne Anredeform verwenden ("Neues Feld hinzufügen", "An ein Segment senden")

### Multiline msgid
```
msgid ""
"Zeile 1\n"
"Zeile 2"
msgstr ""
```
Multiline-Blöcke separat behandeln; Regex muss `re.DOTALL` verwenden.

### HTML-Inhalte
HTML-Tags und Attribute unverändert lassen. Nur den Textinhalt übersetzen.
Escaped Anführungszeichen in href-Attributen (`\"`) beibehalten.

### Changelog-Einträge
Kurz und prägnant; Imperativ oder Substantivkonstruktion je nach Original. Versionsnummern unverändert. In der Regel Teil der 1:1-Batches (Schritt 3b), ausser sie enthalten direkte Anrede.