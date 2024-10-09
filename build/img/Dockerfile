FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV X11VNC_SKIP_DISPLAY==""

COPY config/systemd/journal-to-tty.service /lib/systemd/system/journal-to-tty.service
RUN apt-get update -y && \
  apt-get install --no-install-recommends -y \
  ca-certificates \
  cron \
  curl \
  dbus \
  file \
  iproute2 \
  libvirt-daemon \
  libvirt-daemon-system \
  openssl \
  software-properties-common \
  ssh \
  systemd && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# todo: checksum downloaded binaries
COPY scripts/init-devos.sh /tmp/init-devos.sh
COPY scripts/install-docker.sh /tmp/install-docker.sh
RUN chmod +x \
  /tmp/init-devos.sh \
  /tmp/install-docker.sh && \
  /tmp/init-devos.sh && \
  echo "devos ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/devos && \
  systemctl enable journal-to-tty.service && \
  useradd -m devos

CMD ["/sbin/init"]
USER devos
HEALTHCHECK NONE
