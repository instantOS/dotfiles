#!/usr/bin/env bash

######################################################
## installs all basic dotfiles for paperbenni setup ##
######################################################

pushd .
cd

# fetch and install config file from my repo
gget() {
    if [ -n "$2" ]; then
        if echo $2 | grep '/'; then
            ARGDIR=${2%/*}
            echo "creating dir $ARGDIR"
            if ! [ -e "$ARGDIR" ]; then
                mkdir -p "$ARGDIR" || (echo 'cannot create dir' && return 1)
            fi
            TARGET="$2"
        else
            TARGET="$HOME/$2"
        fi
    else
        TARGET="$HOME/$1"
    fi
    curl https://raw.githubusercontent.com/paperbenni/dotfiles/master/"$1" >"$TARGET"
}

# install git completion script, source it in bashrc
mkdir .paperbenni
curl 'https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash' >.paperbenni/git.sh

gget '.gitconfig'
gget 'tmux.conf' '.tmux.conf'
gget 'bashrc.sh' '.bashrc'

popd
