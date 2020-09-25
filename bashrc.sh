#!/usr/bin/env bash
##########################
## paperbenni's bashrc  ##
##########################

# dont to anything on non-interactive sessions
[ -z "$PS1" ] && return

if ! [ -e ~/storage/shared ]; then

    force_color_prompt=yes

    if [ -n "$force_color_prompt" ]; then
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
            # We have color support; assume it's compliant with Ecma-48
            # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
            # a case would tend to support setf rather than setaf.)
            color_prompt=yes
        else
            color_prompt=
        fi
    fi

    if [ "$color_prompt" = yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    else
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    fi
    unset color_prompt force_color_prompt

else

    PS1='$> '
fi

HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
shopt -s checkwinsize

export EDITOR=nvim
export PAGER=less

complete -cf sudo
source ~/.paperbenni/git.sh || echo "git completion not found"

# quickly start paperbash
papertest() {
    source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)
}

set -o vi

bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

# automatically make it a tmux session
if [ -n "$PS1" ] &&
    [ -n "$DISPLAY" ] &&
    [[ ! "$TERM" =~ screen ]] &&
    [[ ! "$TERM" =~ tmux ]] &&
    [ -z "$TMUX" ] &&
    ! [ -e ~/storage/shared ]; then

    if [[ "$SHELL" == *"bash" ]]; then
        exec tmux
    else
        exec tmux -c bash
    fi
fi

# kill all tmux sessions with no terminal emulator attached
tmkill() {
    LIST="$(tmux ls)"
    TSESSIONS=""
    while read -r line; do
        if ! echo "$line" | grep 'attached'; then
            tmux kill-session -t "$(echo $line | grep -oP '^\d\d?')"
        fi
    done <<<"$LIST"
}

sl() {
    sll
}

# quick way to run instantOS utils
i() {
    "instant$@"
}

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# autojump j function
[ -e /usr/share/autojump/autojump.bash ] && source /usr/share/autojump/autojump.bash
