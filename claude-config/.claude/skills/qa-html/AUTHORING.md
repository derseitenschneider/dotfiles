# Authoring QA items

Items are model-authored per feature, not picked from a template. Two people can only trust a checklist if every line is a claim that is unambiguously true or false after one action. That is the bar.

## Rules

**One observable check per item.** If verifying it needs two unrelated actions, it is two items. "Students list, table and dialogs localized" is acceptable as one item only because it is one sweep of one surface; "students localized and Stripe checkout localized" is two.

**The title is a claim, not a topic.** Write what must be true, so the tester is deciding a verdict rather than guessing what you meant.

- Good: `A missing key renders German, never a raw key path`
- Bad: `Fallback behaviour`, `Check translations`, `Language switcher`

**`how` must be followable without reading code.** Name the route, the control, the input, and the thing to look at. The tester may not be an engineer, and will not open the repo.

- Good: `Settings → Appearance. Switch to fr, reload, then open on another device — the choice sticks.`
- Bad: `Verify the locale persists via the settings mutation hook.`

**Group by surface, in the order a human would walk it.** Anonymous surfaces before authenticated ones, UI before background systems, regression checks last. 5–10 sections of 2–8 items each is the comfortable range; past ~60 items the run stops getting finished.

**Cover the four families**, not just the happy path:
1. The change itself works on its primary path.
2. Its edges: empty, invalid, too long, offline, permission-denied, the fallback branch.
3. Anything the change could have broken that it does not own (regression).
4. Things you already know are wrong or unverified — file them as items with a flag rather than leaving them out. A known gap the tester rediscovers is wasted testing.

**`key` is a breadcrumb, not documentation.** A filename, constant, feature flag or column that lets the fixing agent jump straight to the code. Omit rather than pad.

**Flags carry what you know that the tester does not.** Define the vocabulary per run, in `FLAGS`. Useful shapes: something shipped unreviewed (`needs` tone), something already confirmed but worth re-checking (`pass` tone), a known defect being tracked (`fail` tone). Do not flag everything — a flag on every item is a flag on nothing.

**Do not smuggle the fix into the item.** The item says what to check; where the cause is suspected, one clause at the end of `how` is the limit.

## Worked example — Eleno i18n launch

Five locales (de/en/fr/it/es) shipped at once; fr/it/es copy shipped without native review. The console ran ~45 items over 10 sections: known gaps → anonymous auth → legal links → authenticated app UI → import/export → Stripe → CRM lifecycle → landing page → manual → regression.

```js
const FLAGS = {
  gap:     { label: "known gap",    tone: "fail"  },
  loc:     { label: "unreviewed",   tone: "needs" },
  chk:     { label: "spot-checked", tone: "pass"  },
};

const QA = [
  { id:"gaps", title:"Known localization gaps (flagged for fix)", items:[
    { id:"gap-authemail", t:"Supabase Auth emails untranslated (confirm signup, reset password, magic link)",
      how:"Sent by Supabase Auth from single global templates, outside the app catalogs. Verify which auth email types actually fire in prod and in which language; note the desired copy per locale.",
      key:"user_metadata.i18n_locale", flags:["gap","loc"] },
  ]},
  { id:"auth", title:"Anonymous auth surfaces", items:[
    { id:"auth-fr", t:"French signup / login card renders fully localized",
      how:"app.eleno.net in a French browser (or picker → Français). No German or English text leaking anywhere on the card.",
      flags:["loc","chk"] },
    { id:"auth-fallback", t:"Unsupported browser language falls back to English, not German",
      how:"Set navigator.language to pt-PT → English card. de is the key-fallback, en is the resolution-fallback." },
  ]},
  { id:"regression", title:"Regression & cross-cutting", items:[
    { id:"reg-existing", t:"Existing de / en users see no change or breakage",
      how:"Log in as a German and an English user — everything works exactly as before." },
    { id:"reg-flash", t:"No flash of wrong language on first paint",
      how:"Hard-reload a fr session — the correct language paints immediately, no German-then-swap flicker.",
      flags:["loc"] },
  ]},
];
```

Note the pattern: known gaps are **section 01**, so the tester sees up front what is already known broken; every fr/it/es copy item carries `loc` so unreviewed copy gets the closest read; and the last section is pure regression on the locales that were already live.

## Fix prompt example

```
You are picking up hand-testing QA for the i18n launch (5 locales) in the eleno
monorepo, branch i18n. Prod is v2.57.0.

Everything under "Worklist" below is a defect a human actually observed while
testing. The passed / N/A / untested sections are context only — do not work them.

For each worklist item, top to bottom:
1. Reproduce it before you change anything. Do not fix from the description alone.
2. Fix the root cause, not the symptom.
3. Add or extend a test that would have caught it.
4. Log the fix in .docs/BUG_FIXES.md per the convention in CLAUDE.md.

Ground rules:
- Stay inside app/src/services/i18n/, the locale catalogs, and the components named
  in each item. Ask before touching anything outside that.
- Ask before schema changes, dependency bumps, or anything needing a deploy.
- Copy changes in fr/it/es must follow .docs/BRAND_VOICE_{FR,IT,ES}.md.
- If an item is ambiguous or you cannot reproduce it, ask instead of guessing.
- Report at the end: what you fixed, what you skipped, and why.
```

Everything the receiving agent needs is in the paste: repo, branch, build, which sections are actionable, the fix loop, the logging convention, and a hard boundary on scope.
