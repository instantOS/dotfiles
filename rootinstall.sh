#!/bin/bash

######################################################
## installs all system wide dotfiles for instantOS  ##
######################################################

echo "applying instantOS tweaks to system"

if ! [ "$(whoami)" = "root" ]; then
    echo "please run this as root"
    exit 1
fi

enable_pacman_dots() {
    # enable arch pacman easter egg
    if command -v pacman && [ -e /etc/pacman.conf ] &&
        ! grep -q 'ILoveCandy' </etc/pacman.conf; then
        echo "pacmanifiying your package manager"
        # Enable pacman eating progress dots eater-egg
        sed -i '/VerbosePkgLists/a ILoveCandy' /etc/pacman.conf
        # Enable colored output
        sed -i 's/^#Color/Color/g' /etc/pacman.conf
        sed -i '/^#ParallelDownloads/s/^#//g' /etc/pacman.conf
    fi
}

enable_pacman_dots


# change greeter appearance
echo "installing instantOS lightdm greeter session"
[ -e /etc/lightdm ] || mkdir -p /etc/lightdm
cat /usr/share/instantdotfiles/rootconfig/lightdm-gtk-greeter.conf >/etc/lightdm/lightdm-gtk-greeter.conf

# fix/improve grub settings on nvidia
# also fixes tty resolution

if ! grep -i 'pb-grub' </etc/default/grub && command -v nvidia-smi; then
    RESOLUTION=$(xrandr | grep -oP '[0-9]{3,4}x[0-9]{3,4}' | head -1)

    if [ -n "$RESOLUTION" ]; then
        if grep -i "$RESOLUTION" </etc/default/grub; then
            echo "grub resolution already fixed"
        else
            echo "adjusting grub settings"
            sed -i 's~GRUB_GFXMODE=.*~GRUB_GFXMODE='"$RESOLUTION"'~g' /etc/default/grub
        fi
    fi

    if command -v update-grub; then
        update-grub
    else
        grub-mkconfig -o /boot/grub/grub.cfg
    fi

fi
