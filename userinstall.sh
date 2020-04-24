#!/usr/bin/env bash

####################################################
## installs all basic dotfiles for instantOS      ##
## please install the preferred theme before this ##
###################################################
SCRIPTPATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

echo ""
echo "installing dotfiles for $(whoami)"
cd
pwd
echo "HOME $HOME"
echo ""

mkdir ~/instantos

# fetch and install config file from my repo
gget() {
    if [ -n "$2" ]; then
        if echo $2 | grep -q '/'; then
            ARGDIR=$HOME/${2%/*}
            if ! [ -e "$ARGDIR" ]; then
                echo "creating dir $ARGDIR"
                mkdir -p "$ARGDIR" || (echo 'cannot create dir' && return 1)
            fi
        fi
        TARGET="$HOME/$2"

    else
        TARGET="$HOME/$1"
    fi
    echo "installing $1"
    if [ -e ./$1 ]; then
        cat "$1" >"$TARGET"
    else
        curl -s https://raw.githubusercontent.com/paperbenni/dotfiles/master/"$1" >"$TARGET"
    fi
}

gappend() {
    if [ -n "$2" ]; then
        if echo $2 | grep -q '/'; then
            ARGDIR=${2%/*}
            if ! [ -e "$ARGDIR" ]; then
                echo "creating dir $ARGDIR"
                mkdir -p "$ARGDIR" || (echo 'cannot create dir' && return 1)
            fi
        fi
        TARGET="$HOME/$2"
    else
        TARGET="$HOME/$1"
    fi
    echo "installing $1"
    if [ -e $TARGET ] && grep -q "papertheme" "$TARGET"; then
        if ! grep -q "$3" "$TARGET"; then
            if [ -e ./$1 ]; then
                cat "$1" >>"$TARGET"
            else
                curl -s https://raw.githubusercontent.com/paperbenni/dotfiles/master/"$1" >>"$TARGET"
            fi
        fi
    else
        if [ -e ./$1 ]; then
            cat "$1" >"$TARGET"
        else
            curl -s https://raw.githubusercontent.com/paperbenni/dotfiles/master/"$1" >"$TARGET"
        fi
    fi
}

# install git completion script, source it in bashrc
mkdir .paperbenni &>/dev/null

if [ -e "$SCRIPTPATH/rootinstall.sh" ]; then
    cd "$SCRIPTPATH"
    echo "offline dotfiles found"
else
    rm -rf /tmp/paperdotfiles
    mkdir -p /tmp/paperdotfiles
    cd /tmp/paperdotfiles
    git clone --depth=1 https://github.com/paperbenni/dotfiles.git &>/dev/null
    cd dotfiles
fi

gget '.gitconfig'
gget 'git-completion.bash' .paperbenni/git.sh
gget 'tmux.conf' '.tmux.conf'
gget 'bashrc.sh' '.bashrc'
gget 'compton.conf' '.compton.conf'

gget 'flameshot.ini' '.config/Dharkael/flameshot.ini'
gget 'libinput-gestures.conf' '.config/libinput-gestures.conf'
gget 'dunstrc' '.config/dunst/dunstrc'

gget 'ranger/rc.conf' '.config/ranger/rc.conf'
gget 'ranger/commands.py' '.config/ranger/commands.py'
chmod +x ~/.config/ranger/commands.py
gget 'conky.conf' '.config/conky/conky.conf'

gget 'jgmenu/jgmenurc' '.config/jgmenu/jgmenurc'
gget 'jgmenu/prepend.csv' '.config/jgmenu/prepend.csv'

gget 'qt5ct.conf' '.config/qt5ct/qt5ct.conf'

gget 'texstudio.ini' '.config/texstudio/texstudio.ini'

gget 'init.vim' '.config/nvim/init.vim'

gget 'dmrc' '.dmrc'

gget 'desktop/terminal.desktop' '.local/share/file-manager/actions/terminal.desktop'
gget 'desktop/spottoggle.desktop' '.local/share/applications/spottoggle.desktop'
gget 'desktop/nm-applet.desktop' '.local/share/applications/nm-applet.desktop'

gget 'neofetch.conf' '.config/neofetch/config.conf'

gappend Xresources .Xresources 'instantos-general'
gappend dunstrc .config/dunst/dunstrc '[global]'

cd ..
rm -rf /tmp/paperdotfiles

# generate override config
if ! [ -e ~/.instantrc ]; then
    if [ -e /usr/share/instantdotfiles/override.sh ]; then
        bash /usr/share/instantdotfiles/override.sh
    fi
fi
