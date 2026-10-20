# Comments to match

Two sets. Brian's own comments show the voice. The rewrites show the shape for agent work, approved by Brian
on 2026-10-20; each assumes the triage already happened (Brian's calls made, fixable points fixed, thread
read). Screenshot lines (`Bildschirmfoto ….png`) are attachments Brian adds next to the text.

## Brian's own comments

Done, with a note on what's next (869e9q92x, 🙏 from Simea):
```
@Simea Merki Payrexx Anbindung funktioniert. Ist momentan auf Testmodus gestellt, damit sbbhistoric den Flow allenfalls auch noch testen kann. Ich mache mir noch ne Subtask, um den wieder Live zu schalten.
```

Done, with where to look (869euxjgj):
```
@Simea Merki erledigt. Hier hast du eine Galerie, die keine Lightbox-Einstellung hat und trotzdem in einer Lightbox öffnet:
sarasani.swiss/pfadilager-du-packst-das/
```

Done, credit to a teammate (869et15nx):
```
@Simea Merki ist erledigt, kudos to @joschua merki
```

Bug fix, cause in one clause (869e9zk9g):
```
@Simea Merki das ist gefixt, war der Publish Press Status Bug.
```

Blocked, with what's missing (869e9q92x):
```
@Simea Merki das kann ich noch nicht weil:
die Zahlungsprovider noch nicht freigegeben sind von Payrexx
Die Versandarten noch nicht konfiguriert zu sein scheinen
```

Proposal to client and Simea (869df84gv):
```
@Nadia Lettieri / Dröpsli @Simea Merki Die Seite ist wieder online. Damit wir keine Verwirrung stiften bei den Nutzern schlage ich vor, dass wir dieses Update erst nächste Woche Donnerstag machen. Einverstanden?
```

Decision handed to Joshy (869e7a5v1):
```
@joschua merki Wir hatten letzte Nacht 40+ Nachrichten auf die Support-Mail wegen des Cron-Jobs von MailPoet bei unisono. Ich hab mal einen Vorschlag ausarbeiten lassen, wie wir das zumindest zum schweigen bringen könnten. Your call.
```

Closing on his own call (869fhccvv):
```
@Simea Merki ich habe gesehen, dass sie das hier schon selbständig eingerichtet haben. Ich schliesse den Task mal, ich gehe davon aus, dass sie sich melden, wenn sie hier Hilfe benötigen.
```

## Rewrites of agent comments

Bug fix for Simea (869fjprr3; the original ran 230 words with the cache forensics, the SSH steps and an
"Entscheid Brian" point):
```
@Simea Merki Suche und Filter auf «Fachwissen finden» gehen wieder, auf DE, FR und IT. Nach einem Plugin-Update vom 16.10. hätte der Cache geleert werden müssen, das ist nicht passiert. Nicht dasselbe wie im September, geht auf Sorgenfrei. Peter hab ich geantwortet.
```

Dev handover to Joshy, no mention of Simea (869fjkg67):
```
@joschua merki gefixt, ist live auf test-red:
- Link-Block speichert keine Icon-URL mehr im post_content, das Icon kommt per CSS
- Bestehende Blöcke migrieren beim nächsten Bearbeiten
- DB auf test-red bereinigt, 410 Stellen mit /../
WAF-Regeln 930100 und 930110 können also anbleiben. Auf red.baspomedia.ch bräuchte es dieselbe Bereinigung, falls die DB dort nicht von test-red kommt, oder?
```

Done, Brian's own open point settled in triage (869dnebmq; the plugin settings to keep off went to the repo):
```
@Simea Merki WP Rocket ist eingerichtet auf tvsent.ethz.ch, die Startseite lädt jetzt in 0.15 statt 1.5 Sekunden. Animationen laufen alle noch, hab alle Seiten durchgeklickt. Die schweren Prozessbilder auf /spielregeln/ hab ich gleich als WebP ersetzt, ein Bildoptimierungs-Plugin braucht es vorerst nicht. Für den Go-live hab ich mir ne Subtask gemacht.
```

Test task, fixable findings fixed, two decisions for Simea (869dffjeu; the original listed six open points
and asked her what to fix):
```
@Simea Merki Alle Formulare getestet, sie kommen an und die Bestätigungsmail geht raus. Die Testeinträge heissen «TEST morntag» und können weg. Hab dabei noch ein paar Sachen gefixt:
- Das Gönnerschaft-Formular auf /unterstuetzen/ war unsichtbar, ist wieder da
- Die Charterfahrt speichert jetzt das gewählte Fahrzeug
- Plakatreproduktion: Vorname ist Pflicht, Datenschutz-Checkbox ist drin
- Erfolgsmeldungen sind überall per Sie
Zwei Sachen für dich:
- Die Telefonnummer verliert die führende 0, weil das Feld nur Zahlen nimmt. Soll ich das umstellen, oder ist das so gewünscht?
- Die Mails an die SBB-Postfächer sehe ich nicht. Kann Sofia kurz bestätigen, dass sie ankommen?
```

Done, one open point left after reading the thread (869ed4rg5; a second point was already answered in
Simea's comment of 12.10 and dropped):
```
@Simea Merki Spielregeln sind umgesetzt, zum Anschauen auf tvsent.ethz.ch/spielregeln/: Abstände und Raster wie in Figma, Pfeil aussen mit Hover und Klick, Deckblatt mit Text und der weisse Moment beim Öffnen. Die Notizen von Katja und Arthur im Elementor hab ich abgearbeitet.
Eine Sache für dich und Katja: Die Projekt-Check-Buttons im Seiteninhalt gehen auf /projekt-check/, nur Header und Menü auf Notion. Sollen alle auf Notion?
```
