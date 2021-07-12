#!/bin/bash
echo "" >~/.instantrc

cat <<EOT >>~/.instantrc
# This config file allows you to configure dotfile management 
# If you do dotfiles, you're probably okay with vim and plaintext. 
# If you're not, you probably stumbled upon this by accident and should close this window. 

# 1 at the end of a line means the file is managed and updated by instantOS
# 0 means it is managed by the user

EOT
