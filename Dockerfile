# Some basic tools and a non-root user ("morty") with a home and paswordless sudo.
# Modify $TOOLS, etc. as desired.
FROM alpine:latest

# Defaults for the non-root user
ARG UID=1000
ARG GID=$UID
ARG USER=morty
ARG GROUP=$USER
ARG USER_SHELL=/bin/bash
ARG HOME=/home/$USER

# Non-root login user with passwordless sudo
RUN addgroup --gid $GID $GROUP \
&& adduser --disabled-password --gecos "" --shell "$USER_SHELL" --home "$HOME" --ingroup "$GROUP" --uid "$UID" "$USER" \
&& mkdir -p /etc/sudoers.d \
&& echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
&& chmod 0440 /etc/sudoers.d/$USER

# TOOLS help me explore the system and make the terminal nicer and easier to use (IMO).
ENV TOOLS='bash zip curl wget neovim bat psmisc sudo tree mc the_silver_searcher ncdu tmux tini jq busybox-extras procps'
ENV NET_TOOLS='nmap iproute2 bind-tools net-tools iputils'

RUN apk update \
&& apk add --no-cache ${TOOLS} ${NET_TOOLS} \
&& ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

WORKDIR $HOME

COPY . .
RUN chown -R "$UID:$GID" .

USER $USER

# Script to do container startup stuff. CMD gets exec'd at the end of the script.
ENTRYPOINT ["tini", "--", "./.entrypoint.sh"]
CMD ["/usr/bin/tmux"]
