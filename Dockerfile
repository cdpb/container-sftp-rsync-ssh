FROM debian:stable-slim

# packages
RUN apt-get update && \
    apt-get install -y rsync openssh-server

# permissions
RUN groupadd -r sftponlygrp && \
    groupadd -r sshonlygrp

# sshd
COPY config/ssh_custom.conf /etc/ssh/sshd_config.d/
RUN mkdir -p /run/sshd

# entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 22
CMD ["/usr/sbin/sshd", "-De"]

