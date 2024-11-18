# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
~/.config/scripts/welcome.sh

##mysql path
export PATH=$PATH:/usr/local/mysql/bin

# fzf-repo path
export PATH="$HOME/.config/scripts:$PATH"

# fzf-repo shortcut
bindkey -s "^f" ' () { fzf-repo.sh; } && eval "clear"\n'

# export TERM='xterm-256color'
export EDITOR='nvim'
# export VISUAL='nvim'
# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# source $ZSH/oh-my-zsh.sh

# User configuration

# Starship promt
eval "$(starship init zsh)"

# Vim Mode
bindkey -v
bindkey kj vi-cmd-mode
VI_MODE_SET_CURSOR=true
MODE_INDICATOR="%F{white}+%f"
INSERT_MODE_INDICATOR="%F{yellow}+%f"

# FZF
# eval "$(fzf --zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

## -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --exclude 'node_modules'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git --exclude 'node_modules' . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git --exclude 'node_modules' . "$1"
}

# Stripe completion
fpath=(~/.stripe $fpath)
autoload -Uz compinit && compinit -i

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Keymaps

# ALIASES

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
alias user='cd ~'
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
alias lnav='TERM=xterm lnav'

# Git
alias ga="git add -A"
alias gc="git commit"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias lg="lazygit"

alias ls="eza --color=always --all --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias lsa="eza --color=always --long --all --git --icons=always"

# SCRIPTS
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

#Start tmux when opening terminal
# if [ "$TERM" = "xterm-kitty" ]; then
#     if ! tmux has-session 2>/dev/null; then
#         tmux new-session
#     else
#         tmux attach-session
#     fi
# fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# Created by `pipx` on 2024-10-07 14:14:33
export PATH="$PATH:/Users/brianboy/.local/bin"
