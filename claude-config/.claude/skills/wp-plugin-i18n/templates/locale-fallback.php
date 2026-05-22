<?php
/**
 * Locale-variant fallback + textdomain registration.
 *
 * Paste this block into your plugin's main file (after the plugin header and
 * any `defined( 'WPINC' )` guard, before module bootstrapping). Replace every
 * `{SLUG}` with your plugin slug (the directory name) and every `{SLUG_FN}`
 * with a snake_case prefix for the helper function (e.g. `myplugin_`).
 *
 * Edit the `{SLUG_FN}_map_locale_to_shipped` function to list the locale
 * variants you ship and the canonical variant they should fall back to.
 *
 * Why three pieces instead of one:
 *
 *   1. `load_textdomain_mofile` filter — rewrites PHP .mo lookups inside the
 *      WP 6.7+ JIT loader (the legacy `plugin_locale` filter no longer fires).
 *   2. `load_script_translation_file` filter — same idea for JS strings loaded
 *      via `wp_set_script_translations()`.
 *   3. `load_plugin_textdomain()` — still required to register the plugin's
 *      /languages path with `WP_Textdomain_Registry`. It does not load the
 *      .mo itself in modern WP, but without it the JIT loader has no path.
 */

/**
 * Map any locale variant to the canonical one we actually ship a .mo for.
 *
 * Without this, a user whose profile is `fr_FR` would never see French
 * translations from a plugin that only ships `fr_CH`, because WP looks for
 * an exact filename match (`{slug}-fr_FR.mo`) and falls back to msgid when
 * none exists.
 *
 * Edit the body for your shipped locales.
 *
 * @param string $locale e.g. 'fr_FR', 'it_IT', 'en_US'.
 * @return string The locale we actually have a .mo for.
 */
function {SLUG_FN}_map_locale_to_shipped( $locale ) {
	// List your shipped locales here — return them unchanged.
	if ( 'fr_CH' === $locale || 'it_CH' === $locale ) {
		return $locale;
	}
	// Any French variant → the French we ship.
	if ( 0 === strpos( $locale, 'fr_' ) || 'fr' === $locale ) {
		return 'fr_CH';
	}
	// Any Italian variant → the Italian we ship.
	if ( 0 === strpos( $locale, 'it_' ) || 'it' === $locale ) {
		return 'it_CH';
	}
	return $locale;
}

/**
 * Redirect PHP .mo lookups for variant locales to our shipped file.
 *
 * Runs inside `load_textdomain()` for every domain, including the WP 6.7+
 * just-in-time loader path. Only acts on our domain, only when the requested
 * file doesn't exist, and only when the variant actually maps to something
 * different we have on disk.
 */
add_filter(
	'load_textdomain_mofile',
	function ( $mofile, $domain ) {
		if ( '{SLUG}' !== $domain || is_readable( $mofile ) ) {
			return $mofile;
		}
		if ( ! preg_match( '/{SLUG}-([a-zA-Z_]+)\.mo$/', $mofile, $m ) ) {
			return $mofile;
		}
		$mapped = {SLUG_FN}_map_locale_to_shipped( $m[1] );
		if ( $mapped === $m[1] ) {
			return $mofile;
		}
		$candidate = preg_replace( '/{SLUG}-[a-zA-Z_]+\.mo$/', '{SLUG}-' . $mapped . '.mo', $mofile );
		return ( $candidate && is_readable( $candidate ) ) ? $candidate : $mofile;
	},
	10,
	2
);

/**
 * Same idea for JS-handle translation JSON files loaded via
 * `wp_set_script_translations()`. File shape is `{slug}-{locale}-{md5}.json`.
 */
add_filter(
	'load_script_translation_file',
	function ( $file, $handle, $domain ) {
		if ( '{SLUG}' !== $domain || file_exists( $file ) ) {
			return $file;
		}
		$dir      = dirname( $file );
		$basename = basename( $file );
		if ( ! preg_match( '/^{SLUG}-([a-zA-Z_]+)-([a-f0-9]{32})\.json$/', $basename, $m ) ) {
			return $file;
		}
		$mapped = {SLUG_FN}_map_locale_to_shipped( $m[1] );
		if ( $mapped === $m[1] ) {
			return $file;
		}
		$candidate = $dir . '/{SLUG}-' . $mapped . '-' . $m[2] . '.json';
		return file_exists( $candidate ) ? $candidate : $file;
	},
	10,
	3
);

/**
 * Standard textdomain registration. Required even on WP 6.7+ — registers the
 * path with `WP_Textdomain_Registry` so the JIT loader knows where to look.
 *
 * Replace `__FILE__` with whichever constant or expression in your plugin
 * resolves to the main plugin file path (e.g. a `MY_PLUGIN_FILE` constant).
 */
add_action(
	'plugins_loaded',
	function () {
		load_plugin_textdomain(
			'{SLUG}',
			false,
			basename( dirname( __FILE__ ) ) . '/languages'
		);
	}
);
