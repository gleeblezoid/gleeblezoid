#!/bin/sh

mkdir packages &&
cd packages &&
curl -LJO https://github.com/rxhanson/Rectangle/releases/download/v0.49/Rectangle0.49.dmg &&
hdiutil mount Rectangle0.49.dmg &&
sudo cp -r /Volumes/Rectangle0.49/Rectangle.app /Applications/Rectangle.app &&

curl -LJO https://slack.com/ssb/download-osx-universal &&
mv download-osx-universal download-osx-universal.dmg &&
hdiutil mount download-osx-universal.dmg &&
sudo cp -r /Volumes/Slack/Slack.app /Applications/Slack.app &&

curl -LJO https://downloads.vivaldi.com/stable/Vivaldi.5.3.2679.38.universal.dmg &&
hdiutil mount Vivaldi.5.3.2679.38.universal.dmg &&
cp -r /Volumes/Vivaldi\ 5.3.2679.38.dmg/Vivaldi.app /Applications/Vivaldi.app &&

curl -LJO "https://code.visualstudio.com/sha/download\?build\=stable\&os=darwin-universal" &&
unzip VSCode-darwin-universal.zip &&
cp -r Visual\ Studio\ Code.app /Applications/Visual\ Studio\ Code.app &&

curl -LJO "https://electron.authy.com/download?channel=stable&arch=x64&platform=darwin&version=latest&product=authy" &&
mv download\?channel=stable\&arch=x64\&platform=darwin\&version=latest\&product=authy Authy\ Desktop-*.dmg &&
hdiutil mount Authy\ Desktop-*.dmg &&
sudo cp -r /Volumes/Authy\ Desktop\ */Authy\ Desktop.app /Applications/Authy\ Desktop.app &&

cd ../ &&
rm -rf packages
