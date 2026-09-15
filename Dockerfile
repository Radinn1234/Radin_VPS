FROM debian:11

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd && \
    sed -i 's/^#\?Port .*/Port 7587/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 7587

CMD ["/usr/sbin/sshd", "-D", "-e"]
