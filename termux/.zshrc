# paperbenni's default zshrc

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

autoload -U compinit
compinit

if ! [ -e ~/lena ]
then
    set -o vi
fi
# clear

source ~/.config/zsh/music.zsh

export PATH="$PATH:~/bin"

alias s="cd ~/storage/shared || termux-setup-storage"
alias q=exit
alias v=nvim
alias t=task
alias g=git
alias lg=lazygit
alias vv="nvim ."
alias codex="just ~/.codex/ run"
# builtin ripgrep is broken
alias claude="CLAUDE_CODE_TMPDIR=$PREFIX/tmp USE_BUILTIN_RIPGREP=0 claude"

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

export PATH="$PATH:$PREFIX/local/bin:$HOME/git-annex.linux/bin"


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

# opencode
export PATH=/data/data/com.termux/files/home/.opencode/bin:$PATH
