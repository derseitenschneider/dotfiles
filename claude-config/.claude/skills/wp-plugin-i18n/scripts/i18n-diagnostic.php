<?php
/**
 * Plugin Name: i18n Diagnostic (temporary)
 * Description: Logs every textdomain load attempt + locale state to debug.log. Drop into wp-content/mu-plugins/, reproduce the "__() returns the msgid" bug, then DELETE THE FILE.
 *
 * Replace YOUR_PLUGIN_SLUG below with the slug you're debugging.
 *
 * Reads `wp-content/debug.log` via your usual workflow (e.g. `tail -f`).
 * Requires WP_DEBUG + WP_DEBUG_LOG enabled in wp-config.php.
 */

const I18N_DIAG_DOMAIN = 'YOUR_PLUGIN_SLUG';

/**
 * Snapshot of the locale-resolution state at any given moment.
 */
function i18n_diag_snapshot( $label ) {
	$user_id   = function_exists( 'get_current_user_id' ) ? get_current_user_id() : 0;
	$user_loc  = ( $user_id && function_exists( 'get_user_locale' ) ) ? get_user_locale( $user_id ) : 'n/a';
	$det_loc   = function_exists( 'determine_locale' ) ? determine_locale() : get_locale();
	$registry  = '';
	if ( function_exists( 'wp_get_textdomain_registry' ) ) {
		$reg     = wp_get_textdomain_registry();
		$registry = $reg ? ( $reg->get( I18N_DIAG_DOMAIN, $det_loc ) ?: '(not registered)' ) : '(registry unavailable)';
	}
	error_log(
		sprintf(
			'[i18n-diag] %s | domain=%s user_id=%d user_locale=%s determine_locale=%s registered_path=%s',
			$label,
			I18N_DIAG_DOMAIN,
			$user_id,
			$user_loc,
			$det_loc,
			$registry
		)
	);
}

/**
 * Every .mo lookup attempt — including JIT loads, including failures.
 */
add_filter(
	'load_textdomain_mofile',
	function ( $mofile, $domain ) {
		if ( I18N_DIAG_DOMAIN !== $domain ) {
			return $mofile;
		}
		error_log(
			sprintf(
				'[i18n-diag] load_textdomain_mofile | domain=%s file=%s readable=%s',
				$domain,
				$mofile,
				is_readable( $mofile ) ? 'yes' : 'NO'
			)
		);
		return $mofile;
	},
	1,
	2
);

/**
 * Every JS-translation JSON lookup.
 */
add_filter(
	'load_script_translation_file',
	function ( $file, $handle, $domain ) {
		if ( I18N_DIAG_DOMAIN !== $domain ) {
			return $file;
		}
		error_log(
			sprintf(
				'[i18n-diag] load_script_translation_file | domain=%s handle=%s file=%s exists=%s',
				$domain,
				$handle,
				$file,
				file_exists( $file ) ? 'yes' : 'NO'
			)
		);
		return $file;
	},
	1,
	3
);

/**
 * Snapshot after textdomain loads complete (or fail).
 */
add_action(
	'plugins_loaded',
	function () {
		i18n_diag_snapshot( 'plugins_loaded' );
	},
	999
);

add_action(
	'init',
	function () {
		i18n_diag_snapshot( 'init' );
	},
	999
);

add_action(
	'admin_init',
	function () {
		i18n_diag_snapshot( 'admin_init' );
	},
	999
);
