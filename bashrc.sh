##########################
## paperbenni's bashrc  ##
##########################

export "$PS1"='$'

# sudo complete only in interactive sessions
if [ "$PS1" ]; then
	complete -cf sudo

	# default git completion from git github
	source ~/.paperbenni/git.sh || echo "git completion not found"

fi

# quickly start paperbash
papertest() {
	source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)
}

# automatically make it a tmux session
if [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
	if command -v tmux &>/dev/null; then
		exec tmux
	fi

fi

# kill all tmux sessions with no terminal emulator attached
tmkill() {
	LIST=$(tmux ls)
	TSESSIONS=""
	while read -r line; do
		if ! echo "$line" | grep 'attached'; then
			tmux kill-session -t "$(echo $line | grep -oP '^\d\d?')"
		fi
	done <<<"$LIST"
}
