# Angebots-Struktur (Markdown-Output)

Simea überträgt den Angebotstext danach selbst in Bexio. Liefere darum sauberen, direkt copy-paste-fähigen **Markdown-Text** — kein docx, keine Tabellen mit komplexem Layout, keine Kopf-/Fusszeilen-Grafiken (die macht Bexio automatisch).

Nutze folgende Struktur als Grundgerüst, angepasst an Projekt- vs. Vorprojekt-Angebot. Übernimm nur die Abschnitte, die für den konkreten Fall relevant sind — kein Abschnitt ist Pflicht, wenn er nicht passt.

## Projekt-Angebot

```
Guten morntag!

Vielen Dank für [Anlass des Gesprächs / der Anfrage].
Gerne unterbreiten wir dir folgendes Angebot:

## Eckdaten
[Kurzbeschrieb: Was wird gebaut/gemacht, mit welcher Technik/Ansatz, wie läuft die Zusammenarbeit ab]

## Zeitplan
- Geplanter Start: [Datum]
- Geplanter Abschluss/Launch: [Datum]
[Hinweis, wovon die Einhaltung des Zeitplans abhängt]

## Zahlungsmodalitäten
Das Angebot ist als Pauschalpreis zu verstehen.
- 50 % bei Projektstart fällig
- 50 % bei Projektabschluss fällig, spätestens am [Datum]

## Option A / B / C: [Name der Option]
[Beschreibung, was enthalten ist]
Preis: CHF [Betrag] (exkl. MWST)

## Leistungsumfang & Abgrenzung
- Was der Pauschalpreis abdeckt
- Was NICHT enthalten ist (separate Vereinbarung nötig)
- Fehlerbehebungen/Anpassungen ohne neue Funktionen: i.d.R. 30 Tage nach Go-Live inbegriffen

## Reisekosten (falls relevant)
CHF 0.90/km exkl. MWST + CHF 70.00/Std. Fahrzeit, Hotelübernachtung effektiv

## Kostenpflichtige Plugins/Programme (falls relevant)
[Liste, wer lizenziert/bezahlt was]

## Projektabschluss
[Übergabe-Prozedere, Retro-Gespräch, Übergang in Maintenance falls Thema]

## Fakturierung
Zwei Teilrechnungen (Start / Abschluss), Pauschalpreis.

Total: CHF [X]
Zzgl. MWST 8.1 %: CHF [X]
Betrag inkl. MWST: CHF [X]

Wir hoffen, unser Angebot entspricht deinen Vorstellungen und stehen bei Fragen gerne zur Verfügung.

Lieb grüsst
Team morntag
```

## Vorprojekt-Angebot

Gleiche Grundstruktur, aber statt «Eckdaten» ein Abschnitt **«Hinweise zum Vorprojekt»**:

```
## Hinweise zum Vorprojekt
Dieses Angebot umfasst ein Vorprojekt: [kurz, was geklärt/prototypisiert wird].
Die Beauftragung des Vorprojekts verpflichtet nicht zur Beauftragung der anschliessenden Umsetzung. Ohne Vorprojekt können wir jedoch keine verlässlichen Preise für die nachfolgende Umsetzung nennen.
```

Danach analog: Zahlungsmodalitäten (50/50), Optionen (typischerweise Workshops wie MVP-Umfang bestimmen, Workflows klären, Datenmodellierung — mit Tagesansätzen als Pauschale, nicht als Stundensatz), Leistungsumfang, Fakturierung.

## Wichtige Zahlen & Fakten

- **MWST-Normalsatz Schweiz (Stand 2026): 8.1 %.** (Nicht mehr 7.7 % — das war der alte Satz bis Ende 2023. Falls unsicher, kurz bei Simea nachfragen, ob sich der Satz geändert hat.)
- Firmendaten für die Fusszeile (falls Simea sie im Fliesstext braucht): morntag GmbH, Zurzacherstrasse 81, 5200 Brugg, team@morntag.com, +41 79 811 90 30, IBAN CH47 0839 0037 9269 1000 5, MWST-Nr. CHE-470.377.920 MWST. Diese Angaben normalerweise NICHT ins Markdown schreiben, da Bexio sie automatisch aus der Vorlage zieht — nur auf Nachfrage einfügen.
- Preise im Angebotstext werden exkl. MWST ausgewiesen, mit Total/Zzgl. MWST/Betrag inkl. MWST am Schluss.
