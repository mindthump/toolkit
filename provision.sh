#!/usr/bin/env bash
# provision.sh — single source of truth for the toolkit's packages, user, and
# dotfiles setup. Idempotent: safe to run at Docker build time AND against an
# already-running container to (re)provision or patch it in place.
#
# Usage:
#   As root, inside the target container:
#     ./provision.sh
#
#   Override any default via environment variable:
#     TOOLKIT_USER=jane TOOLKIT_UID=2000 ./provision.sh
#
#   To carry over tmux.conf, keep it alongside this script (same directory) —
#   it gets picked up automatically if present. Not required.

set -euo pipefail

: "${TOOLKIT_UID:=1001}"
: "${TOOLKIT_GID:=$TOOLKIT_UID}"
: "${TOOLKIT_USER:=morty}"
: "${TOOLKIT_GROUP:=$TOOLKIT_USER}"
: "${TOOLKIT_SHELL:=/bin/zsh}"
: "${TOOLKIT_HOME:=/home/$TOOLKIT_USER}"

DOTFILES_REPO="https://github.com/mindthump/dotfiles.git"

log() { printf '>>> %s\n' "$*" >&2; }

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    log "This script must be run as root (it installs packages and creates a user)."
    exit 1
  fi
}

install_packages() {
  log "Installing packages"

  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet --autoremove \
    --no-install-suggests --no-install-recommends \
    bat \
    btop \
    build-essential \
    byobu \
    ca-certificates \
    curl \
    dnsutils \
    eza \
    fzf \
    gawk \
    git \
    htop \
    httpie \
    iproute2 \
    jq \
    just \
    less \
    lf \
    linux-tools-common \
    mc \
    ncdu \
    neovim \
    netcat-traditional \
    nmap \
    nnn \
    par \
    psmisc \
    ranger \
    shellcheck \
    silversearcher-ag \
    stow \
    sudo \
    tini \
    tmux \
    tree \
    unzip \
    wget \
    xz-utils \
    yq \
    zip \
    zsh

  apt-get clean
  rm -rf /var/lib/apt/lists/*
}

create_user() {
  if id "$TOOLKIT_USER" >/dev/null 2>&1; then
    log "User $TOOLKIT_USER already exists, skipping creation"
    return
  fi
  log "Creating user $TOOLKIT_USER (uid=$TOOLKIT_UID)"
  addgroup --gid "$TOOLKIT_GID" "$TOOLKIT_GROUP"
  adduser --disabled-password --gecos "" --shell "$TOOLKIT_SHELL" \
    --home "$TOOLKIT_HOME" --ingroup "$TOOLKIT_GROUP" --uid "$TOOLKIT_UID" "$TOOLKIT_USER"
  mkdir -p /etc/sudoers.d
  echo "$TOOLKIT_USER ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$TOOLKIT_USER"
  chmod 0440 "/etc/sudoers.d/$TOOLKIT_USER"
}

stage_local_files() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -f "$script_dir/tmux.conf" ]]; then
    log "Staging tmux.conf into $TOOLKIT_HOME"
    mkdir -p "$TOOLKIT_HOME"
    cp "$script_dir/tmux.conf" "$TOOLKIT_HOME/tmux.conf"
    chown "$TOOLKIT_UID:$TOOLKIT_GID" "$TOOLKIT_HOME/tmux.conf"
  fi
}

provision_user_environment() {
  log "Setting up $TOOLKIT_USER's shell environment"
  # Forced to bash (-s /bin/bash) regardless of the user's login shell, so
  # this logic doesn't depend on zsh happening to support the same set -o
  # flags. The user's actual configured shell (zsh) is untouched.
  su - "$TOOLKIT_USER" -s /bin/bash <<'USERSCRIPT'
set -euo pipefail

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  wget -qO /tmp/omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
  CHSH=no RUNZSH=no sh /tmp/omz-install.sh --unattended
  rm -rf "$HOME/.zshrc" "$HOME/.profile" /tmp/omz-install.sh "$HOME/.oh-my-zsh/.git"
fi

if [[ ! -d "$HOME/.dotfiles" ]]; then
  git clone --depth 1 "https://github.com/mindthump/dotfiles.git" "$HOME/.dotfiles"
else
  git -C "$HOME/.dotfiles" pull --ff-only
fi

stow --dir "$HOME/.dotfiles" --target "$HOME" --stow zsh vim byobu git

# Replacing byobu's tmux.conf to prevent prefix key conflict (^A vs ^B) with host
if [[ -f "$HOME/tmux.conf" ]]; then
  mkdir -p "$HOME/.byobu"
  mv -f "$HOME/tmux.conf" "$HOME/.byobu/.tmux.conf"
fi

vim +PlugInstall +qall || true
USERSCRIPT
}

system_tweaks() {
  log "Applying system-wide tweaks"
  ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
  ln -fs /usr/bin/python3 /usr/bin/python
  ln -fs /usr/bin/batcat /usr/bin/bat
}

main() {
  require_root
  install_packages
  create_user
  stage_local_files
  provision_user_environment
  system_tweaks
  log "Done. Log in as $TOOLKIT_USER: su - $TOOLKIT_USER"
}

main "$@"
