#!/usr/bin/zsh

[ -z "$NOTMUX" ] && [ -z "$TMUX" ] &&
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
#

source <(COMPLETE=zsh ins)


alias lg=lazygit
alias pls=sudo
alias v=nvim
alias vv="nvim ."

alias g=git
alias j=just

alias open=xdg-open
alias i=ins

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

set -o emacs

eval "$(starship init zsh)"

