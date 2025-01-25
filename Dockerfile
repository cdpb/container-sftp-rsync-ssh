FROM alpine:latest

# packages
RUN apk add --update-cache rsync openssh-server shadow

# permissions
RUN groupadd -r sshonlygrp

# sshd
COPY config/ssh_custom.conf /etc/ssh/sshd_config.d/

# entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 22
CMD ["/usr/sbin/sshd", "-De"]
