package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"

	"github.com/Eun/gdriver"
	"github.com/Eun/gdriver/oauthhelper"
)

func main() {
	checkForXcode()
	zshSetup()
	setupHomebrew()
	brewBundle()
	trackpadSetup()
	desktopBackground()
	// install dtrx
}

func desktopBackground() {
	// Setup OAuth
	helper := oauthhelper.Auth{
		ClientID:     "ClientID",
		ClientSecret: "ClientSecret",
		Authenticate: func(url string) (string, error) {
			fmt.Printf("Open to authorize Example to access your drive\n%s\n", url)

			var code string
			fmt.Printf("Code: ")
			if _, err := fmt.Scan(&code); err != nil {
				return "", fmt.Errorf("Unable to read authorization code %v", err)
			}
			return code, nil
		},
	}

	var err error
	// Try to load a client token from file
	helper.Token, err = oauthhelper.LoadTokenFromFile("token.json")
	if err != nil {
		// if the error is NotExist error continue
		// we will create a token
		if !os.IsNotExist(err) {
			log.Panic(err)
		}
	}

	// Create a new authorized HTTP client
	client, err := helper.NewHTTPClient(context.Background())
	if err != nil {
		log.Panic(err)
	}

	// store the token for future use
	if err = oauthhelper.StoreTokenToFile("token.json", helper.Token); err != nil {
		log.Panic(err)
	}

	// create a gdriver instance
	gdrive, err := gdriver.New(client)
	if err != nil {
		log.Panic(err)
	}

	err = gdrive.ListDirectory("/Pictures/Wallpaper", func(info *gdriver.FileInfo) error {
		fmt.Printf("%s\t%d\t%s", info.Name(), info.Size(), info.ModifiedTime().String())
		return nil
	})
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

func brewBundle() {
	fmt.Println("Install packages with brew from Brewlist")
	bundleInstall := exec.Command("brew", "bundle")

	b := bundleInstall.Run()
	checkError(b)
}

func setupHomebrew() {
	fmt.Println("Install Homebrew and brew bundle")
	installHomebrew := exec.Command("curl", "-0", "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh")
	brewTapBundle := exec.Command("brew tap Homebrew/bundle")

	i := installHomebrew.Run()
	b := brewTapBundle.Run()

	checkError(i)
	checkError(b)

}

func zshSetup() {
	fmt.Println("Install oh-my-zsh and update zsh config")
	installOhMyZsh := exec.Command("curl", "-0", "https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh")
	zshConfig := "~/.zshrc"
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

/*
git config --global user.name ""
git config --global user.email 
*/
