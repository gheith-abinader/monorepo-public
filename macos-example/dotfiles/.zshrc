location: $HOME/.zshrc
contents:
#Homebrew setup
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
# dagger completion setup
fpath=(~/.zsh/functions $fpath)
# docker completion setup
FPATH="$HOME/.docker/completions:$FPATH"
# general completion setup
autoload -Uz compinit
compinit
#monorepo direct navigation
MONOREPO=~/Code/GitHub/gheith-abinader/monorepo
RESUME="~/Library/CloudStorage/OneDrive-Personal/Documents/Job search"
