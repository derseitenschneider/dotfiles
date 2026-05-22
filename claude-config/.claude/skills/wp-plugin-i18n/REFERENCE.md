# wp-plugin-i18n — Reference

Companion to `SKILL.md`. Patterns and code snippets for the day-to-day work after the plumbing is in place.

Every snippet uses `{slug}` as the placeholder for your plugin's text-domain (the directory name).

## Per-context escape helpers (PHP)

Pick the helper by the context the string lands in. The codesniffer (with `WP.I18n` pinned) will flag the wrong choice.

```php
echo esc_html__( 'Status', '{slug}' );                              // HTML body
echo esc_attr__( 'Label', '{slug}' );                               // HTML attribute
echo wp_kses_post( __( '<strong>Note</strong>', '{slug}' ) );        // allowed HTML
printf(
    /* translators: %d: number of entries */
    esc_html__( '%d entries', '{slug}' ),
    (int) $count
);
```

Placeholders always require a `/* translators: ... */` comment immediately above the call. phpcs blocks otherwise.

## When to use `_x()` (msgctxt)

Use `_x()` (or `_ex()` / `esc_html_x()` / `esc_attr_x()`) when the same source word means different things in different UI contexts, so translators can render them differently.

```php
_x( 'Order', 'post sort field',        '{slug}' );
_x( 'Order', 'noun for a purchase',    '{slug}' );
```

Without `msgctxt` these would dedupe to one msgid and translators couldn't disambiguate.

## CPT and taxonomy labels

WordPress reads the `$labels` array per active locale. Wrap every key your plugin uses — partial wraps produce half-translated admin chrome.

```php
$labels = array(
    'name'                  => _x( 'Things',   'post type general name',  '{slug}' ),
    'singular_name'         => _x( 'Thing',    'post type singular name', '{slug}' ),
    'add_new'               => __( 'Add New',                              '{slug}' ),
    'add_new_item'          => __( 'Add new Thing',                        '{slug}' ),
    'edit_item'             => __( 'Edit Thing',                           '{slug}' ),
    'new_item'              => __( 'New Thing',                            '{slug}' ),
    'view_item'             => __( 'View Thing',                           '{slug}' ),
    'view_items'            => __( 'View Things',                          '{slug}' ),
    'search_items'          => __( 'Search Things',                        '{slug}' ),
    'not_found'             => __( 'No Things found.',                     '{slug}' ),
    'not_found_in_trash'    => __( 'No Things found in Trash.',            '{slug}' ),
    'parent_item_colon'     => __( 'Parent Thing:',                        '{slug}' ),
    'all_items'             => __( 'All Things',                           '{slug}' ),
    'archives'              => __( 'Thing Archives',                       '{slug}' ),
    'attributes'            => __( 'Thing Attributes',                     '{slug}' ),
    'insert_into_item'      => __( 'Insert into Thing',                    '{slug}' ),
    'uploaded_to_this_item' => __( 'Uploaded to this Thing',               '{slug}' ),
    'featured_image'        => __( 'Featured image',                       '{slug}' ),
    'set_featured_image'    => __( 'Set featured image',                   '{slug}' ),
    'remove_featured_image' => __( 'Remove featured image',                '{slug}' ),
    'use_featured_image'    => __( 'Use as featured image',                '{slug}' ),
    'menu_name'             => __( 'Things',                               '{slug}' ),
    'filter_items_list'     => __( 'Filter things list',                   '{slug}' ),
    'items_list_navigation' => __( 'Things list navigation',               '{slug}' ),
    'items_list'            => __( 'Things list',                          '{slug}' ),
);
```

Also wrap the `description` field in the `$args` you pass to `register_post_type()` / `register_taxonomy()`.

If your plugin's data structure builds CPT registrations from an array, build the labels via `sprintf( __( 'Add new %s', '{slug}' ), $singular )` with translator comments — single wrap pattern, no duplicated literals.

## JavaScript

In the JS source:

```js
import { __, _x, sprintf } from '@wordpress/i18n';

__( 'Save', '{slug}' );

sprintf(
    /* translators: %s: post type label */
    __( 'Add %s', '{slug}' ),
    label
);
```

In the PHP that enqueues the script:

```php
wp_register_script(
    'my-handle',
    plugins_url( 'build/index.js', __FILE__ ),
    array( 'wp-i18n', /* other deps */ ),
    $version,
    true
);
wp_set_script_translations(
    'my-handle',
    '{slug}',
    plugin_dir_path( __FILE__ ) . 'languages'
);
```

**Both pieces are required.** Without `wp-i18n` in the deps the import resolves to a no-op in the browser; without `wp_set_script_translations` WordPress doesn't know to load the per-handle JSON file at runtime.

If you call `wp_localize_script()` for the same handle, put `wp_set_script_translations()` *after* it. Otherwise inline data ordering can break.

Modules written as plain JS (no `@wordpress/scripts` build) can use the global instead:

```js
const { __ } = wp.i18n;
```

…with `wp-i18n` still in the enqueue deps.

## block.json

```json
{
  "title":       "My Block",
  "description": "What the block does.",
  "keywords":    ["editor", "thing"],
  "textdomain":  "{slug}"
}
```

WP 5.5+ auto-extracts `title`, `description`, `keywords`, `styles[].label`, `variations[].title|description` into the POT when `wp i18n make-pot` runs from the plugin root. No code call required — but the `textdomain` field MUST be correct, and if your build step copies `block.json` from `src/` to `build/`, both copies need it.

## The daily "add a string" workflow

```
1. Write the string in code with the right wrapper (see above).
2. composer i18n:pot              # regenerates languages/{slug}.pot
3. Open languages/{slug}-<locale>.po, fill msgstr for each new msgid.
4. composer i18n:all              # pot → po merge → mo compile → JSON split
5. Commit source + POT + PO + MO + JSON files together.
```

If step 3 is skipped, the string ships untranslated and falls back to the source language. CI warns but doesn't block.

## Adding a new target locale

```
1. cp languages/{slug}.pot languages/{slug}-<locale>.po
2. Edit the .po header: Language: <locale>
3. Fill msgstr entries.
4. composer i18n:mo && composer i18n:json
5. Commit.
```

If the locale is a regional variant you ship (`fr_CH` etc.) and you want other variants (`fr_FR`, `fr_BE`) to fall back to it, add the mapping to the locale-fallback function in your main plugin file.

The deploy target site must have the locale installed (`wp language core install <locale>`) before WP will resolve translations for it.

## Renaming or removing a string

`composer i18n:pot` removes the old msgid from the POT. `composer i18n:po` (which runs `wp i18n update-po`) marks the corresponding `.po` entries obsolete (`#~ msgid ...`). Safe to leave; prune periodically.

## Release packaging

The release ZIP **must** include `languages/`. If you build releases via rsync or a custom script with exclusion lists, double-check the `.mo` and `.json` files aren't filtered out — `.mo` is binary, `.json` is per-script-handle, and both are required at runtime.

A defensive CI check:

```bash
unzip -l dist/my-plugin.zip | grep -q 'languages/.*\.mo' || { echo "ZIP missing .mo files"; exit 1; }
```

## Troubleshooting beyond the diagnostic

If `scripts/i18n-diagnostic.php` doesn't surface the cause:

| Symptom | Likely cause |
|---|---|
| `__()` returns the msgid in admin, but the `.mo` is on disk and named correctly | User locale variant doesn't match your shipped locale and the `load_textdomain_mofile` filter isn't wired or doesn't cover it. |
| Strings in admin translate but JS strings stay in source language | Missing `wp_set_script_translations()` call, or `wp-i18n` not in the script's deps. Confirm by viewing page source — the script's translation JSON should appear inline. |
| Front-end translates per-page-language (multilingual plugin like Polylang/WPML), but admin doesn't | `get_user_locale()` (admin) and `get_locale()` (front-end) take different code paths; the multilingual plugin filters the latter. This is expected. |
| Block titles/descriptions stay in source language | `"textdomain"` missing or wrong in `block.json`. Check both `src/*/block.json` and `build/*/block.json`. |
| Strings disappear from POT after editing | `composer i18n:pot` was run from the wrong directory, or your `--exclude=` list accidentally covers source dirs. |
| POT diff in CI but you didn't add a string | Someone removed a string, or the source file moved (POT records source-line references). Run `composer i18n:pot` locally, commit the diff. |
| CI fails with "POT-Creation-Date changed" | Your CI's diff isn't filtering the volatile header line. See `templates/ci-i18n-job.yml` — the canonical diff invocation excludes it. |

## What this skill deliberately does not cover

- **Multilingual content plugins** (Polylang, WPML, TranslatePress) — they translate posts/terms/menus, which is content not code. `__()` and `.mo` cover code strings; the multilingual plugin owns content. The two layers coexist; this skill is about the code-string layer only.
- **Multi-textdomain plugins** (e.g. a parent plugin shipping multiple independently-distributed add-ons) — you'd need to repeat this setup per text-domain. The skill's templates handle one.
- **Theme i18n** — themes use `load_theme_textdomain()` instead of `load_plugin_textdomain()`. Different path, same JIT-loader behavior in WP 6.7+, so the filter pattern still applies.
- **WP-CLI string extraction internals** — if `wp i18n make-pot` is missing strings it should find, that's a WP-CLI bug or a misconfigured `--exclude`; debug separately.
