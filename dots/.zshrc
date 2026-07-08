#!/usr/bin/zsh

export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket

export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/node_modules/.bin:$PATH"

eval "$(mise activate zsh)"

zstyle ':fzf-tab:*' use-fzf-default-opts yes
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

bindkey -e

# Sheldon plugin manager setup (compiled single-file cache)
if [[ ! -s "$HOME/.config/sheldon/source.zsh" \
   || "$HOME/.config/sheldon/plugins.toml" -nt "$HOME/.config/sheldon/source.zsh" \
   || "$HOME/.local/share/sheldon/plugins.lock" -nt "$HOME/.config/sheldon/source.zsh" ]]; then
  local tmp_cache=$(mktemp)
  sheldon source | while read -r line; do
    if [[ "$line" =~ ^source\ \"(.*)\" ]]; then
      local filepath="${match[1]}"
      if [[ "$filepath" == */ohmyzsh/ohmyzsh/lib/* ]]; then
        cat "$filepath" >> "$tmp_cache"
        echo "" >> "$tmp_cache"
      else
        echo "$line" >> "$tmp_cache"
      fi
    else
      echo "$line" >> "$tmp_cache"
    fi
  done
  # Statically cache starship prompt setup
  if command -v starship &>/dev/null; then
    starship init zsh >> "$tmp_cache"
    echo "" >> "$tmp_cache"
  fi
  mv "$tmp_cache" "$HOME/.config/sheldon/source.zsh"
  zcompile "$HOME/.config/sheldon/source.zsh"
fi
source "$HOME/.config/sheldon/source.zsh"

source <(COMPLETE=zsh ins)

export ANSIBLE_VAULT_PASSWORD_FILE=/tmp/ansible-vault-pass."$USER"


alias anspass="bash $HOME/.paperbenni/ansible-vault-agent.sh"
alias g=git
alias i=ins
alias j=just
alias lg=lazygit
alias open="xdg-open"
alias v=nvim
alias vv="nvim ."

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

export EDITOR=nvim

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

command_not_found_handler() {
    if command -v commandfinder >/dev/null 2>&1; then
        commandfinder "$@"
    else
        printf "zsh: command not found: %s\n" "$1" >&2
        return 127
    fi
}

