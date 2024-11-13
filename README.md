# Dotfiles

My personal dotfiles, managed with GNU Stow.

## Prerequisites

1. Install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Install GNU Stow:

```bash
brew install stow
```

## Installation

1. Clone this repository to your home directory:

```bash
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Install Homebrew packages (optional):

```bash
brew bundle
```

3. Stow all configurations:

```bash
stow */
```

Or stow individual configurations:

```bash
stow nvim      # Neovim config
stow tmux      # Tmux config
stow zshrc     # Zsh config
# etc...
```

## Structure

```
.dotfiles/
├── nvim/           # Neovim configuration
├── tmux/           # Tmux configuration
├── vim/            # Vim configuration
├── zshrc/          # Zsh configuration
├── ssh/            # SSH config (excluding keys)
├── p10k/           # Powerlevel10k configuration
└── ...
```

## Important Notes

- SSH keys are not included and need to be set up separately
- Some configurations might require additional software to be installed
- Use `brew bundle` to install all applications listed in the Brewfile

## Uninstall

To remove any stowed configuration:

```bash
stow -D package_name
```

For example:

```bash
stow -D nvim    # Remove Neovim config
```
