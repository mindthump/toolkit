FROM ubuntu:26.04
COPY provision.sh tmux.conf /tmp/
RUN chmod +x /tmp/provision.sh && /tmp/provision.sh && rm -f /tmp/provision.sh
COPY .entrypoint.sh /home/morty/.entrypoint.sh
RUN chmod +x /home/morty/.entrypoint.sh && chown morty:morty /home/morty/.entrypoint.sh
USER morty
WORKDIR /home/morty
ENTRYPOINT ["/usr/bin/tini", "--", "./.entrypoint.sh"]
CMD ["/bin/zsh"]
