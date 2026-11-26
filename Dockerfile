FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV container=docker

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        systemd \
        systemd-sysv \
        dbus \
        openssh-server \
        python3 \
        python3-venv \
        python3-pip \
        sudo \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create deployment user and directories
RUN useradd -m -s /bin/bash deploy && \
    mkdir -p /opt/lab10 && \
    chown deploy:deploy /opt/lab10 && \
    install -d -m 700 \
        -o deploy -g deploy /home/deploy/.ssh

# Configure SSH authentication
RUN printf '%s\n' \
    'PermitRootLogin no' \
    'PasswordAuthentication no' \
    'KbdInteractiveAuthentication no' \
    'PubkeyAuthentication yes' \
    'UsePAM yes' \
    'AllowUsers deploy' \
    > /etc/ssh/sshd_config.d/00-lab10.conf

# Disable automatic SSH startup before runtime setup
RUN systemctl disable ssh.service && \
    systemctl mask ssh.socket && \
    rm -f /etc/ssh/ssh_host_*_key \
          /etc/ssh/ssh_host_*_key.pub

RUN printf '%s\n' \
    'deploy ALL=(root) NOPASSWD: /usr/bin/systemctl restart lab10-flask.service' \
    > /etc/sudoers.d/lab10-deploy && \
    chmod 440 /etc/sudoers.d/lab10-deploy && \
    visudo -cf /etc/sudoers.d/lab10-deploy

# Install systemd service configuration
COPY deploy/lab10-flask.service \
    /etc/systemd/system/lab10-flask.service

EXPOSE 22 8080

STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init"]
