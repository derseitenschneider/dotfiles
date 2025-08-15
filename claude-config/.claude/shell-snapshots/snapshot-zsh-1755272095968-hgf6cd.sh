# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
# Shell Options
setopt nohashdirs
setopt login
# Aliases
alias -- run-help=man
alias -- which-command=whence
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/usr/local/Cellar/ripgrep/14.1.0/bin/rg'
fi
export PATH=/usr/local/opt/php\@8.3/bin\:/Users/brianboy/.config/scripts\:/usr/local/bin\:/usr/local/sbin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\:/opt/X11/bin\:/Library/Apple/usr/bin\:/Users/brianboy/.config/scripts\:/Users/brianboy/.local/share/zinit/polaris/bin\:/Applications/Ghostty.app/Contents/MacOS\:/Users/brianboy/.local/bin\:/usr/local/mysql/bin\:/Users/brianboy/.local/bin\:/usr/local/mysql/bin\:/Users/brianboy/.local/bin
