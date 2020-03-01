#!/bin/bash
echo "installing source code pro"
convert -list font | grep -iq 'source.*code' && exit

pushd .

mkdir -p ~/.local/share/fonts &>/dev/null
cd ~/.local/share/fonts
echo "installing source code pro"
wget -qO sourcecode.otf \
    "https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Roman.otf"

# custom font symbols
wget "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono.ttf"
wget "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete.ttf"

popd
