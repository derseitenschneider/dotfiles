######## FZF
# 
# Source fzf
eval "$(fzf --zsh)"

######## PLUGINS

#
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Starship promt
eval "$(starship init zsh)"
######## ZINIT
#
# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

######## EXPORTS
#
# mysql path
export PATH=$PATH:/usr/local/mysql/bin
# fzf-repo path
export PATH="$HOME/.config/scripts:$PATH"

# 1Password ssh keys
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Make nvim the default editor
export EDITOR='nvim'

######## KEYBINDINGS
#
# fzf-repo shortcut
bindkey -s "^f" ' () { fzf-repo.sh; } && eval "clear"\n'

# Vim Mode
bindkey -v
bindkey kj vi-cmd-mode
VI_MODE_SET_CURSOR=true
MODE_INDICATOR="%F{white}+%f"
INSERT_MODE_INDICATOR="%F{yellow}+%f"

# Accept autosuggestions
bindkey "^a" autosuggest-accept

######## HISTORY
#
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


# ######## FD
# #
# # eval "$(fzf --zsh)"
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

## -- Use fd instead of fzf --
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --exclude 'node_modules'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude 'node_modules' . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude 'node_modules' . "$1"
}

# Stripe completion
fpath=(~/.stripe $fpath)
autoload -Uz compinit && compinit -i

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

######## ALIASES
#
# Basics
alias c='clear'
alias e='exit'
alias zshrc='cd ~/ && v .zshrc'
alias cat='bat'


# Navigation
alias ..='cd ../'
alias ...='cd ../..'
alias ....='cd ../../..'

alias sf='ls | fzf'
alias home='cd ~'
alias repo='cd ~/Repositories/'
alias down='cd ~/Downloads/'

#Yazi
alias y='yazi'

# FZF
alias ff='fzf'
alias fv='nvim $(fzf)'

# Python
alias python=python3

# Neovim
alias v='nvim'
alias vv='nvim .'

# Lnav
alias lnav='TERM=xterm-256color lnav'

# Git
alias ga="git add -A"
alias gc="git commit"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias lg="lazygit"

# LS
alias ls="eza --color=always --all --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias lsa="eza --color=always --long --all --git --icons=always"

# npm
alias nr="npm run"
alias nx="npx"

######## SCRIPTS
#
# Build scripts
npm-dev() {
    if [ $# -eq 0 ]; then
        npm run dev
    else
        npm run dev:$1
    fi
}

alias dev='npm-dev'

npm-build() {
    if [ $# -eq 0 ]; then
        npm run build
    else
        npm run build:$1
    fi
}

alias build='npm-build'


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# Created by `pipx` on 2024-10-07 14:14:33
export PATH="$PATH:/Users/brianboy/.local/bin"

if tmux has-session -t my-session 2>/dev/null; then
  tmux attach-session -t my-session; clear
elif tmux ls 2>/dev/null | grep -q '^'; then
  tmux attach; clear
else
  tmux new-session -s my-session;
  tmux new_window;
  clear
fi
