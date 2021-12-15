#!/bin/bash

set -eo pipefail

echo "Check for xcode and install"
if [[ ! -f "/Library/Developer/CommandLineTools" ]]; then
    xcode-select --install
fi

echo "Set up oh-my-zsh and zsh config"
sudo curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh && sudo cp config/zsh-config.txt "$HOME"/.zshrc

echo "MacPorts Install"
sudo curl -O https://distfiles.macports.org/MacPorts/MacPorts-2.7.1.tar.bz2
tar xjvf MacPorts-2.7.1.tar.bz2
cd MacPorts-2.7.1
./configure && make && sudo make install
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
sudo port -v selfupdate
cd ../
rm -rf MacPorts-2.7.1*

echo "Install Mac App Store CLI"
sudo port install mas
echo "Install xcode full"
mas lucky xcode
echo "Install Bitwarden"
mas lucky bitwarden
echo "Install WhatsApp"
mas lucky whatsapp
echo "Install Spark"
mas lucky spark
echo "Install Messenger"
mas lucky messenger
echo "Install Microsoft Remote Desktop"
mas lucky "microsoft remote desktop"

echo "Install ports from list"
sudo curl --location --remote-name https://github.com/macports/macports-contrib/raw/master/restore_ports/restore_ports.tcl
sudo chmod +x restore_ports.tcl
sudo xattr -d com.apple.quarantine restore_ports.tcl
sudo ./restore_ports.tcl config/myports.txt

echo "Install PowerLevel10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME"/powerlevel10k

echo "Set up trackpad and touchbar"
sudo defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
sudo defaults write ~/Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool false
sudo defaults write ~/Library/Preferences/com.apple.controlstrip MiniCustomized '(com.apple.system.brightness, com.apple.system.volume, com.apple.system.mute, com.apple.system.screen-lock )'

echo "Install closed source apps"
sudo ./scripts/installBinaries.sh

sudo reboot
