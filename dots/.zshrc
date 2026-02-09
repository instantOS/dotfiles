#!/usr/bin/zsh
#
# paperbenni's default zshrc

[ -n "$USETMUX" ] && [ -z "$TMUX" ] &&
    ! [ "$TERM_PROGRAM" = "vscode" ] &&
    command -v tmux &>/dev/null &&
    exec tmux &&
    exit


zstyle ':fzf-tab:*' use-fzf-default-opts yes
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

bindkey -e

# mise
eval "$(mise activate zsh)"

ZIM_CONFIG_FILE=~/.config/zsh/zimrc
ZIM_HOME=~/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi

source ${ZIM_HOME}/init.zsh

source <(COMPLETE=zsh ins)

export PATH="$PATH:~/bin"

alias v=nvim
alias g=git
alias lg=lazygit
alias vv="nvim ."
alias open="xdg-open"
alias i=ins

alias j=just

eval "$(starship init zsh)"

sshh() {
    if ! ssh-add -l &>/dev/null; then
        if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID"; then
            eval "$(ssh-agent)"
        fi
        ssh-add -l 2>/dev/null | grep -q 'RSA' || ssh-add
    fi
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

export PATH="$HOME/node_modules/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

command_not_found_handler() {commandfinder $@}

set -o emacs

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

export PATH="$HOME/.bun/bin:$PATH"

# bun completions
[ -s "/home/benjamin/.bun/_bun" ] && source "/home/benjamin/.bun/_bun"
