# Comments Brian kept

Abschlusskommentare Brian left standing. Match their density. The first one is the current shape (2026-10-08,
after Brian rejected a version with a bold title, a mention at the end, PR links and the open points as a
prose clause); the older three predate the two-section rule but show the density.

## Handover to a teammate with open decisions (task 869dnebu8, 2026-10-08)

```
[@Simea Merki](#user_mention#2438286) Accessibility-Check umgesetzt, Stand 8.10.2026. Plugin mcc-visual-studio 0.12.0 ist auf Staging (tvsent.ethz.ch), alles dort im Browser mit Tastatur geprüft.

Erledigt
- Überschriften: /spielregeln/, /services/, /projekt-check/ und die Projekt-Detailseiten haben jetzt eine saubere H1–H3-Struktur, optisch unverändert. Alle anderen Seiten waren bereits in Ordnung.
- Tastatur: Der Skip-Link führt in den Hauptinhalt, der Fokusrahmen ist auch im dunklen Footer sichtbar, Menü-Icon und ETH-Logo haben einen Namen, das Menü-Popup lässt sich per Tastatur schliessen. Tool-Kategorien und Kapitel auf /spielregeln/ sowie die Service-Karten lassen sich mit Enter bedienen, das Awards-Accordion versteckt zugeklappte Inhalte.
- Formulare /kontakt/: Labels eindeutig zugeordnet, autocomplete für Name, E-Mail und Telefon, Honeypot-Feld aus der Tab-Reihenfolge genommen.

Offen
- Startseite ohne H1, bleibt wie besprochen.
- Formular-Labels sind nur für Screenreader sichtbar, sichtbare Labels statt Platzhalter wären besser. Design-Entscheid bei dir und Katja.
```

## Rollout across sites (task 869f3xgz7, 2026-10-08)

```
Umgesetzt (Variante 1), 7./8.10.2026

morntag-client 0.11.0 blockiert Core-Auto-Updates (dev/minor/major) auf jeder Seite mit aktivem Plugin. Plugin-, Theme- und Übersetzungs-Updates sowie manuelle Core-Updates bleiben unverändert. wp morntag status zeigt den Zustand.
Per SSH/WP-CLI auf alle 11 Seiten mit dem Plugin ausgerollt und verifiziert: athletes, carvelo, dpr, hindernisfreie-architektur, labmag, meinwettenberg, renovita, sarasani-new, unisono, uzh, wuhrmanngarten.
WP_AUTO_UPDATE_CORE vom 18.9. aus der wp-config entfernt auf athletes, hindernisfreie-architektur, labmag, sarasani-new. carvelo und uzh: Konstante stammt von Raidboxes (wp-config gehört root), bleibt. dpr, renovita, unisono, wuhrmanngarten haben stattdessen das ältere AUTOMATIC_UPDATER_DISABLED, nicht angefasst.
Ohne Plugin, daher weiter nur Konstante: paneco, naturzentrumthurauen. baspo-test-red ohne Schutz.

Doku: audits/2026-10-07-client-plugin-0.11.0. Offen: Prozess für Sicherheitsupdates, Admin-Mail an Kunden.
```

Brian wrote this one himself after deleting three longer comments (a report, a correction, a question).
Note what is absent: how the survey ran, which WP-CLI flags were needed, the backups taken, the environment
quirks of single hosts.

## Check with no change needed (task 869f432n0, 2026-09-18)

```
Geprüft 2026-09-18: Website nicht betroffen. Sie verschickt Mails (Kontaktformular) per PHP mail() über Hostpoint, nicht per SMTP-Login bei Microsoft 365. Kein SMTP-Plugin aktiv, keine Anpassung nötig. Die von Sorba gemeldete Basic-Auth-Nutzung von info@ stammt vom Druckercenter (Scan-to-Mail), das Graphax bereits aktualisiert hat.
```

## Bug fix with cause (task 869f8ucb8, 2026-09-29)

```
Behoben am 29.09.2026. Ursache: Das Plugin UserPro entfernt auf der ganzen Website die Versionsnummer (?ver=) aus allen CSS- und JS-Adressen, und WP Fastest Cache lässt Browser statische Dateien 120 Tage zwischenspeichern. Nach den Elementor-Updates vom 23./25.09. haben Browser mit älterem Cache deshalb weiter die alten Elementor-Scripts verwendet, und die seitlichen Links «Publikationen herunterladen» (Elementor Off-Canvas) haben nicht mehr reagiert. Lösung: Neues WPCode-Snippet 67858 «Versionsnummern an CSS/JS wiederherstellen (UserPro)» hebt diesen UserPro-Filter auf, danach Cache auf allen drei Domains geleert. Alle Scripts haben jetzt wieder eine Versionsnummer, künftige Updates erreichen die Browser also automatisch. Vorher lokal auf einer Kopie getestet, auf Prod geprüft (Links öffnen, keine Fehler). Details: docs/cases/2026-09-29-hindernisfreie-architektur-stale-elementor-js.md im Repo maintenance-clients.
```

## The pattern to avoid

Task 869f3ueya carries seven comments on one issue: "Analyse", "Nachtrag Aufwand", "Präzisierung zur
Beweislage", "Umsetzungsplan", each 150 to 400 words, plus Brian's own two-liners. Everything in them that
mattered fits the shape above; the rest lives in the case file it already links.
