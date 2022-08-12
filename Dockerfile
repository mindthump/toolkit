# Some basic tools and a non-root user ("morty") with a home and paswordless sudo.
# It is not tiny like the basic alpine image, but it's not massive either.
# Modify TOOLS section, entrypoint.sh, requirements.txt, .coderfile and .config/* as desired.
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

# TOOLS help me explore the system and make the terminal nicer and easier to use (IMO).
RUN apk update && \
    apk add --no-cache \
    bash zip wget vim less psmisc sudo py3-pip \
    tree mc the_silver_searcher ncdu byobu tmux \
    fzf fd

# Set default timezone (alter as needed) & make python3 the default
RUN ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    ln -s /usr/bin/python3 /usr/bin/python

WORKDIR $HOME

COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

# Script to do container startup stuff. CMD gets exec'd at the end of the script.
ENTRYPOINT ["./entrypoint.sh"]
CMD ["/bin/bash"]
