#!/bin/bash

echo "installing cantarell font"
convert -list font | grep -iq 'cantarell' && exit
mkdir -p ~/.local/share/fonts &>/dev/null

cd /tmp
mkdir cantarell
cd cantarell
wget -qO cantarell.zip "https://fonts.google.com/download?family=Cantarell"
unzip cantarell.zip
rm LICENSE.txt
rm cantarell.zip
mv ./* ~/.local/share/fonts
