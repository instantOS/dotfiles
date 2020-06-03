#!/usr/bin/env bash

####################################################
## installs all basic dotfiles for instantOS      ##
## please install the preferred theme before this ##
###################################################

# root check
if whoami | grep -q '^root$'; then
    echo "do not run instantdotfiles as root"
    echo "do not run instantdotfiles as root $(date)" >/opt/instantdotfileslog
    exit
fi

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

mkdir -p ~/instantos/olddotfiles &>/dev/null

ctee() {
    mkdir -p ${1%/*} && command tee "$@"
}

DOTDATE="$(date '+%Y%m%d%H%M')"
echo "archiving old dotfiles to ~/instantos/olddotfiles/$DOTDATE"

mkdir -p ~/instantos/olddotfiles/"$DOTDATE"
touch ~/instantos/olddotfiles/"$DOTDATE"/index

# back up dotfile
backupfile() {
    if [ -e "$1" ]; then
        echo "archiving old version of $2"

        touch ~/instantos/olddotfiles/"$DOTDATE"/index || {
            echo "dotfiles installation failed"
            exit
        }

        mkdir -p ~/instantos/olddotfiles/"$DOTDATE"
        cat "$1" | ctee ~/instantos/olddotfiles/"$DOTDATE"/"$2" >/dev/null
        echo "$1" >>~/instantos/olddotfiles/"$DOTDATE"/index
    else
        echo "cannot archive $1, no old version found"
    fi
}

# fetch and install config file from my repo
gget() {
    if [ -n "$2" ]; then
        if grep -q '/' <<<"$2"; then
            TARGETDIR="$(echo $2 | grep -o '^.*/')"
            TARGETDIR="$HOME/$TARGETDIR"
            if ! [ -e "$TARGETDIR" ]; then
                echo "creating $TARGETDIR"
                mkdir -p "$TARGETDIR"
            fi
        fi
        TARGET="$HOME/$2"
        TARGETNAME="$2"
    else
        TARGET="$HOME/$1"
        TARGETNAME="$1"
    fi

    if ! grep -q "^$TARGET [01]" ~/.instantrc; then
        if [ -e $TARGET ] && iconf -i askdotfiles; then
            echo "confirming override"
            if ! imenu -c "override $TARGET ?"; then
                echo "disabling $TARGET"
                echo "$TARGET 0" >>~/.instantrc
                return
            fi
        fi
        echo "$TARGET 1" >>~/.instantrc
        echo "initializing config for $TARGET"
    else
        if grep "^$TARGET 0" ~/.instantrc; then
            echo "skipping $TARGET, management disabled by user"
            return
        fi
    fi

    backupfile "$TARGET" "$TARGETNAME"

    echo "installing $1"
    if [ -e ./$1 ]; then
        cat "$1" >"$TARGET"
    else
        curl -s https://raw.githubusercontent.com/paperbenni/dotfiles/master/"$1" >"$TARGET"
    fi
}

gappend() {
    if [ -n "$2" ]; then
        if grep -q '/' <<<"$2"; then
            TARGETDIR="$(echo $2 | grep -o '^.*/')"
            TARGETDIR="$HOME/$TARGETDIR"
            if ! [ -e "$TARGETDIR" ]; then
                echo "creating $TARGETDIR"
                mkdir -p "$TARGETDIR"
            fi
        fi
        TARGET="$HOME/$2"
    else
        TARGET="$HOME/$1"
    fi

    backupfile "$TARGET" "$TARGETNAME"

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

# generate override config
if ! [ -e ~/.instantrc ]; then
    if [ -e /usr/share/instantdotfiles/override.sh ]; then
        bash /usr/share/instantdotfiles/override.sh
    fi
fi

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
gget 'instantosonboard.theme' '.local/share/onboard/themes/instantosonboard.theme'

gget 'init.vim' '.config/nvim/init.vim'

gget 'dmrc' '.dmrc'

gget 'desktop/terminal.desktop' '.local/share/file-manager/actions/terminal.desktop'
gget 'desktop/spottoggle.desktop' '.local/share/applications/spottoggle.desktop'
gget 'desktop/nm-applet.desktop' '.local/share/applications/nm-applet.desktop'

gget 'neofetch.conf' '.config/neofetch/config.conf'

gappend Xresources '.Xresources' 'instantos-general'
gappend dunstrc '.config/dunst/dunstrc' '[global]'

cd ..
rm -rf /tmp/paperdotfiles
