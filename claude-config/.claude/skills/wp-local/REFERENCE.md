# wp-local Full Reference

## Complete command reference

### `wpl create <name> [options]`
Create and auto-install a WordPress site.

| Flag | Description |
|------|-------------|
| `--plugin <path>` | Mount local plugin directory into the site |
| `--multisite` | Install as Multisite with subdomain mode |

Creates site in `~/dev/wp-local/sites/<name>/`, starts Docker containers, installs WordPress with all defaults (locale, timezone, permalinks), removes default content (Hello World, Sample Page, Akismet, Hello Dolly), adds auto-login mu-plugin.

### `wpl clone <name> --from <ssh> --path <path> [options]`
Clone a WordPress site from a remote server via SSH.

| Flag | Description |
|------|-------------|
| `--from <ssh-host>` | **Required.** SSH hostname or alias |
| `--path <remote-path>` | **Required.** Remote WordPress root path |
| `--exclude-plugin <name>` | Don't copy this plugin (repeatable, saved) |
| `--exclude-theme <name>` | Don't copy this theme (repeatable, saved) |
| `--dev-plugin <name>` | Protect local dev plugin from rsync (repeatable, saved) |
| `--dev-theme <name>` | Protect local dev theme from rsync (repeatable, saved) |
| `--skip-uploads` | Skip media/uploads directory (faster) |
| `--skip-db` | Skip database export/import |
| `--dry-run` | Preview what would happen |

**What it does:** Validates SSH + WP-CLI, detects remote config (domain, protocol, table prefix, multisite), rsyncs wp-content, imports DB, search-replaces URLs, deactivates all plugins, saves config to `.remote`.

### `wpl pull <name> [options]`
Sync updates from linked remote (requires prior clone).

| Flag | Description |
|------|-------------|
| `--db-only` | Only sync database (skip files) |
| `--skip-db` | Only sync files (skip database) |
| `--skip-uploads` | Skip media/uploads directory |
| `--exclude-plugin <name>` | Protect plugin from overwrite (saved for future pulls) |
| `--exclude-theme <name>` | Protect theme from overwrite (saved for future pulls) |
| `--include-plugin <name>` | One-time override of a saved exclusion |
| `--clear-excludes` | Clear all saved exclusions |
| `--dry-run` | Preview what would happen |

**Exclusion persistence:** `--exclude-plugin` saves to `.remote` and applies on all future pulls. Use `--include-plugin` for one-time override or `--clear-excludes` to reset all.

**Plugin state management:** Active plugins are snapshot before DB import, then restored after. Plugins removed from filesystem are skipped gracefully.

**Dev repo detection:** Automatically scans for `.git` directories in plugins/themes. Offers to protect unprotected git repos from rsync overwrite.

### `wpl config <name> php <version>`
Change PHP version. Available: `8.0`, `8.1`, `8.2`, `8.3`. Requires restart after change.

### `wpl cli <name> <command>`
Run any WP-CLI command inside the site's container.

```bash
wpl cli mysite plugin list
wpl cli mysite plugin activate my-plugin
wpl cli mysite option update blogname "New Title"
wpl cli mysite db query "SELECT * FROM wp_options LIMIT 5"
wpl cli mysite cache flush
wpl cli mysite rewrite flush
wpl cli mysite cron event run --all
wpl cli mysite search-replace 'old-url.com' 'new-url.test' --dry-run
```

**Note:** WP-CLI runs in a dedicated `cli` container as user `33:33` (www-data). Uses `docker-compose run --rm cli wp <command>`.

### `wpl db <name>`
Show database credentials: server, database name, username, password, root password, phpMyAdmin URL.

### `wpl logs <name>`
View live Docker container logs (follows output).

### `wpl shell <name>`
Open an interactive bash shell in the WordPress container.

### `wpl start/stop/restart <name>`
Manage site containers. `wpl stop --all` stops every running site.

### `wpl list`
List all sites with running/stopped status, PHP version, and URL. Alias: `wpl ls`.

### `wpl destroy <name>`
Remove site completely: stops containers, removes volumes, deletes site directory.

---

## Site directory structure

```
~/dev/wp-local/sites/<name>/
├── .env                        # SITE_NAME, PHP_VERSION, DB passwords
├── .remote                     # Remote sync config (if cloned)
├── docker-compose.yml          # Site-specific Docker services
├── uploads.ini                 # PHP config (256M uploads, 300s timeout)
└── wp-content/
    ├── plugins/
    ├── themes/
    ├── uploads/
    ├── mu-plugins/
    │   └── auto-login.php      # Auto-login as admin
    └── debug.log               # WordPress debug log
```

### `.remote` file format (created by clone)
```
REMOTE_SSH_HOST=<ssh-alias>
REMOTE_WP_PATH=<remote-path>
REMOTE_DOMAIN=<detected-domain>
REMOTE_PROTOCOL=<https|http>
REMOTE_TABLE_PREFIX=<prefix>
REMOTE_IS_MULTISITE=<true|false>
DEV_PLUGINS="plugin-a plugin-b"
DEV_THEMES="theme-a"
EXCLUDE_PLUGINS="plugin-c"
EXCLUDE_THEMES=""
```

---

## URLs and networking

| Resource | URL |
|----------|-----|
| WordPress site | `http://<name>.test` |
| WordPress admin | `http://<name>.test/wp-admin` (auto-login) |
| Multisite subdomain | `http://<sub>.<name>.test` |
| Network admin | `http://<name>.test/wp-admin/network/` |
| phpMyAdmin | `http://pma.test` |
| Traefik dashboard | `http://localhost:8080` |

DNS: dnsmasq routes `*.test` → `127.0.0.1`. Traefik auto-routes to the correct container via Docker labels.

---

## Database access

Each site has its own MariaDB 10.11 container.

| Property | Value |
|----------|-------|
| Host | `<name>-db` (from within Docker network) |
| Database | `<name>` |
| User | `wordpress` |
| Password | Auto-generated (see `wpl db <name>` or `.env`) |

Access via:
- **phpMyAdmin**: `http://pma.test` → Server: `<name>-db`, User: `wordpress`
- **WP-CLI**: `wpl cli <name> db query "SELECT ..."`
- **Direct**: `docker-compose -f ~/dev/wp-local/sites/<name>/docker-compose.yml exec db mysql -u wordpress -p<password> <name>`

---

## Docker architecture

Core infrastructure (shared):
- **Traefik v3.0** — Reverse proxy on port 80, dashboard on 8080
- **phpMyAdmin** — Database GUI on pma.test
- **Network** — `wp-local` bridge network connects all containers

Per-site services:
- **wordpress** — WordPress + PHP (version from `.env`)
- **db** — MariaDB 10.11 with `--skip-ssl`
- **cli** — WP-CLI container (runs as www-data, on-demand)

---

## Rsync default exclusions (always applied)

These are never synced from remote during clone/pull:
- `debug.log`, `*.log` — Log files
- `cache/`, `*/cache/` — Cache directories
- `upgrade/` — WordPress upgrade files
- `wflogs/` — Wordfence logs
- `mu-plugins/auto-login.php` — Local auto-login plugin

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Site not loading at `<name>.test` | `sudo dscacheutil -flushcache` and check dnsmasq: `sudo brew services list` |
| Containers won't start | Check Colima: `colima status`, start with `colima start` |
| DB connection error | Wait for DB readiness or restart: `wpl restart <name>` |
| WP-CLI permission issues | CLI container runs as `33:33` (www-data) — ensure wp-content is writable |
| Plugin changes not showing | Plugin must be mounted via `--plugin` flag or be in `wp-content/plugins/` |
| MariaDB SSL errors | Already handled via `--skip-ssl` in docker-compose |
| Traefik routing wrong container | Check `traefik.docker.network=wp-local` label on container |
