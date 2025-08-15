---
description: "Intelligently discover, organize, and stow unstowed dotfiles with safety checks"
allowed_tools: ["Read", "Write", "Edit", "Bash", "LS", "Glob", "Grep", "TodoWrite"]
---

# Update Dotfiles Command

**CRITICAL**: This command manages your entire development environment. Follow all safety procedures from `~/.dotfiles/CLAUDE.md`.

## Phase 1: Discovery and Analysis

Start by discovering all unstowed configurations in your system:

### 1.1 Scan for Unstowed Configs
```bash
# Find configs in ~/.config that aren't stowed
cd ~/.dotfiles
echo "=== Scanning for unstowed configs in ~/.config ==="
for dir in ~/.config/*/; do
    if [ -d "$dir" ]; then
        app_name=$(basename "$dir")
        # Check if this config is already stowed
        if ! find . -name ".config" -type d -exec test -d "{}/config/$app_name" \; 2>/dev/null; then
            if [ ! -L "$dir" ]; then
                echo "UNSTOWED: ~/.config/$app_name"
                ls -la "$dir" | head -3
                echo "---"
            fi
        fi
    fi
done
```

### 1.2 Scan for Home Directory Dotfiles
```bash
echo "=== Scanning for unstowed dotfiles in home directory ==="
for file in ~/.*; do
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        filename=$(basename "$file")
        # Skip common system files
        case "$filename" in
            .DS_Store|.Trash|.CFUserTextEncoding|.bash_sessions) continue ;;
        esac
        
        # Check if already managed by a stow package
        if ! find ~/.dotfiles -name "$filename" -type f 2>/dev/null | grep -q .; then
            echo "UNSTOWED: $file"
        fi
    fi
done
```

### 1.3 Check Currently Stowed Packages
```bash
echo "=== Currently stowed packages ==="
cd ~/.dotfiles
stow -n -v */ 2>&1 | grep -E "(LINK|UNLINK)" | head -10 || echo "No conflicts detected"
```

## Phase 2: Categorization and Planning

For each discovered config, determine the appropriate stow package structure:

### 2.1 Categorize Configurations
- **Application configs** (`~/.config/app`) → `app/.config/app/`
- **Shell dotfiles** (`~/.zshrc`) → `zshrc/.zshrc`
- **Development tools** (`~/.gitconfig`) → `git/.gitconfig`
- **Terminal configs** → respective package names

### 2.2 Create Migration Plan
For each unstowed config, document:
1. Current location
2. Proposed package name
3. Target stow structure
4. Potential conflicts
5. Backup requirements

**STOP HERE** - Present the complete plan to the user before proceeding.

## Phase 3: Safety Checks and Dry Runs

**MANDATORY**: Before any file operations:

### 3.1 Backup Critical Configs
```bash
# Create session backup directory
backup_dir=~/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)
mkdir -p "$backup_dir"
echo "Backup directory: $backup_dir"

# Backup each config being moved
# Example: cp -r ~/.config/app "$backup_dir/"
```

### 3.2 Test Stow Operations
```bash
# For each new package, run dry run:
# stow -n -v [package_name]
# Check for any conflicts or warnings
```

## Phase 4: Execution (Only After User Approval)

### 4.1 Create Package Structure
For each new package:
```bash
# Example for a ~/.config/app configuration:
mkdir -p [package_name]/.config
# Mirror the exact home directory structure
```

### 4.2 Move Configurations
```bash
# Move files preserving permissions and structure
# Example: mv ~/.config/app [package_name]/.config/
# Verify move completed successfully
```

### 4.3 Stow New Packages
```bash
# For each package, stow with verbose output:
stow -v [package_name]

# Verify symlinks created correctly:
ls -la ~/.config/[app]  # Should show symlink
```

## Phase 5: Brewfile Update

### 5.1 Backup Current Brewfile
```bash
cd ~/.dotfiles
cp Brewfile "Brewfile.backup-$(date +%Y%m%d-%H%M%S)"
```

### 5.2 Update Dependencies
```bash
# Generate new Brewfile
brew bundle dump --force

# Show changes to user
echo "=== Brewfile changes ==="
git diff Brewfile || echo "No changes to Brewfile"
```

## Phase 6: Verification and Cleanup

### 6.1 Verify All Symlinks
```bash
echo "=== Verifying stowed symlinks ==="
# Check each new symlink points to correct location
find ~ -lname "*/.dotfiles/*" | while read link; do
    echo "✓ $link -> $(readlink "$link")"
done
```

### 6.2 Test Critical Configurations
- Test shell config: `zsh -c 'echo "Shell test successful"'`
- Test git config: `git config --list | head -5`
- Test editor config: Launch editor briefly

### 6.3 Stow Integrity Check
```bash
echo "=== Final stow integrity check ==="
cd ~/.dotfiles
stow -n -R */ | head -20
```

## Phase 7: Commit Changes

### 7.1 Review All Changes
```bash
cd ~/.dotfiles
git status
git diff --cached || git add -A && git diff --cached
```

### 7.2 Commit New Dotfiles
```bash
git add .
git commit -m "feat: Add discovered dotfiles to stow management

- Added [list packages]
- Updated Brewfile with new dependencies  
- All configs now managed via symlinks

🤖 Generated with Claude Code"
```

## Emergency Rollback Procedures

If anything goes wrong:

### Immediate Rollback
```bash
# Unstow problematic packages
cd ~/.dotfiles
stow -D [problematic_package]

# Restore from backup
cp -r ~/.dotfiles-backup-[timestamp]/[config] ~/[original_location]
```

### Full Session Rollback
```bash
# Unstow all packages from this session
# Restore all backups
# Reset git repository if needed: git reset --hard HEAD~1
```

## Success Criteria

✅ All discovered configs are now stowed packages  
✅ All original locations are symlinks to ~/.dotfiles  
✅ No broken symlinks exist  
✅ Shell and critical tools still function  
✅ Brewfile reflects current installed tools  
✅ Changes committed to git repository

## Post-Execution Notes

Document any:
- Configs that couldn't be stowed (with reasons)
- Manual interventions required
- Special cases discovered
- Recommendations for future runs

Remember: This command touches your entire development environment. When in doubt, stop and ask for clarification.