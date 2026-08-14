# Dotfiles

Personal configs and machine bootstrap scripts.

Repo: https://github.com/gmdias727/dotfiles

## Fedora quickstart

On a fresh Fedora Workstation install:

```bash
sudo dnf install -y git
git clone git@github.com:gmdias727/dotfiles.git ~/dotfiles
~/dotfiles/fedora/bootstrap.sh
```

The Fedora script:

- enables Chrome, Docker CE, Cursor, Netbird, Ghostty, and lazygit repos
- installs core CLI/dev tools plus desktop apps used on this setup
- configures git identity, zsh + Oh My Zsh, and nvm
- symlinks `.emacs`, Ghostty, and Alacritty configs from this repo
- installs Discord via Flatpak

Arch Linux still uses the root [`bootstrap.sh`](./bootstrap.sh) (pacman/yay).
NixOS config lives under [`nixos/`](./nixos/).
