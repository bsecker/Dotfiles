# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"


ZSH_THEME="af-magic"

plugins=(
        git
        colored-man-pages
        z
        docker-compose
        docker
        kubectl
)

source $ZSH/oh-my-zsh.sh

# My stuff below...

# note: history stuff is handled by oh-my-zsh
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh

alias kc=kubectl
alias please=sudo
alias lah='ls -lah'

# Work-Specific stuff
export DOCKER_HOST=tcp://localhost:2375 # WSL1 docker integration
alias home='cd /mnt/c/Users/b.secker/'
