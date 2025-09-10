if status is-interactive
    # Commands to run in interactive sessions can go here
    zoxide init fish | source
    ~/.local/bin/mise activate fish | source
    starship init fish | source
    set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket
    set -Ux FZF_DEFAULT_OPTS "\
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
    --color=selected-bg:#45475a \
    --multi"
    alias lg lazygit
    alias pls sudo
    alias nv "neovide --multigrid"
    alias v nvim
    alias vv "nvim ."

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end

