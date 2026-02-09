#!/usr/bin/zsh
#
# paperbenni's default zshrc

[ -n "$USETMUX" ] && [ -z "$TMUX" ] &&
    ! [ "$TERM_PROGRAM" = "vscode" ] &&
    command -v tmux &>/dev/null &&
    exec tmux &&
    exit

export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
eval "$(mise activate zsh)"

zstyle ':fzf-tab:*' use-fzf-default-opts yes
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

bindkey -e

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

export ANSIBLE_VAULT_PASSWORD_FILE=/tmp/ansible-vault-pass."$USER"
alias anspass="bash $HOME/.paperbenni/ansible-vault-agent.sh"

alias lg=lazygit
alias v=nvim
alias g=git
alias vv="nvim ."
alias open="xdg-open"
alias i=ins

alias j=just

eval "$(starship init zsh)"


# yazi wrapper which keeps cwd
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

set -o emacs


# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"


export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$HOME/node_modules/.bin:$PATH"
export PATH="$PATH:~/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

command_not_found_handler() {which commandfinder && commandfinder $@}
