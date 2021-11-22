#!/bin/bash

set -eu -o pipefail

echo "install xcode"
if [[ ! -x /Library/Developer/CommandLineTools ]]; then
    xcode-select --install &
fi
echo "Install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &
echo "Set up zsh config"
cat zsh-config.txt > ~/.zshrc &
echo "Install homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &
echo "Install brew bundle and brew install app list"
brew tap Homebrew/bundle &
brew bundle &


