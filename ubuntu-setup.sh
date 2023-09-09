apt update && \
  apt install --yes --quiet --autoremove --no-install-suggests --no-install-recommends bat btop byobu delta exa fd fx fzf gawk git gtop gum hr httpie jless jq just lazycli lazygit less lf mc ncdu neovim nnn par psmisc ranger shellcheck silversearcher-ag ss stow sudo tree wget ydiff yq ytree zip zsh

NEW_USER_ID=1002
NEW_USER_GID=$NEW_USER_ID
NEW_USER=morty
NEW_USER_GROUP=$NEW_USER
NEW_USER_SHELL=/usr/bin/zsh
HOME=/home/$NEW_USER

addgroup --gid $NEW_USER_GID $NEW_USER_GROUP && \
  adduser --disabled-password --gecos "" --shell "$NEW_USER_SHELL" --home "$HOME" --ingroup "$NEW_USER_GROUP" --uid "$NEW_USER_ID" "$NEW_USER" && \
  mkdir -p /etc/sudoers.d && \
  echo "$NEW_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$NEW_USER && \
  chmod 0440 /etc/sudoers.d/$NEW_USER && \

wget -O omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh && \
  CHSH=no RUNZSH=no sh omz-install.sh --unattended && \
  rm -rf ~/.zshrc ~/.profile omz-install.sh .oh-my-zsh/.git

# Configuration files from my GitHub repo (without git history), see gnu "stow" docs and https://is.gd/CdR7Ua
# Replacing byobu's tmux.conf to prevent prefix key conflict (^A vs ^B) with host
git clone --depth 1 https://github.com/mindthump/dotfiles.git ~/.dotfiles && \
  stow --dir ~/.dotfiles --stow zsh vim byobu git && \
  mv ~/tmux.conf ~/.byobu/.tmux.conf

## Preload vim plugins.
vim +PlugInstall +qall

# SSH public key
