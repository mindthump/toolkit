# Larger footprint image with some basic tools and a non-root user ("morty") with a home and paswordless sudo.
FROM ubuntu:jammy

# Needs curl and some apt sources to get ready for kubectl
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --yes --quiet --autoremove --no-install-suggests --no-install-recommends \
    curl ca-certificates  \
    && apt clean && rm -rf /var/lib/apt/lists/*
RUN curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

## zsh and useful command line tools, delete what you don't want or need. Do first to avoid sudo.conf install question.
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --yes --quiet --autoremove --no-install-suggests --no-install-recommends \
    tini zip git wget zsh byobu stow neovim less bat tree ytree httpie \
    ncdu psmisc mc silversearcher-ag sudo python3.10-venv kubectl buildah \
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
    rm -f ~/.profile && \
    echo "Set disable_coredump false" >> /etc/sudo.conf  # Work around crappy-ass bug in sudo

WORKDIR $HOME
USER $USER

## Oh-My-Zsh
RUN curl -Lo omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh \
    && CHSH=no RUNZSH=no sh omz-install.sh --unattended \
    && rm -rf ~/.zshrc ~/.profile omz-install.sh .oh-my-zsh/.git

## Configuration files from my GitHub repo (without git history), see gnu "stow" docs and https://is.gd/CdR7Ua
RUN git clone --depth 1 https://github.com/mindthump/dotfiles.git ~/.dotfiles \
    && stow --dir ~/.dotfiles --stow zsh vim byobu git

## Preload vim plugins.
RUN vim +PlugInstall +qall

# Set default timezone, link python and bat
RUN sudo ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    sudo ln -s /usr/bin/python3 /usr/bin/python && \
    sudo ln -s /usr/bin/batcat /usr/bin/bat

COPY . .

# Set up a virtual python environment to isolate packages, etc.
############  DO I REALLY NEED THIS ??? ###################
#### Just use `sudo pip install` -- it's a container !!!
#### What about poetry?
RUN python -m venv $HOME/venv && . $HOME/venv/bin/activate

# RUN chown -R "$UID:$GID" .

# Script to do container startup stuff. CMD gets exec'd at the end of the script.
# If this is in a pod defn with command: and args: it is ignored
# It's also ignored on exec'ing into pod
ENTRYPOINT ["/usr/bin/tini", "--", "./entrypoint.sh"]
CMD ["/bin/zsh"]
