---
name: wp-plugin-i18n
description: Add internationalization to a WordPress plugin — text-domain wiring, locale-variant fallback compatible with WP 6.7+ just-in-time translation loading, composer i18n scripts, phpcs WP.I18n enforcement, CI POT-freshness gate, and a diagnostic for "__() returns the msgid" debugging. Use when adding translations to a WordPress plugin, wrapping strings in __() / esc_html__() / _x(), setting up a text-domain, generating .pot / .po / .mo / JSON files, fixing untranslated strings, or when the user mentions WordPress i18n, internationalization, translation, text domain, gettext, wp_set_script_translations, or load_plugin_textdomain.
---

# wp-plugin-i18n

Opinionated, one-canonical-path recipe for translating a WordPress plugin. Prescriptive on purpose — pick a different shape only if you actually have a multi-textdomain or theme-coupled plugin.

## The WP 6.7 trap (read first)

Most online tutorials are wrong for modern WordPress.

- `load_plugin_textdomain()` is a **no-op for loading** since WP 6.7. It now only registers your `/languages` path with `WP_Textdomain_Registry`. Actual `.mo` loading happens lazily via `_load_textdomain_just_in_time()` the first time a string in your domain is requested.
- The JIT loader **does not fire the `plugin_locale` filter**. The classic "fallback for user locale" snippet you'll find in old tutorials silently does nothing.
- The filters that DO still run inside the JIT path are `load_textdomain_mofile` (PHP strings) and `load_script_translation_file` (JS strings via `wp_set_script_translations`). This recipe uses both.

You still call `load_plugin_textdomain()` on `plugins_loaded` — it's required to register the path — but don't expect it to load anything.

## Quick start checklist

Run through these once per plugin. Files to copy from `templates/`:

1. **Plugin header** — add `Text Domain: {slug}` and `Domain Path: /languages` to the plugin's main file header. See `templates/plugin-header.php`.
2. **Loader + locale-variant fallback** — paste `templates/locale-fallback.php` into the main plugin file. Replace every `{SLUG}` with your plugin slug (the directory name). Edit the locale map for your shipped locales.
3. **Languages directory** — `mkdir languages && touch languages/.gitkeep`. Commit the dir so the JIT loader's `is_readable()` checks have something to find.
4. **Composer scripts** — merge `templates/composer-i18n-scripts.json` into your `composer.json` `scripts` block. Adjust `--exclude=` to match your repo's non-source dirs.
5. **phpcs enforcement** — merge `templates/phpcs-i18n.xml` into your `phpcs.xml` to pin the text-domain.
6. **CI gate** — copy `templates/ci-i18n-job.yml` into your GitHub Actions workflow as a new job. Blocks on stale POT, warns on missing msgstr.
7. **Generate POT, bootstrap target locales** — `composer i18n:pot`; then `cp languages/{slug}.pot languages/{slug}-<locale>.po` for each target, edit the `Language:` header, commit.

After step 7 the plumbing is done. Existing strings still render in the source language until you wrap them.

## Wrapping the first slice

Don't try to wrap every string at once. Pick one module, ship it, repeat. Per module:

1. Run `./vendor/bin/phpcs --standard=phpcs.xml <module-dir>/` — surfaces unwrapped strings and missing-translator-comment violations.
2. Grep for unwrapped capitalised literals as a backstop: `grep -nrE "['\"][A-ZÄÖÜ][a-zäöü][^'\"]{3,}['\"]" <module-dir>/ | grep -vE "(use |namespace |class |->|::|register_)"`.
3. Wrap PHP with `__()` / `esc_html__()` / `esc_attr__()` / `_x()` — see `REFERENCE.md` for the per-context helper table and the full CPT/taxonomy `$labels` template.
4. For any JS file: import `__` from `@wordpress/i18n`, wrap strings, and on the PHP enqueue side add `wp-i18n` to deps + call `wp_set_script_translations( $handle, '{slug}', plugin_dir_path( __FILE__ ) . 'languages' )`. Without that call JS strings never translate.
5. For `block.json` files: set `"textdomain": "{slug}"`. WP 5.5+ auto-extracts `title`, `description`, `keywords`, `styles[].label`, `variations[].title|description` into the POT — no code call required.
6. `composer i18n:pot` then fill new `msgstr` entries in each target `.po`. `composer i18n:all` to compile.
7. Smoke test: switch user locale in WP admin profile, reload the module's UI, confirm translation. Repeat per target locale.

## When `__()` returns the msgid (the diagnostic)

Drop `scripts/i18n-diagnostic.php` into `wp-content/mu-plugins/`. It logs what the JIT loader saw — `determine_locale()`, `get_user_locale()`, the path it looked for, whether the file is readable. This is exactly the gap that costs 30 minutes of guessing every time. Remove the file once you've identified the cause.

Most common causes, in order: (1) user locale is a variant you don't ship and the fallback filter isn't wired (the WP 6.7 trap); (2) `.mo` exists but wasn't regenerated after editing `.po` — run `composer i18n:mo`; (3) JS strings — you forgot `wp_set_script_translations()`; (4) text-domain typo — phpcs would have caught it if pinned.

## Further reading

- `REFERENCE.md` — per-context PHP escape helpers, full CPT/taxonomy `$labels` template, JS patterns, daily add-a-string workflow, troubleshooting.
- `templates/` — copy-paste source files.
- `scripts/i18n-diagnostic.php` — the mu-plugin diagnostic.
