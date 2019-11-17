#!/bin/bash

source <(curl -Ls https://git.io/JerLG)
pb tar
cd
mkdir .fonts

mkdir .cache/applefonts

cd .cache/applefonts
wget https://developer.apple.com/design/downloads/SF-Font-Pro.dmg
appledmg SF-Font-Pro.dmg
mv SanFranciscoPro/Library/Fonts/* ~/.fonts
rm -rf ./*
wget https://developer.apple.com/design/downloads/SF-Mono.dmg
appledmg SF-Mono.dmg
mv SFMonoFonts/Library/Fonts/* ~/.fonts
cd
rm .cache/applefonts
