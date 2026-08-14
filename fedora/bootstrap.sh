#!/usr/bin/env bash
# Fedora Workstation quickstart for https://github.com/gmdias727/dotfiles
#
# Usage (from a fresh Fedora install):
#   git clone git@github.com:gmdias727/dotfiles.git ~/dotfiles
#   ~/dotfiles/fedora/bootstrap.sh
#
# Idempotent where practical: safe to re-run.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVM_VERSION="v0.40.3"

log()  { printf '\n==> %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }
is_installed() { rpm -q "$1" >/dev/null 2>&1; }

require_fedora() {
  if [[ ! -f /etc/fedora-release ]]; then
    echo "This script is for Fedora only." >&2
    exit 1
  fi
  log "Detected $(cat /etc/fedora-release)"
}

dnf_install() {
  local pkgs=()
  local pkg
  for pkg in "$@"; do
    if ! is_installed "$pkg"; then
      pkgs+=("$pkg")
    fi
  done
  if ((${#pkgs[@]})); then
    sudo dnf install -y "${pkgs[@]}"
  else
    echo "Already installed: $*"
  fi
}

enable_copr() {
  local project="$1"
  local owner="${project%%/*}"
  local name="${project#*/}"
  local repo_file="/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:${owner}:${name}.repo"
  if [[ -f "$repo_file" ]]; then
    echo "COPR already enabled: $project"
  else
    sudo dnf copr enable -y "$project"
  fi
}

write_repo_if_missing() {
  local path="$1"
  local contents="$2"
  if [[ -f "$path" ]]; then
    echo "Repo exists: $path"
    return
  fi
  echo "$contents" | sudo tee "$path" >/dev/null
}

setup_third_party_repos() {
  log "Third-party repositories"

  write_repo_if_missing /etc/yum.repos.d/google-chrome.repo \
'[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub'

  write_repo_if_missing /etc/yum.repos.d/docker-ce.repo \
'[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/fedora/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg'

  write_repo_if_missing /etc/yum.repos.d/cursor.repo \
'[cursor]
name=Cursor
baseurl=https://downloads.cursor.com/yumrepo
enabled=1
gpgcheck=1
gpgkey=https://downloads.cursor.com/keys/anysphere.asc
repo_gpgcheck=1'

  write_repo_if_missing /etc/yum.repos.d/netbird.repo \
'[NetBird]
name=NetBird
baseurl=https://pkgs.netbird.io/yum/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
repo_gpgcheck=1'

  # Steam lives in RPM Fusion nonfree.
  if [[ ! -f /etc/yum.repos.d/rpmfusion-nonfree-steam.repo ]]; then
    sudo dnf install -y \
      "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" \
      || true
  fi

  enable_copr scottames/ghostty
  enable_copr dejan/lazygit

  sudo dnf makecache
}

install_core_packages() {
  log "Core packages (dnf)"
  sudo dnf group install -y development-tools || \
    sudo dnf install -y @development-tools

  dnf_install \
    git \
    curl \
    wget \
    zsh \
    gcc \
    clang \
    make \
    golang \
    ripgrep \
    btop \
    htop \
    fastfetch \
    emacs \
    firefox \
    pavucontrol \
    gnome-tweaks \
    ghostty \
    lazygit \
    gh \
    wireshark \
    thunderbird \
    obs-studio \
    bat \
    flatpak
}

install_third_party_packages() {
  log "Third-party packages"
  dnf_install \
    google-chrome-stable \
    cursor \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    netbird \
    netbird-ui

  # Optional desktop extras (skip quietly if unavailable).
  if ! is_installed steam; then
    sudo dnf install -y steam || echo "Skipping steam (RPM Fusion may be missing)."
  fi
}

setup_docker() {
  log "Docker"
  sudo systemctl enable --now docker
  if ! groups "$USER" | grep -qw docker; then
    sudo usermod -aG docker "$USER"
    echo "Added $USER to docker group (log out/in to take effect)."
  fi
}

setup_git() {
  log "Git identity"
  git config --global user.name "Gabriel Dias Mazieri"
  git config --global user.email "gabrieldias7200@gmail.com"
  git config --global init.defaultBranch main
}

setup_zsh() {
  log "Zsh + Oh My Zsh"
  if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "Oh My Zsh already installed."
  fi

  local current_shell
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
  if [[ "$current_shell" != "$(command -v zsh)" ]]; then
    chsh -s "$(command -v zsh)"
    echo "Default shell set to zsh (new login required)."
  fi
}

setup_nvm() {
  log "nvm ${NVM_VERSION}"
  if [[ ! -d "${HOME}/.nvm" ]]; then
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
  else
    echo "nvm already installed."
  fi
}

link_dotfile() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      echo "OK  $dest"
      return
    fi
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mv "$dest" "${dest}.pre-dotfiles"
    echo "Backed up $dest -> ${dest}.pre-dotfiles"
  fi
  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
}

setup_dotfiles() {
  log "Symlink configs from ${DOTFILES_DIR}"
  link_dotfile "${DOTFILES_DIR}/.emacs" "${HOME}/.emacs"
  link_dotfile "${DOTFILES_DIR}/.config/ghostty/config" "${HOME}/.config/ghostty/config"

  if [[ -d "${DOTFILES_DIR}/.config/alacritty" ]]; then
    link_dotfile "${DOTFILES_DIR}/.config/alacritty" "${HOME}/.config/alacritty"
  fi
}

setup_flatpak_apps() {
  log "Flatpak apps"
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install -y flathub com.discordapp.Discord || true
}

print_next_steps() {
  cat <<EOF

Done.

Next steps (manual / optional):
  - Log out and back in (docker group + zsh).
  - Install Iosevka for Emacs/Ghostty:
      https://github.com/be5invis/Iosevka/releases
  - Docker Desktop (optional): download the Fedora RPM from docker.com
  - gh auth login
  - netbird up
  - Open a new shell and: nvm install --lts

Repo: ${DOTFILES_DIR}
EOF
}

main() {
  require_fedora
  log "Updating system"
  sudo dnf upgrade -y

  setup_third_party_repos
  install_core_packages
  install_third_party_packages
  setup_docker
  setup_git
  setup_zsh
  setup_nvm
  setup_dotfiles
  setup_flatpak_apps
  print_next_steps
}

main "$@"
