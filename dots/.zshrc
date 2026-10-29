#!/usr/bin/zsh

export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket

export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/node_modules/.bin:$PATH"

# Tool shims make managed commands available before mise activation.
path=("$HOME/.local/share/mise/shims" $path)
typeset -U path

zstyle ':fzf-tab:*' use-fzf-default-opts yes
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

bindkey -e

# Cache reusable init code; mise activation itself remains dynamic.
_zsh_cached_init() {
  local name=$1 executable=$commands[$2]
  shift
  [[ -n $executable ]] || return 127
  # A shim's timestamp describes mise, not the selected tool installation.
  if [[ $executable == "$HOME/.local/share/mise/shims/"* ]]; then
    executable=$(command mise which "$1") || return
  fi
  executable=${executable:A}
  local cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init
  local cache=$cache_dir/$name.zsh
  local tool_config=${XDG_CONFIG_HOME:-$HOME/.config}/$name/config.toml
  local fingerprint="${(qqq)@}:$executable" file previous
  local -A info
  zmodload zsh/stat
  for file in "$executable" "${ZDOTDIR:-$HOME}/.zshrc" "$tool_config"; do
    info=()
    if zstat -H info -- "$file" 2>/dev/null; then
      fingerprint+="|$file:$info[device]:$info[inode]:$info[size]:$info[mtime]:$info[ctime]"
    else
      fingerprint+="|$file:missing"
    fi
  done
  [[ -r $cache.key ]] && previous=$(<"$cache.key")
  if [[ ! -s $cache || $previous != $fingerprint ]]; then
    command mkdir -p "$cache_dir" || return
    local tmp=$cache.$$.tmp
    if "$executable" "${@:2}" >| "$tmp" && [[ -s $tmp ]]; then
      [[ ! -f $cache.zwc ]] || command unlink "$cache.zwc"
      command mv -f "$tmp" "$cache" || return
      print -r -- "$fingerprint" >| "$tmp.key"
      command mv -f "$tmp.key" "$cache.key"
    else
      [[ ! -f $tmp ]] || command unlink "$tmp"
      return 1
    fi
  fi
  source "$cache"
}

# Sheldon plugin manager setup (compiled single-file cache)
if [[ ! -s "$HOME/.config/sheldon/source.zsh" \
   || "$HOME/.config/sheldon/plugins.toml" -nt "$HOME/.config/sheldon/source.zsh" \
   || "$HOME/.local/share/sheldon/plugins.lock" -nt "$HOME/.config/sheldon/source.zsh" ]]; then
  if ! command -v sheldon &>/dev/null; then
    echo "Sheldon not found. Installing via mise..."
    mise use -g sheldon
    eval "$(mise env)"
  fi
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
  mv "$tmp_cache" "$HOME/.config/sheldon/source.zsh"
  zcompile "$HOME/.config/sheldon/source.zsh"
fi
source "$HOME/.config/sheldon/source.zsh"
_zsh_cached_init starship starship init zsh


COMPLETE=zsh _zsh_cached_init ins ins

export ANSIBLE_VAULT_PASSWORD_FILE=/tmp/ansible-vault-pass."$USER"


alias anspass="bash $HOME/.paperbenni/ansible-vault-agent.sh"
alias g=git
alias i=ins
alias j=just
alias lg=lazygit
alias open="xdg-open"
alias v=nvim
alias vv="nvim ."

alias hr="herdr"
alias oc="opencode2"

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


_zsh_cached_init atuin atuin init zsh

# Activate last: compdef exists, and PATH is final before mise captures it.
eval "$(mise activate zsh)"
