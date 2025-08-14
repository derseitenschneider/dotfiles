# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Neovim configuration using Lazy.nvim as the plugin manager. The configuration follows a modular structure:

- **Entry Point**: `init.lua` sets system language and loads core modules
- **Core Configuration**: `lua/brianboy/core/` contains fundamental settings
  - `options.lua`: Editor options, indentation rules, and autocmds
  - `keymaps.lua`: Custom key mappings and leader key bindings  
  - `run_script.lua`: Custom `:Run` command that executes project-level `./run` scripts
- **Plugin Management**: `lua/brianboy/lazy.lua` configures Lazy.nvim
- **Plugin Configurations**: `lua/brianboy/plugins/` contains individual plugin setups
- **Snippets**: `lua/brianboy/snippets/` contains custom snippets for various languages

## Key Configuration Patterns

### Plugin Structure
Each plugin is configured as a separate file in `lua/brianboy/plugins/` returning a Lazy.nvim spec table with dependencies, configuration, and keymaps.

### Language Server Setup
LSP configuration is centralized in `lspconfig.lua` with Mason for automatic tool installation:
- Supports TypeScript/JavaScript, HTML, CSS, Tailwind, Lua, PHP, and Emmet
- Custom PHP setup with Intelephense including WordPress/PHPUnit stubs
- Biome formatting for JS/TS projects, phpcs/phpcbf for PHP

### Formatting and Linting
- **Formatting**: Conform.nvim with format-on-save enabled
- **Linting**: Configured via `linting.lua` with nvim-lint
- **PHP**: Uses phpcs/phpcbf with custom ruleset support

### Custom Features
- **Run Command**: `:Run` executes project-level `./run` scripts from git root
- **Tailwind Sorting**: Auto-sorts Tailwind classes on save for relevant filetypes
- **Custom Keymaps**: Space leader key with extensive custom mappings
- **FZF Integration**: Ctrl+F opens tmux popup with fzf-repo.sh script

## Development Workflow

### Plugin Management
- Add new plugins in `lua/brianboy/plugins/[name].lua`
- Run `:Lazy` to manage plugins
- Plugin lockfile is tracked in `lazy-lock.json`

### Custom Snippets
- Located in `lua/brianboy/snippets/[filetype].lua`
- Use LuaSnip format for snippet definitions

### Key Mappings
- Leader key: Space
- Custom escape: `kj` in insert/visual/command modes
- File operations: `<leader>w` (save all), `<leader>cc` (save and quit all)
- Project run: `<leader>r` executes `:Run` command

## Language-Specific Configuration

### JavaScript/TypeScript
- 2-space indentation (auto-configured via FileType autocmd)
- Biome for formatting and linting
- Tailwind CSS class sorting on save

### PHP
- 4-space indentation (default)
- Intelephense LSP with custom stubs
- phpcs/phpcbf for formatting
- Custom PHP snippets available

### Lua
- 4-space indentation
- stylua for formatting
- Vim globals recognized in LSP

## File Type Associations
- Web files (JS/TS/React/HTML/CSS): 2-space indentation, Tailwind sorting
- PHP files: 4-space indentation, custom formatting rules
- All files: Format on save enabled via Conform.nvim