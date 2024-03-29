# Larger footprint image (lunar), a shitload of tools, and a non-root user ("morty") with a home and paswordless sudo.
FROM ubuntu:22.04

## zsh and useful command line tools, delete what you don't want or need. Do first to avoid sudo.conf install question.
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --yes --quiet --autoremove --no-install-suggests --no-install-recommends \
    bat build-essential byobu ca-certificates ctop curl dnsutils git htop httpie iproute2 jq less linux-tools-common   \
    mc ncdu neovim netcat nmap psmisc silversearcher-ag stow sudo tini tmux tree unzip wget xz-utils ytree zip zsh     \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Non-root login user with passwordless sudo
ARG UID=1000
ARG GID=$UID
ARG USER=morty
ARG GROUP=$USER
ARG USER_SHELL=/bin/zsh
ARG HOME=/home/$USER
RUN addgroup --gid $GID $GROUP && \
    adduser --disabled-password --gecos "" --shell "$USER_SHELL" --home "$HOME" --ingroup "$GROUP" --uid "$UID" "$USER" && \
    mkdir -p /etc/sudoers.d && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER && \
    rm -f ~/.profile

# The rest needs to happen in morty's HOME
WORKDIR $HOME
USER $USER

COPY --chown=$UID:$GID . .
# This adds a whole layer copy
# RUN sudo chown -R "$UID:$GID" .

## Oh-My-Zsh
RUN wget -O omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh \
    && CHSH=no RUNZSH=no sh omz-install.sh --unattended \
    && rm -rf ~/.zshrc ~/.profile omz-install.sh .oh-my-zsh/.git

## Configuration files from my GitHub repo (without git history), see gnu "stow" docs and https://is.gd/CdR7Ua
RUN git clone --depth 1 https://github.com/mindthump/dotfiles.git ~/.dotfiles \
    && stow --dir ~/.dotfiles --stow zsh vim byobu git \
    # Replacing byobu's tmux.conf to prevent prefix key conflict (^A vs ^B) with host
    && mv ~/tmux.conf ~/.byobu/.tmux.conf

## Preload vim plugins.
RUN vim +PlugInstall +qall

# Set default timezone, link python and bat
RUN sudo ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    sudo ln -s /usr/bin/python3 /usr/bin/python && \
    sudo ln -s /usr/bin/batcat /usr/bin/bat

# Script to do container startup stuff. CMD gets exec'd at the end of the script.
# If this is in a pod defn with command: and args: it is ignored
# It's also ignored on exec'ing into pod
ENTRYPOINT ["/usr/bin/tini", "--", "./.entrypoint.sh"]
CMD ["/bin/zsh"]
