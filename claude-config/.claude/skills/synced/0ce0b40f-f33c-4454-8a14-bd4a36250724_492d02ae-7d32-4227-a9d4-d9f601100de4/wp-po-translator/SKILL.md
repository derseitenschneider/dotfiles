---
name: wp-po-translator
description: >
  Übersetzt WordPress .po-Dateien ins Deutsche gemäss den offiziellen WP-DE-Polyglots-Richtlinien
  (Style Guide, Glossar, Rechtschreibung, Komposita). Verwende diesen Skill wenn Simea sagt
  «übersetze diese .po-Datei», «mach die Übersetzungen», «füll die leeren msgstr aus»,
  «übersetze das WordPress-Plugin», «passe das .po-File an» oder wenn eine .po-Datei
  hochgeladen wird und Übersetzung gefragt ist. Auch verwenden wenn eine Liste von zu
  übersetzenden Strings aus einer .po-Datei vorliegt und ins Deutsche übertragen werden soll.
---

# WP .po Übersetzer (DE / DE Formal / CH)

Übersetzt WordPress .po-Dateien ins Deutsche gemäss den offiziellen WP-DE-Polyglots-Richtlinien.

**Standardmässig immer zwei Dateien ausgeben:** German (du) und German Formal (Sie).
Für German (Switzerland) gilt ein eigener Prozess – siehe unten.

---

## Wichtigste Regeln (WP-DE Style Guide)

### Anrede
- **German (de_DE):** Informelles **„du"** (kleingeschrieben)
- **German Formal (de_DE_formal):** Formelles **„Sie"** (grossgeschrieben)
- **German Switzerland (de_CH / de_CH_formal):** Kein direktes Übersetzen – Import-Prozess, siehe unten

### Stil
- Keine wörtliche Übersetzung – Inhalt sinngemäss auf Deutsch übertragen
- Aktive, kurze, prägnante Sätze
- Keine Umgangssprache (fürs → für das, nochmal → noch einmal)
- Kein Fachjargon ausser Glossar-Begriffe

### Rechtschreibung
- Typografische Anführungszeichen: „..." statt "..."
- `&` → „und" (ausser in HTML-Attributen/Entitäten)
- Zahlen mit Trennpunkt ab vierstellig: 1.000.000
- Gedankenstrich (–) statt Bindestrich (-) bei Einschüben

### Komposita (Bindestrich-Regeln)
- Englisch+Deutsch gemischt: immer Bindestrich → „Alt-Text", „KI-Engine", „API-Schlüssel"
- Reine deutsche Komposita: zusammenschreiben → „Mediathek", „Benutzeroberfläche"
- Produktnamen bleiben unverändert: WordPress, ChatGPT, Yoast SEO, Elementor, Divi

### Glossar (wichtigste Begriffe)
| Englisch | Deutsch |
|---|---|
| media library | Mediathek |
| bulk actions | Mehrfachauswahl / Massenoperation (je nach Kontext) |
| plugin | Plugin |
| feature | Funktion |
| button | Button |
| troubleshooting | Problembehandlung |
| user | Benutzer |
| settings | Einstellungen |
| attachment | Anhang |
| post | Beitrag |
| post type | Inhaltstyp |
| frontend | Frontend |
| backend | Backend |
| upload | hochladen (Verb) / Upload (Nomen) |
| download | herunterladen (Verb) / Download (Nomen) |
| browser | Browser |
| dashboard | Dashboard |
| theme | Theme |
| tag | Schlagwort |
| custom | individuell |

---

## Workflow: German + German Formal

### Schritt 1: Datei lesen
```bash
cat /mnt/user-data/uploads/datei.po
```

### Schritt 2: Leere Strings extrahieren
```python
import re
with open("datei.po") as f:
    content = f.read()
empty = re.findall(r'msgid "(.+)"\nmsgstr ""', content)
```

### Schritt 3: Übersetzen (beide Varianten)
Translations als **zwei** JSON-Dateien speichern:

```bash
cat > /home/claude/translations_de.json << 'JSONEOF'
{ "Original English string": "Deutsche Übersetzung (du)", ... }
JSONEOF

cat > /home/claude/translations_de_formal.json << 'JSONEOF'
{ "Original English string": "Deutsche Übersetzung (Sie)", ... }
JSONEOF
```

Strings ohne Anrede-Bezug (Changelog, technische Terme, Produktnamen) sind in beiden Dateien identisch.

### Schritt 4: Übersetzungen eintragen

```python
import json, re

def apply_translations(po_content, translations_path, fill_empty_only=False):
    with open(translations_path) as f:
        translations = json.load(f)
    content = po_content
    for msgid, msgstr in translations.items():
        po_msgid = msgid.replace('"', '\\"')
        po_msgstr = msgstr.replace('\\', '\\\\').replace('"', '\\"')
        if fill_empty_only:
            pattern = r'(msgid "' + re.escape(po_msgid) + r'"\nmsgstr )""'
        else:
            pattern = r'(msgid "' + re.escape(po_msgid) + r'"\nmsgstr )"[^"]*"'
        content, _ = re.subn(pattern, r'\g<1>"' + po_msgstr + '"', content)
    return content

with open("datei.po") as f:
    original = f.read()

# German (du): nur leere füllen
de = apply_translations(original, "/home/claude/translations_de.json", fill_empty_only=True)
with open("/home/claude/datei-de.po", "w") as f:
    f.write(de)

# German Formal (Sie): leere füllen + bestehende du-Strings ersetzen
de_formal = apply_translations(original, "/home/claude/translations_de_formal.json", fill_empty_only=False)
de_formal = de_formal.replace('"Language: de\\n"', '"Language: de_DE_formal\\n"')
with open("/home/claude/datei-de_DE_formal.po", "w") as f:
    f.write(de_formal)
```

### Schritt 5: Verifizieren

```python
for path, label in [("/home/claude/datei-de.po", "German"), ("/home/claude/datei-de_DE_formal.po", "Formal")]:
    with open(path) as f:
        content = f.read()
    empty = re.findall(r'msgid "(.+)"\nmsgstr ""', content)
    print(f"{label}: {len(empty)} leere msgstr")

# Formal: auf du-Formen prüfen
with open("/home/claude/datei-de_DE_formal.po") as f:
    content = f.read()
for block in content.split("\n\n"):
    ms = re.search(r'msgstr (.+)', block, re.DOTALL)
    if ms and re.search(r'\b(du |dein|dich|dir |deine|deiner|deinen|deinem)\b', ms.group(1), re.IGNORECASE):
        mid = re.search(r'msgid "(.{0,60})"', block)
        print(f"du-Form noch vorhanden: {mid.group(1) if mid else '?'}")
```

### Schritt 6: Ausgabe
```bash
cp /home/claude/datei-de.po /mnt/user-data/outputs/datei-de.po
cp /home/claude/datei-de_DE_formal.po /mnt/user-data/outputs/datei-de_DE_formal.po
```

---

## Workflow: German (Switzerland)

> **WICHTIG:** de_CH wird **nicht** direkt übersetzt. Die Schweizer Übersetzungen entstehen durch Konvertierung der de_DE-Übersetzungen.

### Offizieller Prozess (gemäss de-ch.wordpress.org)

1. **de_DE informal** erstellen/vervollständigen (Schritt 1–6 oben)
2. **de_DE formal** erstellen (Schritt 1–6 oben)
3. Die fertigen de_DE-Dateien durch den **PO Converter** laufen lassen:
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
1. Die de_DE-Dateien (informal + formal) wie gewohnt erstellen und ausgeben
2. Darauf hinweisen, dass diese anschliessend über **https://po.wpswitzerland.ch/** zu de_CH konvertiert werden

---

## Besonderheiten

### 1:1-Strings (nicht verändern)
Strings ohne Anrede-Bezug werden in beiden Varianten identisch übernommen:
- Technische Begriffe, Produktnamen, Versionsnummern
- Rein deskriptive Sätze ohne Anrede (Changelog, Fehlermeldungen)
- Bereits übersetzte Strings ohne du/Sie-Formen

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
Kurz und prägnant; Imperativ oder Substantivkonstruktion je nach Original. Versionsnummern unverändert.
