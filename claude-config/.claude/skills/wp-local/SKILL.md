---
name: wp-local
description: WordPress local dev environment CLI tools (wp-local). Manage WordPress sites, run WP-CLI, debug, clone/pull from remote servers. Use when working with WordPress sites in ~/dev/wp-local, running WP-CLI commands, managing local WordPress containers, debugging WordPress, or syncing with remote servers.
---

# wp-local Dev Tools

## Detecting the current site

If CWD is inside `~/dev/wp-local/sites/<name>/...`, extract `<name>` as the site name:
```bash
echo "$PWD" | sed -n 's|.*/wp-local/sites/\([^/]*\).*|\1|p'
```

## Running commands

Use the `wpl` alias (resolves to `~/dev/wp-local/scripts/wp`):
```bash
wpl <command> <site-name> [options]
```

**Important**: Commands use `docker-compose` (v1 with hyphen), NOT `docker compose`.

## Command cheatsheet

| Command | Usage | Purpose |
|---------|-------|---------|
| `create` | `wpl create <name> [--plugin <path>] [--multisite]` | Create new WP site |
| `clone` | `wpl clone <name> --from <ssh> --path <remote-path>` | Clone from remote server |
| `pull` | `wpl pull <name> [--db-only\|--skip-db] [--skip-uploads]` | Sync from remote |
| `start` | `wpl start <name>` | Start site containers |
| `stop` | `wpl stop <name\|--all>` | Stop site(s) |
| `restart` | `wpl restart <name>` | Restart site |
| `list` | `wpl list` | List all sites with status |
| `destroy` | `wpl destroy <name>` | Remove site completely |
| `config` | `wpl config <name> php <8.0\|8.1\|8.2\|8.3>` | Change PHP version |
| `cli` | `wpl cli <name> <wp-command>` | Run WP-CLI command |
| `db` | `wpl db <name>` | Show DB credentials |
| `logs` | `wpl logs <name>` | View live container logs |
| `shell` | `wpl shell <name>` | Open bash in WP container |

## Common workflows

### Run WP-CLI
```bash
wpl cli mysite plugin list
wpl cli mysite option get siteurl
wpl cli mysite user list
wpl cli mysite search-replace 'old' 'new' --dry-run
```

### Debug a site
1. Check debug log: `~/dev/wp-local/sites/<name>/wp-content/debug.log`
2. Live container logs: `wpl logs <name>`
3. Open shell: `wpl shell <name>`
4. DB credentials: `wpl db <name>`

### Access URLs
- Site: `http://<name>.test`
- Admin: `http://<name>.test/wp-admin` (auto-login as admin)
- phpMyAdmin: `http://pma.test`
- Multisite subdomains: `http://<sub>.<name>.test`

### Plugin development
Mount a local plugin repo during creation:
```bash
wpl create mysite --plugin ~/dev/my-plugin
```
Changes to the plugin directory are immediately reflected in the container.

### Remote sync
```bash
wpl clone mysite --from prod --path /var/www/html        # Initial clone
wpl pull mysite                                           # Full sync
wpl pull mysite --db-only                                 # Database only
wpl pull mysite --skip-db                                 # Files only
wpl pull mysite --exclude-plugin local-plugin             # Protect a plugin
wpl pull mysite --dry-run                                 # Preview changes
```

**Table prefix auto-detection:** After DB import, clone/pull verify the actual table prefix by scanning imported tables. If the prefix differs from what was detected remotely (e.g., remote WP-CLI silently fell back to `wp_`), it warns and fixes `wp-config.php` automatically.

See [REFERENCE.md](REFERENCE.md) for full flag details, remote operations, site structure, and troubleshooting.

## WordPress defaults (auto-configured)
- Credentials: `admin` / `admin` / `brian@morntag.com`
- Locale: `de_CH_informal`, Timezone: `Europe/Zurich`
- Permalinks: `/%postname%/`, Date: `d.m.Y`, Time: `H:i`
- Debug logging enabled (to file, not displayed)
- Auto-login mu-plugin (no login required locally)

## Key paths
```
~/dev/wp-local/scripts/wp              # CLI tool (aliased as wpl)
~/dev/wp-local/sites/<name>/           # Site directory
~/dev/wp-local/sites/<name>/wp-content # WordPress content (plugins, themes, uploads)
~/dev/wp-local/sites/<name>/.env       # Site environment config
~/dev/wp-local/sites/<name>/.remote    # Remote sync config (if cloned)
```
