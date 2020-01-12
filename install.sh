#!/usr/bin/env bash

####################################################
## installs all basic dotfiles for instantOS      ##
## please install the preferred theme before this ##
###################################################

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
    echo "installing $1"
    curl -s https://raw.githubusercontent.com/paperbenni/dotfiles/master/"$1" >"$TARGET"
}

gappend() {
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
    echo "installing $1"
    if [ -e $TARGET ] && grep -q "papertheme" "$TARGET"; then
        if ! grep -q "$3" "$TARGET"; then
            curl -s https://raw.githubusercontent.com/paperbenni/dotfiles/master/"$1" >>"$TARGET"
        fi
    else
        curl -s https://raw.githubusercontent.com/paperbenni/dotfiles/master/"$1" >"$TARGET"
    fi
}

# install git completion script, source it in bashrc
mkdir .paperbenni &>/dev/null
curl 'https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash' >.paperbenni/git.sh

gget '.gitconfig'
gget 'tmux.conf' '.tmux.conf'
gget 'bashrc.sh' '.bashrc'
gget 'compton.conf' '.compton.conf'

gget 'flameshot.ini' '.config/Dharkael/flameshot.ini'
gget 'libinput-gestures.conf' '.config/libinput-gestures.conf'
gget 'dunstrc' '.config/dunst/dunstrc'

gget 'ranger/rc.conf' '.config/ranger/rc.conf'
gget 'ranger/commands.py' '.config/ranger/commands.py'
gget 'conky.conf' '.config/conky/conky.conf'

gget 'qt5ct.conf' '/home/benjamin/.config/qt5ct/qt5ct.conf'

gappend Xresources .Xresources 'instantos-general'
gappend dunstrc .config/dunst/dunstrc '[global]'

popd
