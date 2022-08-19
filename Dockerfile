# Larger footprint image with some basic tools and a non-root user ("morty") with a home and paswordless sudo.
FROM ubuntu:20.04

# Defaults for the non-root user
ARG UID=1000
ARG GID=$UID
ARG USER=morty
ARG GROUP=$USER
ARG USER_SHELL=/bin/zsh
ARG HOME=/home/$USER

# Non-root login user with passwordless sudo
RUN addgroup --gid $GID $GROUP && \
    adduser --disabled-password --gecos "" --shell "$USER_SHELL" --home "$HOME" --ingroup "$GROUP" --uid "$UID" "$USER" && \
    mkdir -p /etc/sudoers.d && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER && \
    echo "Set disable_coredump false" >> /etc/sudo.conf  # Work around crappy-ass bug in sudo

## zsh and useful command line tools, delete what you don't want or need.
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --yes --quiet --autoremove --no-install-suggests --no-install-recommends \
    tini zip curl git wget zsh byobu stow vim less tree ytree ncdu psmisc mc silversearcher-ag fzf fd-find sudo ca-certificates \
    && apt clean && rm -rf /var/lib/apt/lists/*

## Oh-My-Zsh
RUN curl -Lo omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh \
    && CHSH=no RUNZSH=no sh omz-install.sh --unattended

## Configuration files from my GitHub repo (without git history), see gnu "stow" docs and https://is.gd/CdR7Ua
RUN git clone --depth 1 https://github.com/mindthump/dotfiles.git ~/.dotfiles \
    ### Remove some files created during setup, we have our own versions.
    && rm -f ~/.zshrc ~/.profile omz-install.sh \
    && stow --dir ~/.dotfiles --stow zsh vim byobu git

## Preload vim plugins.
RUN vim +PlugInstall +qall &> /dev/null

# Set default timezone & link python
RUN ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    ln -s /usr/bin/python3 /usr/bin/python

WORKDIR $HOME

COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

# Script to do container startup stuff. CMD gets exec'd at the end of the script.
ENTRYPOINT ["/usr/bin/tini", "--", "./.entrypoint.sh"]
CMD ["/bin/zsh"]
