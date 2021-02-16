# Very small footprint with some basic tools installed, and a non-root user ("morty") with paswordless sudo.
FROM python:alpine

# Defaults for the non-root user; fix here or override with --build-arg during the image build
ARG UID=1000
ARG GID=$UID
ARG USER=morty
ARG GROUP=$USER
ARG USER_SHELL=/bin/bash
ARG HOME=/home/$USER

# Non-root login user
RUN addgroup --gid $GID $GROUP \
    && adduser \
    --disabled-password \
    --gecos "" \
    --shell "$USER_SHELL" \
    --home "$HOME" \
    --ingroup "$GROUP" \
    --uid "$UID" "$USER"

# Passwordless superuser
RUN mkdir -p /etc/sudoers.d \
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER \
    && echo "Set disable_coredump false" >> /etc/sudo.conf  # Work around crappy-ass bug in sudo

# Tools

# My favorite command line tools
RUN apk update \
    && apk add --no-cache \
    bash zip wget curl vim less tree mc psmisc byobu tmux the_silver_searcher sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $HOME

# Copy the build context directory to WORKDIR; use the .dockerignore file for exclusions (.git, Dockerfile, etc.).
COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

ENTRYPOINT ["./.entrypoint.sh"]
CMD ["/bin/bash"]
