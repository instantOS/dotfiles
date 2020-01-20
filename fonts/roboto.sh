#!/bin/bash

echo "installing roboto"
convert -list font | grep -iq 'roboto' && exit
mkdir -p ~/.local/share/fonts &>/dev/null

cd /tmp
mkdir roboto
cd roboto
wget -qO roboto.zip "https://fonts.google.com/download?family=Roboto"
unzip roboto.zip
rm LICENSE.txt
rm roboto.zip
mv ./* ~/.local/share/fonts
