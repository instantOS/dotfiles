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
    echo "installing $1"
    curl -s https://raw.githubusercontent.com/paperbenni/dotfiles/master/"$1" >"$TARGET"
}

# install git completion script, source it in bashrc
mkdir .paperbenni &> /dev/null
curl 'https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash' >.paperbenni/git.sh

gget '.gitconfig'
gget 'tmux.conf' '.tmux.conf'
gget 'bashrc.sh' '.bashrc'
gget 'compton.conf' '.compton.conf'

gget 'flameshot.ini' '.config/Dharkael/flameshot.ini'

gget 'ranger/rc.conf' '.config/ranger/rc.conf'
gget 'ranger/commands.py' '.config/ranger/commands.py'
gget 'conky.conf' '.config/conky/conky.conf'

# enable arch pacman easter egg
if command -v pacman && [ -e /etc/pacman.conf ] &&
    ! grep -q 'ILoveCandy' </etc/pacman.conf; then
    echo "pacmanifiying your pacman manager"
    sudo sed -i '/VerbosePkgLists/a ILoveCandy' /etc/pacman.conf
fi

# fix/improve grub settings
if ! grep -i 'pb-grub' </etc/default/grub && command -v nvidia-smi; then
    echo "installing grub theme"
    git clone --depth=1 https://github.com/paperbenni/grub.git
    rm -rf grub/.git
    sudo mv grub /boot/grub/themes/pb-grub
    sudo sed -i 's~#GRUB_THEME="/path/to/gfxtheme"~GRUB_THEME=/boot/grub/themes/pb-grub/theme.txt~g' /etc/default/grub
    sudo sed -i 's~GRUB_TIMEOUT=[0-9]*~GRUB_TIMEOUT=4~g' /etc/default/grub

    RESOLUTION=$(xrandr | grep -oP '[0-9]{3,4}x[0-9]{3,4}' | head -1)

    if [ -n "$RESOLUTION" ]; then
        if grep -i "$RESOLUTION" </etc/default/grub; then
            echo "grub resolution already fixed"
        else
            sudo sed -i 's~GRUB_GFXMODE=.*~GRUB_GFXMODE='"$RESOLUTION"'~g' /etc/default/grub
        fi
    fi

    if command -v update-grub; then
        sudo update-grub
    else
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi

fi

popd
