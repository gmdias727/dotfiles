#!/bin/bash

sudo pacman -S git

git config --global user.name "Gabriel Dias Mazieri"
git config --global user.email "gabrieldias7200@gmail.com"
git config --global init.defaultBranch main

echo $OSTYPE
echo "Chad Linux user!"

yay -S base-devel curl ripgrep btop htop neofetch emacs firefox gcc clang go pavucontrol  

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
