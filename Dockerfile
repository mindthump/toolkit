# Python with some basic tools: vim, bash, etc.
FROM python:alpine

# Defaults for the non-root user (use --build-arg on build to override)
ARG USER=morty
ARG UID=1000
ARG GROUP=$USER
ARG GID=$UID
ARG SHELL=/bin/bash
ARG HOME=/home/$USER

# Non-root passwordless superuser
RUN \
    addgroup --gid $GID $GROUP \
    && adduser --disabled-password --gecos "" --shell "$SHELL" --home "$HOME" --ingroup "$GROUP" --uid "$UID" "$USER" \
    && mkdir -p /etc/sudoers.d \
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER

# My favorite command line tools
RUN apk update \
    && apk add --no-cache \
    bash \
    wget \
    vim \
    less \
    tree \
    mc \
    the_silver_searcher \
    sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $HOME

# Copy the build context directory to WORKDIR
# Check the .dockerignore file for exclusions (.git, Dockerfile, etc.).
COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

# Script to do container startup stuff. This idiom allows us to alter the startup
# script without rebuilding the image. The CMD gets exec'd at the end of the script.
# Either can be overridden on the "docker run" command.
ENTRYPOINT ["./.startup/entrypoint.sh"]
CMD ["/bin/bash"]
