##########################
## paperbenni's bashrc  ##
##########################

export PS1="\[\e[34m\]\u\[\e[m\]\[\e[33m\]\`parse_git_branch\`\[\e[m\]\[\e[32m\]\\$\[\e[m\] "

if [ "$PS1" ]; then
	complete -cf sudo
fi

papertest() {
	source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)
}

if [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
	if command -v tmux &>/dev/null; then
		exec tmux
	fi

fi

source ~/.paperbenni/git.sh || echo "git completion not found"

tmkill() {
	LIST=$(tmux ls)
	TSESSIONS=""
	while read -r line; do
		if ! echo "$line" | grep 'attached'; then
			tmux kill-session -t "$(echo $line | grep -oP '^\d\d?')"
		fi
	done <<<"$LIST"
}
