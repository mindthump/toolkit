# Python, zsh + oh-my-zsh, some tools, and my personal dotfile setup.
FROM ubuntu:20.04

# Defaults for the non-root user
# Use --build-arg on build to override
ARG USER=morty
ARG UID=1000
ARG GROUP=$USER
ARG GID=$UID
ARG SHELL=/bin/zsh
ARG HOME=/home/$USER

# Non-root login user
RUN addgroup --gid $GID $GROUP \
    && adduser \
    --disabled-password \
    --gecos "" \
    --shell "$SHELL" \
    --home "$HOME" \
    --ingroup "$GROUP" \
    --uid "$UID" "$USER"

# Passwordless superuser
RUN mkdir -p /etc/sudoers.d \
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER

# Tools, omz, and dotfiles.
# Note -- layers will not update if underlying packages
# have changed; use --no-cached on build to update

# My favorite command line tools
RUN apt-get update \
    && apt-get install --yes --quiet --no-install-recommends --autoremove \
    git \
    curl \
    zsh \
    byobu \
    stow \
    tmux \
    vim \
    less \
    tree \
    silversearcher-ag \
    sudo \
    ca-certificates \
    | tee /tool-install.log \
    && rm -rf /var/lib/apt/lists/*

# Because I think this should be the default...
RUN ln /usr/bin/python3.8 /usr/bin/python

# This is a bullshit bug in sudo.
RUN echo "Set disable_coredump false" >> /etc/sudo.conf

# Oh-My-Zsh
RUN curl -Lo omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh \
    && CHSH=no RUNZSH=no sh omz-install.sh --unattended

# Configuration files from my GitHub repo (without git history)
# See gnu "stow" docs and https://is.gd/CdR7Ua
RUN git clone --depth 1 https://github.com/mindthump/dotfiles.git ~/.dotfiles \
    # Remove some files created during setup, we have our own versions.
    && rm -f ~/.zshrc  ~/.profile omz-install.sh \
    # Link the dotfiles to the home directory.
    && stow --dir ~/.dotfiles --stow zsh vim byobu git \
    # byobu is installed but don't auto-start it. Use 'byobu' to start manually.
    && rm -f .zprofile

# Preload vim plugins.
RUN vim +PlugInstall +qall >> /tool-install.log

# Copy the build context directory to WORKDIR
# Check the .dockerignore file for exclusions (.git, Dockerfile, etc.).
WORKDIR $HOME
COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

ENTRYPOINT ["/bin/zsh"]
