#!/bin/bash

convert -list font | grep -iq 'monaco.*complete' && exit

mkdir -p ~/.local/share/fonts &>/dev/null

wget -O ~/.local/share/fonts/monaco.otf \
    "https://raw.githubusercontent.com/Karmenzind/monaco-nerd-fonts/master/fonts/Monaco%20Nerd%20Font%20Complete%20Mono.otf"
