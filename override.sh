#!/bin/bash
echo "" >~/.instantrc

cat <<EOT >>~/.instantrc
# 1 at the end of a line means the file is managed by instantOS
# 0 means it can be overridden by the user

EOT

# give option to manually override dotfiles
cat "/usr/share/instantdotfiles/userinstall.sh" |
    grep "^gg.* .* .*" |
    grep -o '[^ ]*$' | grep -o "[^']*" |
    sed 's/\(.*\)/\1 1/g' >~/.instantrc

cat "/usr/share/instantdotfiles/userinstall.sh" |
    grep "^ga.* .* .*" |
    sed 's/gappend .* \([^ ]*\) .*/\1/g' |
    sed 's/\(.*\)/\1 1/g' >>~/.instantrc
