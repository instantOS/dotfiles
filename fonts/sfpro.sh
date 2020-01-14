#!/bin/bash

source <(curl -Ls https://git.io/JerLG)
pb unpack
cd
mkdir .fonts

mkdir .cache/applefonts

cd .cache/applefonts
if ! convert -list font | grep -q 'SF-Pro'; then
    wget -q https://developer.apple.com/design/downloads/SF-Font-Pro.dmg
    appledmg SF-Font-Pro.dmg
    mv Library/Fonts/* ~/.fonts
    rm -rf ./*
fi

if ! convert -list font | grep -q 'SF-Mono'; then
    wget -q https://developer.apple.com/design/downloads/SF-Mono.dmg
    appledmg SF-Mono.dmg
    mv Library/Fonts/* ~/.fonts
fi

cd
rm -rf .cache/applefonts
