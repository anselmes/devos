FROM ubuntu:24.10

ENV DEBIAN_FRONTEND=noninteractive
ENV X11VNC_SKIP_DISPLAY==""

RUN apt-get update -y && \
  apt-get install --no-install-recommends -y \
  ansible \
  ca-certificates \
  cron \
  curl \
  dbus \
  file \
  git \
  git-lfs \
  gnupg2 \
  icewm \
  iproute2 \
  libvirt-clients \
  libvirt-daemon \
  libvirt-daemon-system \
  openssl \
  protobuf-compiler \
  protobuf-compiler-grpc \
  python3-openstackclient \
  software-properties-common \
  ssh \
  systemd \
  unzip \
  vim \
  x11vnc \
  xauth \
  xinit \
  xterm \
  xvfb \
  zsh && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  echo "exec icewm" > ~/.xinitrc && chmod +x ~/.xinitrc

COPY config/systemd/x11vnc.service /lib/systemd/system/x11vnc.service
RUN systemctl enable x11vnc.service

COPY config/systemd/journal-to-tty.service /lib/systemd/system/journal-to-tty.service
RUN systemctl enable journal-to-tty.service

RUN useradd -m devos

# todo: checksum downloaded binaries
COPY scripts/init-devos.sh /tmp/init-devos.sh
COPY scripts/install-docker.sh /tmp/install-docker.sh
RUN chmod +x \
  /tmp/init-devos.sh \
  /tmp/install-docker.sh && /tmp/init-devos.sh

CMD ["/sbin/init"]
USER devos
HEALTHCHECK NONE
