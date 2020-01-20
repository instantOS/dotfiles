#!/bin/bash

echo "installing monaco"
convert -list font | grep -iq 'monaco.*complete' && (echo "monaco already found" && exit)

mkdir -p ~/.local/share/fonts &>/dev/null

wget -qO ~/.local/share/fonts/monaco.otf \
    "https://raw.githubusercontent.com/Karmenzind/monaco-nerd-fonts/master/fonts/Monaco%20Nerd%20Font%20Complete%20Mono.otf"
