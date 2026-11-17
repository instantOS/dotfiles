#!/usr/bin/env bash

# Install paperbenni's Neovim.

NVIMCMD=${nvimcmd:-nvim}

ismacos() {
    uname | grep -q 'Darwin'
}

# fake access to root, setup works without root on termux
if command -v termux-setup-storage; then
    sudo() {
        $@
    }
fi

checkcommand() {
    if ! command -v "$1"; then
        echo "$1 not found, please install" 1>&2
        exit 1
    fi
}

backup_config() {
    pushd "$HOME" || exit 1
    # Save justfile if it exists
    if [ -e .config/nvim/justfile ]; then
        cp .config/nvim/justfile /tmp/justfile_backup
    fi
    mv .config/nvim .config/"$(date '+%y%m%d%H%M%S')"_nvim_backup 2>/dev/null
    mkdir -p .config/nvim
    # Restore justfile if it was saved
    if [ -e /tmp/justfile_backup ]; then
        cp /tmp/justfile_backup .config/nvim/justfile
        rm /tmp/justfile_backup
    fi
    popd || exit 1
}

check_nix_install() {
    if ! command -v nix-env; then return 1; fi

    if ! command -v pip3 && ! python3 -c "import neovim"; then
        nix-env -i -E 'f: with import <nixpkgs> { }; (python3.withPackages(ps: [ ps.pynvim ] ))'
    fi
    if ! command -v "$NVIMCMD"; then
        nix-env -i neovim
    fi
    if ! command -v npm; then
        nix-env -i nodejs
    fi
}


check_dependencies() {
    checkcommand luarocks
    checkcommand sqlite3
}

ensure_repo() {
    if ! [ -e ./init.lua ]; then
        mkdir -p ~/.cache/paperbenni_nvim
        cd ~/.cache/paperbenni_nvim || exit 1
        if ! [ -e init.lua ]; then
            git clone https://github.com/paperbenni/init.lua
        fi
        cd ~/.cache/paperbenni_nvim/init.lua || exit 1
        echo "using git cache init.lua"
        if ! [ -e init.lua ]; then
            echo "failed to clone config"
            exit 1
        fi
    fi
}

is_potato() {
    if [ -n "$POTATO" ]; then
        return 0
    fi
    if [ -n "$NOPOTATO" ]; then
        return 1
    fi

    if [ -e ~/.config/paperbenni/nopotato.txt ]; then
        export NOPOTATO="true"
        return 1
    fi

    MEMAMOUNT="$(free | sed '/^[^A-Z].*/d' | head -1 | grep -o '[0-9]*' | head -1)"
    if command -v termux-setup-storage ||
        [ -e ~/.config/paperbenni/potato.txt ] ||
        [ "$MEMAMOUNT" -lt "7000000" ]; then
        export POTATO="true"
        echo "optimizing for low end device"
        return 0
    else
        export NOPOTATO="true"
        return 1
    fi
}

install_cfg_files() {
    ensure_repo
    [ -e ~/.config/nvim ] || mkdir -p ~/.config/nvim

    for item in *; do
        if [ "$item" != "justfile" ] && [ "$item" != ".git" ]; then
            cp -r "$item" ~/.config/nvim/
        fi
    done
    POTATOFILE="$HOME"/.config/nvim/lua/mypotato.lua

    if ismacos
    then
    echo '
local ispotato = false
return ispotato' > "$POTATOFILE"
    
    elif is_potato; then
        echo "machine is a potato"
        sed -i '/local ispotato/s/inserthere/true/g' "$POTATOFILE"
    else
        echo "machine is not a potato"
        sed -i '/local ispotato/s/inserthere/false/g' "$POTATOFILE"
    fi

}

install_plugins() {
    echo "installing lazy plugins"
    $NVIMCMD --headless "+Lazy! install" +qa
    PLUGINDIR="$HOME"/.local/share/nvim/lazy

    # compile telescope fzf
    if ! [ -e "$PLUGINDIR"/telescope-fzf-native.nvim/build/libfzf.so ]; then
        cd "$PLUGINDIR"/telescope-fzf-native.nvim || exit 1
        make
    fi

}

install_dependencies() {

    # automatically install required
    # packages when on instantOS
    if command -v instantinstall; then
        instantinstall luarocks
        instantinstall sqlite3
    fi

    if ismacos; then
        brew install python
        brew install luarocks
        brew install sqlite
    fi

}

main() {
    echo "installing paperbenni's neovim config"
    echo "warning, this will override existing configs"

    # Keep what this function does distribution agnostic!

    backup_config
    install_cfg_files
    install_plugins

    echo "finished installing paperbenni's neovim config"
}

if [ "$0" = "$BASH_SOURCE" ]; then
    check_nix_install
    install_dependencies
    check_dependencies
    main "$@"
fi
