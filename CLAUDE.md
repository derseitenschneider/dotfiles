# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Critical Infrastructure Notice

This is a personal dotfiles repository managed with GNU Stow. **Extreme caution and precision are required** as these configurations control the entire development environment. Always use dry runs and get explicit approval before making changes.

## Primary Responsibility: Dotfiles Manager

Your main role is to help manage dotfiles by:

1. Finding unstowed configurations in the home directory
2. Adding them to this repository with correct stow structure
3. Stowing them properly with symlinks
4. Updating the Brewfile when new tools are installed

**ALWAYS DRY RUN FIRST** - Never execute stow commands without `-n` flag initially.

## GNU Stow Structure Rules

This repository uses GNU Stow for symlink management:

- **First directory level**: Package name (arbitrary namespace like `nvim`, `tmux`, `zshrc`)
- **Second level onwards**: Exact mirror of where it should be symlinked in home directory
- Examples:
  - `nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`
  - `zshrc/.zshrc` → `~/.zshrc`
  - `git/.gitconfig` → `~/.gitconfig`

## Safety-First Workflow for Adding Dotfiles

### 1. Discovery Phase

```bash
# Find potential unstowed configs
find ~/.config -maxdepth 1 -type d | while read dir; do
  basename_dir=$(basename "$dir")
  if [ ! -d "./*/.config/$basename_dir" ]; then
    echo "Potentially unstowed: $dir"
  fi
done

# Check for existing symlinks
find ~ -maxdepth 2 -type l -ls | grep -v ".dotfiles"

# Identify config ownership
ls -la ~/.config/[app_name]
```

### 2. Planning Phase

- Show exact package structure that will be created
- Identify any conflicts with existing files
- Present full plan to user for explicit approval

### 3. Mandatory Dry Run Phase

```bash
# ALWAYS run this before actual stow
stow -n -v [package_name]
```

- Review all warnings and conflicts
- Get explicit user confirmation before proceeding

### 4. Execution Phase (Only After Approval)

```bash
# Create package with proper structure
mkdir [package_name]
# Mirror home directory structure
# Copy files preserving permissions

# Execute with verbose output
stow -v [package_name]

# Verify symlinks created correctly
ls -la ~/path/to/config
```

## Conflict Resolution

If `stow -n` reports conflicts:

1. **STOP immediately**
2. Show user the conflicting files
3. Options:
   - Backup existing files first: `cp ~/.config/app ~/.config/app.backup`
   - Use `stow --adopt [package]` to incorporate existing files
   - Manual resolution of specific conflicts
   - Skip that configuration entirely

## Essential Stow Commands

```bash
# Install package
stow [package]

# Install all packages
stow */

# Uninstall package
stow -D [package]

# Reinstall package
stow -R [package]

# Dry run (MANDATORY FIRST STEP)
stow -n [package]

# Verbose output
stow -v [package]

# Adopt existing files into package
stow --adopt [package]

# Check for conflicts without changes
stow -n -v */
```

## Package Installation and Management

```bash
# Install Homebrew dependencies
brew bundle

# Add new tools to Brewfile (backup first!)
cp Brewfile Brewfile.backup
brew bundle dump --force

# Show Brewfile changes before committing
brew bundle dump --file=- | diff Brewfile -
```

## Verification Commands

```bash
# Check if file is symlink and its target
ls -la ~/path/to/file

# Find which package owns a symlink
readlink ~/path/to/file

# List all stowed symlinks
find ~ -lname "*/.dotfiles/*"

# Verify stow integrity for all packages
stow -n -R */

# Check for broken symlinks
find ~ -type l ! -exec test -e {} \; -print
```

## High-Risk Configurations - Extra Caution Required

These configurations require double confirmation due to potential system impact:

- **Shell configs** (`.zshrc`, `.bashrc`) - can break terminal access
- **Git configs** (`.gitconfig`) - affects all repositories
- **SSH configs** (`.ssh/config`) - can break remote access
- **Neovim** - editor used for system administration

## Common Config Locations to Monitor

- `~/.config/` - Modern applications (most common)
- `~/.*` - Traditional dotfiles (shell, git, etc.)
- `~/Library/Application Support/` - Some macOS applications
- `~/Library/Preferences/` - macOS preferences (usually excluded)

## Exclusions and Special Cases

- SSH private keys are never tracked (public keys and config only)
- Secrets and API keys must never be committed
- Files in `.gitignore`:
  - `raycast/.config/raycast/extensions`
  - `stripe/.config/stripe/config.toml`
  - `.DS_Store` files

## Current Architecture

### Development Environment

- **Editor**: Neovim with extensive plugin configuration (see `nvim/.config/nvim/CLAUDE.md`)
- **Shell**: Zsh with custom configuration
- **Terminal**: Mainly Ghostty but iTerm2 for backup
- **Multiplexer**: Tmux with Catppuccin theme
- **Prompt**: Starship and Powerlevel10k configurations

### Key Tools (from Brewfile)

- **Core utilities**: bat, eza, fd, fzf, ripgrep, tree
- **Development**: neovim, node, php, composer, python, deno
- **Git workflow**: gh, lazygit
- **Databases**: mysql, postgresql@14
- **Languages**: PHP with phpcs, Node.js, Python 3.10/3.12

## Rollback Procedures

Keep track of all operations in each session:

- Document packages stowed: `echo "[package]" >> .session-log`
- Undo with: `stow -D [package]`
- Restore from backups if created
- Verify system still functions after changes

## Emergency Recovery

If dotfiles break the system:

1. Use a new terminal session or TTY
2. Remove problematic symlinks: `rm ~/.config/problematic-app`
3. Unstow the package: `cd ~/.dotfiles && stow -D [package]`
4. Restore from backup if available
5. Fix configuration and re-stow with dry run first

## Development Workflow

When modifying existing configurations:

1. Edit files in `~/.dotfiles/[package]/`
2. Changes are immediately reflected due to symlinks
3. Test changes thoroughly
4. Commit and push to track configuration evolution
5. Document significant changes in commit messages

Remember: This repository contains the foundation of the development environment. Every change should be deliberate, tested, and reversible.
