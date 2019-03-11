#!/usr/bin/env bash
cd $HOME
mkdir paperbenni
cd paperbenni
rm -rf dotfiles
git clone --depth=1 https://github.com/paperbenni/dotfiles.git
cd dotfiles
rm -rf install.sh README.md .git
cp -r ./* ~/
