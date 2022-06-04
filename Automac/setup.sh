#!/bin/sh

set -e

touch_id_sudo () {
    echo "Add touchID sudo"
    sed -i '' '2i\
    auth       sufficient     pam_tid.so\
    ' /etc/pam.d/sudo
}

install_xcode () {
    echo "Check for xcode and install"
    if [ ! -d "/Library/Developer/CommandLineTools" ]; then
        xcode-select --install
	sleep 1800
    fi
}

zsh_setup () {
    echo "Set up oh-my-zsh and zsh config"
    sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    && sudo cp config/zsh-config.txt "$HOME"/.zshrc
    sudo sh -c source ~/.zshrc
}

install_macports () {
    echo "MacPorts Install"
    sudo curl -O https://distfiles.macports.org/MacPorts/MacPorts-2.7.1.tar.bz2
    tar xjvf MacPorts-2.7.1.tar.bz2
    cd MacPorts-2.7.1
    ./configure && make && sudo make install
    export PATH=/opt/local/bin:/opt/local/sbin:"$PATH"
    sudo port -v selfupdate
    cd ../
    rm -rf MacPorts-2.7.1*
}

install_mac_store_and_apps () {
    # I might need to authenticate with the App Store before mas runs
    cd $HOME
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
}

install_my_ports () {
    echo "Install ports from list"
    sudo curl --location --remote-name https://github.com/macports/macports-contrib/raw/master/restore_ports/restore_ports.tcl
    sudo chmod +x restore_ports.tcl
    sudo ./restore_ports.tcl config/myports.txt
}

install_powerlevel () {
    echo "Install PowerLevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME"/powerlevel10k
}

setup_trackpad_and_touchbar () {
    echo "Set up trackpad and touchbar"
    sudo defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    sudo defaults write ~/Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool false
    sudo defaults write ~/Library/Preferences/com.apple.controlstrip MiniCustomized '(com.apple.system.brightness, com.apple.system.volume, com.apple.system.mute, com.apple.system.screen-lock )'
}

install_apps_from_binaries () {
    echo "Install closed source apps"
    sudo ./scripts/installBinaries.sh
}

setup_git_config () {
    echo "Set up git config"
    echo "Enter the email for your commits:"
    read -r email
    git config --global user.name "gleeblezoid" && git config --global user.email "$email"
}


echo "Make sure you're logged into the App Store with your Apple ID"
touch_id_sudo
install_xcode
install_macports
zsh_setup
install_my_ports
install_powerlevel
install_apps_from_binaries
setup_trackpad_and_touchbar
setup_git_config
install_mac_store_and_apps
sudo reboot
