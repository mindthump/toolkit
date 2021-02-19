FROM ubuntu:20.04

# Defaults for the non-root user.
ARG UID=1000
ARG GID=$UID
ARG USER=morty
ARG GROUP=$USER
ARG USER_SHELL=/bin/zsh
ARG HOME=/home/$USER

# Non-root login user, way safer than letting it run as root (the default).
RUN addgroup --gid $GID $GROUP \
    && adduser \
    --disabled-password \
    --gecos "" \
    --shell "$USER_SHELL" \
    --home "$HOME" \
    --ingroup "$GROUP" \
    --uid "$UID" "$USER"

# Set up the non-root user as a passwordless superuser
##   Also work around crappy-ass bug in sudo. This might go away at some point.
RUN mkdir -p /etc/sudoers.d \
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER \
    && echo "Set disable_coredump false" >> /etc/sudo.conf

# Set default timezone & link python
RUN ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    ln -s /usr/bin/python3 /usr/bin/python

## zsh and useful command line tools, delete what you don't want or need.
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --yes --quiet --autoremove --no-install-suggests --no-install-recommends \
    tini zip curl git wget zsh byobu stow vim less tree psmisc mc silversearcher-ag sudo ca-certificates \
    && apt clean && rm -rf /var/lib/apt/lists/*

## Oh-My-Zsh
RUN curl -Lo omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh \
    && CHSH=no RUNZSH=no sh omz-install.sh --unattended

## Configuration files from my GitHub repo (without git history), see gnu "stow" docs and https://is.gd/CdR7Ua
RUN git clone --depth 1 https://github.com/mindthump/dotfiles.git ~/.dotfiles \
    ### Remove some files created during setup, we have our own versions.
    && rm -f ~/.zshrc  ~/.profile omz-install.sh \
    && stow --dir ~/.dotfiles --stow zsh vim byobu git

## Preload vim plugins.
RUN vim +PlugInstall +qall &> /dev/null

WORKDIR $HOME

COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

ENTRYPOINT ["/usr/bin/tini", "--", "./entrypoint.sh"]
CMD ["/bin/zsh"]
