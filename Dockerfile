FROM ubuntu:26.04
COPY provision.sh tmux.conf /tmp/
RUN chmod +x /tmp/provision.sh && /tmp/provision.sh && rm -f /tmp/provision.sh
USER morty
WORKDIR /home/morty
ENTRYPOINT ["/usr/bin/tini", "--", "./.entrypoint.sh"]
CMD ["/bin/zsh"]
