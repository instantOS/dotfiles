#!/bin/bash

convert -list font | grep -iq 'source.*code' && exit
mkdir -p ~/.local/share/fonts &>/dev/null

echo "installing source code pro"
wget -qO ~/.local/share/fonts/sourcecode.otf \
    "https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Roman.otf"
