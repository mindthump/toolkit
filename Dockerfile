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
    wget \
    zsh \
    byobu \
    stow \
    vim \
    less \
    tree \
    silversearcher-ag \
    sudo \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Work around crappy-ass bug in released version.
RUN echo "Set disable_coredump false" >> /etc/sudo.conf

# Oh-My-Zsh
RUN curl -Lo omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh \
    && CHSH=no RUNZSH=no sh omz-install.sh --unattended

# Configuration files from my GitHub repo (without git history)
# See gnu "stow" docs and https://is.gd/CdR7Ua
RUN git clone --depth 1 https://github.com/mindthump/dotfiles.git ~/.dotfiles \
    # Remove some files created during setup, we have our own versions.
    && rm -f ~/.zshrc  ~/.profile omz-install.sh \
    && stow --dir ~/.dotfiles --stow zsh vim byobu git

# Preload vim plugins.
RUN vim +PlugInstall +qall &> /dev/null

WORKDIR $HOME
# Copy the build context directory to WORKDIR
# Check the .dockerignore file for exclusions (.git, Dockerfile, etc.).
COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

ENTRYPOINT ["/bin/zsh"]
