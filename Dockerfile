# Simple container with python, zsh + oh-my-zsh, some tools, and my personal dotfile setup.

FROM python:alpine

# Defaults
ARG UID=1000
ARG GID=1000
ARG USER=ed
ARG GROUP=ed
ARG USER=ed
ARG SHELL=/bin/zsh

ENV HOME /home/$USER

# Tools
RUN apk update \
    && apk add --no-cache git curl zsh byobu stow tmux vim less mc tree sudo

# oh-my-zsh
RUN curl -Lo omz-install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh \
    && CHSH=no RUNZSH=no sh omz-install.sh --unattended

# my .dotfiles
RUN git clone https://github.com/mindthump/dotfiles.git ~/.dotfiles \
    && rm -f ~/.zshrc omz-install.sh \
    && stow --dir ~/.dotfiles --stow zsh vim byobu git

# New user: no password, don't copy /etc/skel, use defaults from ARGS
RUN addgroup -g $GID $GROUP \
    && adduser --disabled-password --no-create-home --gecos "" \
       --shell "$SHELL" --home "$HOME" --ingroup "$GROUP" --uid "$UID" \
       "$USER"

# Non-root passwordless superuser
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
        && chmod 0440 /etc/sudoers.d/$USER

WORKDIR $HOME
# Copy the build context directory to WORKDIR
# Check the .dockerignore file for exclusions (.git, Dockerfile, etc.).
COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

ENTRYPOINT ["/bin/zsh"]
