#!/bin/bash

######################################################
## installs all system wide dotfiles for instantOS  ##
######################################################

if ! [ $(whoami) = "root" ]; then
    echo "please run this as root"
    exit 1
fi

# enable arch pacman easter egg
if command -v pacman && [ -e /etc/pacman.conf ] &&
    ! grep -q 'ILoveCandy' </etc/pacman.conf; then
    echo "pacmanifiying your pacman manager"
    sed -i '/VerbosePkgLists/a ILoveCandy' /etc/pacman.conf
fi

# fix/improve grub settings on nvidia
# and install a theme
if ! grep -i 'pb-grub' </etc/default/grub && command -v nvidia-smi; then
    echo "installing grub theme"
    cd /tmp
    git clone --depth=1 https://github.com/paperbenni/grub.git
    rm -rf grub/.git
    mv grub /boot/grub/themes/pb-grub
    sed -i 's~#GRUB_THEME="/path/to/gfxtheme"~GRUB_THEME=/boot/grub/themes/pb-grub/theme.txt~g' /etc/default/grub
    sed -i 's~GRUB_TIMEOUT=[0-9]*~GRUB_TIMEOUT=4~g' /etc/default/grub

    RESOLUTION=$(xrandr | grep -oP '[0-9]{3,4}x[0-9]{3,4}' | head -1)

    if [ -n "$RESOLUTION" ]; then
        if grep -i "$RESOLUTION" </etc/default/grub; then
            echo "grub resolution already fixed"
        else
            sed -i 's~GRUB_GFXMODE=.*~GRUB_GFXMODE='"$RESOLUTION"'~g' /etc/default/grub
        fi
    fi

    if command -v update-grub; then
        update-grub
    else
        grub-mkconfig -o /boot/grub/grub.cfg
    fi

fi
