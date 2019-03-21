#!/usr/bin/env bash
cd $HOME
mkdir -p .config/bash
pushd .config/bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > git.sh
popd
echo "installing config files"
mkdir paperbenni
cd paperbenni
rm -rf dotfiles
git clone --depth=1 https://github.com/paperbenni/dotfiles.git &>/dev/null
cd dotfiles
mv bashrc .bashrc
mv .bashrc ~/
mv tmux.conf ~/.tmux.conf
echo "done"
