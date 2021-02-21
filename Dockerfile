# Small footprint image with some basic tools and a non-root user ("morty") with a home and paswordless sudo.
FROM alpine:3.13.2

# Defaults for the non-root user
ARG UID=1000
ARG GID=$UID
ARG USER=morty
ARG GROUP=$USER
ARG USER_SHELL=/bin/bash
ARG HOME=/home/$USER

# Non-root login user with passwordless sudo
RUN addgroup --gid $GID $GROUP && \
    adduser --disabled-password --gecos "" --shell "$USER_SHELL" --home "$HOME" --ingroup "$GROUP" --uid "$UID" "$USER" && \
    mkdir -p /etc/sudoers.d && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER && \
    echo "Set disable_coredump false" >> /etc/sudo.conf  # Work around crappy-ass bug in sudo

# My favorite command line tools
RUN apk update \
    && apk add --no-cache \
    bash zip wget curl vim less tree mc psmisc byobu tmux the_silver_searcher sudo py3-pip mc ncdu

# Set default timezone & link python
RUN ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    ln -s /usr/bin/python3 /usr/bin/python

WORKDIR $HOME

COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

# Script to do container startup stuff. CMD gets exec'd at the end of the script.
ENTRYPOINT ["./.entrypoint.sh"]
CMD ["/bin/bash"]
