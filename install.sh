#!/usr/bin/env bash
cd $HOME
echo "installing config files"
mkdir paperbenni
cd paperbenni
rm -rf dotfiles
git clone --depth=1 https://github.com/paperbenni/dotfiles.git &>/dev/null
cd dotfiles
mv .bashrc ~/
echo "done"
