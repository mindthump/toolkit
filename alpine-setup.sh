apt update && \
  apt install --yes --quiet --autoremove --no-install-suggests --no-install-recommends

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

# Some basic tools and a non-root user ("morty") with a home and paswordless sudo.
# Modify $TOOLS, etc. as desired.
FROM alpine:latest

# Defaults for the non-root user
ARG UID=1000
ARG GID=$UID
ARG USER=morty
ARG GROUP=$USER
ARG USER_SHELL=/bin/bash
ARG HOME=/home/$USER

# Non-root login user with passwordless sudo
RUN addgroup --gid $GID $GROUP \
&& adduser --disabled-password --gecos "" --shell "$USER_SHELL" --home "$HOME" --ingroup "$GROUP" --uid "$UID" "$USER" \
&& mkdir -p /etc/sudoers.d \
&& echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
&& chmod 0440 /etc/sudoers.d/$USER \
&& echo "Set disable_coredump false" >> /etc/sudo.conf  # Work around crappy-ass bug in sudo

# TOOLS help me explore the system and make the terminal nicer and easier to use (IMO).
ENV
TOOLS='

bash bat bind-tools btop byobu delta exa fd fx fzf gawk git gtop gum hr httpie iproute2 jless jq just lazycli lazygit less lf mc ncdu neovim net-tools nmap nnn par psmisc ranger shellcheck silversearcher-ag ss stow sudo the_silver_searcher tini tmux tree wget ydiff yq ytree zip zsh

RUN apk update \
&& apk add --no-cache ${TOOLS} ${NET_TOOLS} \
&& ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

WORKDIR $HOME

COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

# Script to do container startup stuff. CMD gets exec'd at the end of the script.
ENTRYPOINT ["tini", "--", "./.entrypoint.sh"]
CMD ["/usr/bin/tmux"]
