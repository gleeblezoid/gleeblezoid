# Moving from homebrew to macports automatically

- [ ] Install brew bundle
- [ ] Create a brew list using a bundle dump
- [ ] Convert the brew list to a format that MacPorts can use (just package names)
- [ ] - [ ] Use MacPorts API to query through list and find matching packages by name (present user with options if multiple matches come back, warn and append to another list for manual install if no matches found)
- [ ] Check if user still wants to go ahead and if they do then:
  - [ ] Grab the Homebrew uninstaller from https://github.com/Homebrew/install
  - [ ] Uninstall homebrew and all the packages with the uninstall script
  - [ ] Install MacPorts
  - [ ] Run through the list of ports that are known to be available and install them
  - [ ] Present the user with a list of the packages which will need to be installed manually


Bonus features:
- [ ] Portfiles for common casks (e.g. Chrome, Slack, Spotify)
- [ ] Offered backup solution for other packages that don't have ports (e.g. search online for each using list input and prepend search string with "install")
