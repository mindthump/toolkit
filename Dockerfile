# Simple container with python, zsh + oh-my-zsh, some tools, and my personal dotfile setup.

FROM python:alpine

# Defaults
ARG USER=morty
ARG UID=1000
ARG GROUP=$USER
ARG GID=$UID
ARG SHELL=/bin/zsh
ARG HOME=/home/$USER

# New user: no password, don't copy /etc/skel, use defaults from ARGS
RUN addgroup -g $GID $GROUP \
    && adduser \
    --disabled-password \
    --gecos "" \
    --shell "$SHELL" \
    --home "$HOME" \
    --ingroup "$GROUP" \
    --uid "$UID" "$USER"

# Non-root passwordless superuser
RUN mkdir -p /etc/sudoers.d \
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER

# Tools, omz, and dotfiles layers will not update if underlying packages have changed (?), use --no-cached on build to update

# My favorite command line tools
RUN apk update \
    && apk add --no-cache \
    git \
    curl \
    zsh \
    byobu \
    stow \
    tmux \
    vim \
    less \
    mc \
    tree \
    sudo \
    the_silver_searcher

# oh-my-zsh
RUN curl -Lo omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh \
    && CHSH=no RUNZSH=no sh omz-install.sh --unattended

# my .dotfiles
RUN git clone https://github.com/mindthump/dotfiles.git ~/.dotfiles \
    && rm -f ~/.zshrc omz-install.sh \
    && stow --dir ~/.dotfiles --stow zsh vim byobu git

# Preload vim plugins
RUN vim +PlugInstall +qall > /dev/null

WORKDIR $HOME
# Copy the build context directory to WORKDIR
# Check the .dockerignore file for exclusions (.git, Dockerfile, etc.).
COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

# Use '-e BYOBU-DISABLE' to avoid starting with tmux.
ENTRYPOINT ["/bin/zsh"]
