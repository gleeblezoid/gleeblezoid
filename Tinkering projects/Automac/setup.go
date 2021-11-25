package main

import (
	"fmt"
	"io/ioutil"
	"os/exec"
)

func main() {
	checkForXcode()
	zshSetup()
	macPortsInstall()
	installPorts()
	installPowerLevel()
	trackpadSetup()
	//touchbarSetup()
	//installBinaries()
}

func macPortsInstall() {
	fmt.Println("Install MacPorts")

	downloadMacPorts := exec.Command("curl", "-O", "https://distfiles.macports.org/MacPorts/MacPorts-2.7.1.tar.bz2")
	extractMacPorts := exec.Command("tar", "xf", "MacPorts-2.7.1.tar.bz2")
	runConfigure := exec.Command("/bin/sh", "MacPorts-2.7.1/configure")
	doMake := exec.Command("make")
	doInstall := exec.Command("make", "install")
	setPath := exec.Command("export", "PATH=/opt/local/bin:/opt/local/sbin:$PATH")

	d := downloadMacPorts.Run()
	checkError(d)
	e := extractMacPorts.Run()
	checkError(e)
	r := runConfigure.Run()
	checkError(r)
	dm := doMake.Run()
	checkError(dm)
	di := doInstall.Run()
	checkError(di)
	sp := setPath.Run()
	checkError(sp)
}

func installPowerLevel() {
	downloadPowerLevel := exec.Command("git clone", "--depth=1", "https://github.com/romkatv/powerlevel10k.git", "$HOME/powerlevel10k")
	dpl := downloadPowerLevel.Run()
	checkError(dpl)
}

func installPorts() {
	fmt.Println("Run through ports and install them.")
	downloadInstallScript := exec.Command("curl", "-fsSL", "https://github.com/macports/macports-contrib/raw/master/restore_ports/restore_ports.tcl")
	extractInstallScript := exec.Command("xattr", "-d", "com.apple.quarantine restore_ports.tcl")
	runScript := exec.Command("/bin/sh", "restore_ports.tcl", "myports.txt")

	d := downloadInstallScript.Run()
	checkError(d)
	e := extractInstallScript.Run()
	checkError(e)
	r := runScript.Run()
	checkError(r)
}

func installFromDMG() {
	/*
		curl -LJO https://github.com/rxhanson/Rectangle/releases/download/v0.49/Rectangle0.49.dmg
		hdiutil mount Rectangle0.49.dmg
		sudo cp -r /Volumes/Rectangle0.49/Rectangle.app /Applications/Rectangle.app
		hdiutil detach Rectangle0.49.dmg
	*/
	return
}

func trackpadSetup() {
	fmt.Println("Set up trackpad preferences")
	tapToClick := exec.Command("defaults", " write com.apple.AppleMultitouchTrackpad Clicking -bool true")
	scrollDirection := exec.Command("defaults", " write ~/Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool false")

	t := tapToClick.Run()
	checkError(t)
	s := scrollDirection.Run()
	checkError(s)
}

func touchbarSetup() {
	setTouchbar := exec.Command()
}

func zshSetup() {
	fmt.Println("Install oh-my-zsh and update zsh config")
	installOhMyZsh := exec.Command("curl", "-fsSL", "https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh")
	zshConfig := "$HOME/.zshrc"
	i := installOhMyZsh.Run()
	checkError(i)

	config, err := ioutil.ReadFile("zsh-config.txt")
	if err != nil {
		fmt.Println(err)
	}
	errWrite := ioutil.WriteFile(zshConfig, config, 0777)
	if errWrite != nil {
		fmt.Println(err)
	}

}

func checkForXcode() {
	fmt.Println("Check for xcode and install")
	checkXcode := exec.Command("/Library/Developer/CommandLineTools")
	installXcode := exec.Command("xcode-select --install")
	e := checkXcode.Run()
	checkError(e)

	if e == nil {
		i := installXcode.Run()
		checkError(i)
	}
}

func checkError(e error) {
	if e != nil {
		fmt.Println(e)
	}
}
