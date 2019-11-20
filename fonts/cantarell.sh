#!/bin/bash

convert -list font | grep -iq 'cantarell' && exit
mkdir -p ~/.local/share/fonts &>/dev/null

pushd .
cd /tmp
mkdir cantarell
cd cantarell
wget -O cantarell.zip "https://fonts.google.com/download?family=Cantarell"
unzip cantarell.zip
rm LICENSE.txt
rm cantarell.zip
mv ./* ~/.local/share/fonts
popd
