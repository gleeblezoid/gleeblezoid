#!/bin/bash

mkdir packages &&
cd packages &&
curl -LJO https://github.com/rxhanson/Rectangle/releases/download/v0.49/Rectangle0.49.dmg &&
hdiutil mount Rectangle0.49.dmg &&
sudo cp -r /Volumes/Rectangle0.49/Rectangle.app /Applications/Rectangle.app &&
hdiutil detach Rectangle0.49.dmg &&

curl -LJO https://slack.com/ssb/download-osx-universal &&
mv download-osx-universal download-osx-universal.dmg &&
hdiutil mount download-osx-universal.dmg &&
sudo cp -r /Volumes/Slack/Slack.app /Applications/Slack.app &&
hdiutil detach /Volumes/Slack &&

curl -LJO https://downloads.vivaldi.com/stable/Vivaldi.4.3.2439.65.universal.dmg &&
hdiutil mount Vivaldi.4.3.2439.65.universal.dmg &&
cp /Volumes/Vivaldi\ 4.3.2439.65.dmg/Vivaldi.app /Applications/Vivaldi.app &&
hdiutil detach /Volumes/Vivaldi\ 4.3.2439.65.dmg &&

curl -LJO https://code.visualstudio.com/sha/download\?build\=stable\&os\=darwin-universal &&
unzip VSCode-darwin-universal.zip &&
cp Visual\ Studio\ Code.app /Applications/Visual\ Studio\ Code.app &&

curl -LJO https://electron.authy.com/download?channel=stable&arch=x64&platform=darwin&version=latest&product=authy &&
mv download\?channel=stable\&arch=x64\&platform=darwin\&version=latest\&product=authy Authy\ Desktop-1.9.0.dmg &&
hdiutil mount Authy\ Desktop-1.9.0.dmg &&
sudo cp -r /Volumes/Authy\ Desktop\ 1.9.0/Authy\ Desktop.app /Applications/Authy\ Desktop.app &&
hdiutil detach Authy\ Desktop.app &&

cd ../ &&
rm -rf packages
