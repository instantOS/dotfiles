#!/bin/bash

convert -list font | grep -iq 'roboto' && exit
mkdir -p ~/.local/share/fonts &>/dev/null

pushd .
cd /tmp
mkdir roboto
cd roboto
wget -O roboto.zip "https://fonts.google.com/download?family=Roboto"
unzip roboto.zip
rm LICENSE.txt
rm roboto.zip
mv ./* ~/.local/share/fonts
popd
