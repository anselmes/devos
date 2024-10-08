#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

set -euxo pipefail

: "${ARCH:=$(dpkg --print-architecture)}"

: "${CARGO_HOME:=/usr/local/rust/cargo}"
: "${GOPATH:=/usr/local/go}"
: "${KREW_ROOT:=/usr/local/krew}"
: "${RUSTUP_HOME:=/usr/local/rust/rustup}"

: "${BUF_VERSION:=1.36.0}"
: "${CFSSL_VERSION:=1.6.5}"
: "${CILIUM_VERSION:=0.16.18}"
: "${CLOUDFLARED_VERSION:=2024.9.1}"
: "${CLUSTERCTL_VERSION:=1.8.3}"
: "${COSIGN_VERSION:=2.4.0}"
: "${GH_VERSION:=2.57.0}"
: "${JQ_VERSION:=1.7.1}"
: "${K0SCTL_VERSION:=0.19.0}"
: "${KIND_VERSION:=0.24.0}"
: "${KUBECTL_VERSION:=v1.31.1}"
: "${OP_VERSION:=2.30.0}"
: "${SBCTL_VERSION:=0.15.4}"
: "${SOPS_VERSION:=3.9.0}"
: "${TRIVY_VERSION:=0.55.2}"
: "${VAULT_VERSION:=1.17.6}"
: "${YQ_VERSION:=4.44.3}"

DIR="$(dirname $(realpath $(dirname $0)))"

apt-get update
apt-get install -y sudo unzip zip

mkdir -p \
  "${CARGO_HOME}" \
  "${GOPATH}" \
  "${KREW_ROOT}" \
  "${RUSTUP_HOME}"

# fixme: make optional via envvar
# install docker
[[ -z $(command -v docker) ]] && "${DIR}/scripts/install-docker.sh"

# fixme: make optional via envvar
# # install rust
# [[ -z $(command -v rustc) ]] && {
#   curl -fsSLo /tmp/rustup-init.sh https://sh.rustup.rs
#   RUSTUP_HOME="${RUSTUP_HOME}" CARGO_HOME="${CARGO_HOME}" sh /tmp/rustup-init.sh -y
# }

# todo: make golang optional via envvar
# todo: make node optional via envvar

# install yq
[[ -z $(command -v yq) ]] && {
  curl -fsSLo /tmp/yq "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH}"
  install /tmp/yq /usr/local/bin/
}

# install jq
[[ -z $(command -v jq) ]] && {
  curl -fsSLo /tmp/jq "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-arm64"
  install /tmp/jq /usr/local/bin/
}

# install buf
[[ -z $(command -v buf) ]] && {
  curl -fsSLo /tmp/buf "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-$(uname -s)-$(uname -m)"
  install /tmp/buf /usr/local/bin/
}

# install cfssl
[[ -z $(command -v cfssl) ]] && {
  curl -fsSLo /tmp/cfssl "https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/cfssl_${CFSSL_VERSION}_linux_${ARCH}"
  install /tmp/cfssl /usr/local/bin/
}

# install cilium cli
[[ -z $(command -v cilium) ]] && {
  curl -fsSLo /tmp/cilium.tar.gz "https://github.com/cilium/cilium-cli/releases/download/v${CILIUM_VERSION}/cilium-linux-${ARCH}.tar.gz"
  tar -xvf /tmp/cilium.tar.gz -C /tmp/
  install /tmp/cilium /usr/local/bin/
}

# fixme: make optional via envvar
# install cloudflared
# [[ -z $(command -v cloudflared) ]] && {
#   curl -fsSLo /tmp/cloudflared "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${ARCH}"
#   install /tmp/cloudflared /usr/local/bin/
# }

# install clusterctl
[[ -z $(command -v clusterctl) ]] && {
  curl -fsSLo /tmp/clusterctl "https://github.com/kubernetes-sigs/cluster-api/releases/download/v${CLUSTERCTL_VERSION}/clusterctl-linux-${ARCH}"
  install /tmp/clusterctl /usr/local/bin/
}

# install cosign
[[ -z $(command -v cosign) ]] && {
  curl -fsSLo /tmp/cosign "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-${ARCH}"
  install /tmp/cosign /usr/local/bin/
}

# install github cli
[[ -z $(command -v gh) ]] && {
  curl -fsSLo /tmp/gh.tar.gz "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${ARCH}.tar.gz"
  tar -xvf /tmp/gh.tar.gz -C /tmp/
  install "/tmp/gh_${GH_VERSION}_linux_${ARCH}/bin/gh" /usr/local/bin/
}

# install k0sctl
[[ -z $(command -v k0sctl) ]] && {
  curl -fsSLo /tmp/k0sctl "https://github.com/k0sproject/k0sctl/releases/download/v${K0SCTL_VERSION}/k0sctl-linux-${ARCH}"
  install /tmp/k0sctl /usr/local/bin/
}

# install kind
[[ -z $(command -v kind) ]] && {
  curl -fsSLo /tmp/kind "https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-${ARCH}"
  install /tmp/kind /usr/local/bin/
}

# install kubectl
[[ -z $(command -v kubectl) ]] && {
  curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
  install /tmp/kubectl /usr/local/bin/
}

# install 1password cli
[[ -z $(command -v op) ]] && {
  curl -fsSLo /tmp/op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_${ARCH}_v${OP_VERSION}.zip"
  unzip -d /tmp/op /tmp/op.zip
  install /tmp/op/op /usr/local/bin/
  groupadd -f onepassword-cli
  chgrp onepassword-cli /usr/local/bin/op
  chmod g+s /usr/local/bin/op
}

# install sbctl
[[ -z $(command -v sbctl) ]] && {
  curl -fsSLo /tmp/sbctl.tar.gz "https://github.com/Foxboron/sbctl/releases/download/${SBCTL_VERSION}/sbctl-${SBCTL_VERSION}-linux-${ARCH}.tar.gz"
  tar -xvf /tmp/sbctl.tar.gz -C /tmp/
  install /tmp/sbctl/sbctl /usr/local/bin/
}

# install sops
[[ -z $(command -v sops) ]] && {
  curl -fsSLo /tmp/sops "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${ARCH}"
  install /tmp/sops /usr/local/bin/
}

# install trivy
[[ -z $(command -v trivy) ]] && {
  curl -fsSLo /tmp/trivy.tar.gz "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-ARM64.tar.gz"
  tar -xvf /tmp/trivy.tar.gz -C /tmp/
  install /tmp/trivy /usr/local/bin/
}

# install vault
[[ -z $(command -v vault) ]] && {
  curl -fsSLo /tmp/vault.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${ARCH}.zip"
  unzip -d /tmp/vault /tmp/vault.zip
  install /tmp/vault/vault /usr/local/bin/
}

# install flux
[[ -z $(command -v flux) ]] && {
  curl -fsSLo /tmp/flux-install.sh https://fluxcd.io/install.sh
  bash /tmp/flux-install.sh
}

# install helm
[[ -z $(command -v helm) ]] && {
  curl -fsSLo /tmp/get-helm-3.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  bash /tmp/get-helm-3.sh
}

# install krew
[[ -z $(command -v krew) ]] && {
  curl -fsSLo /tmp/krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_${ARCH}.tar.gz"
  tar -xvf /tmp/krew.tar.gz -C /tmp/
  KREW_ROOT="${KREW_ROOT}" /tmp/krew-linux_"${ARCH}" install krew
}

# install trunk.io
[[ -z $(command -v trunk) ]] && {
  curl -fsSLo /tmp/trunk.sh https://get.trunk.io
  chmod 755 /tmp/trunk.sh
  /tmp/trunk.sh
  chmod 755 "$(command -v trunk)"
}

# post
groups=(
  "docker"
  "libvirt"
  "plugdev"
  "sudo"
)
for g in "${groups[@]}"; do
  usermod -aG "${g}" "$(whoami)" || true
done

plugins=(
  "ca-cert"
  "cert-manager"
  "ctx"
  "gopass"
  "hns"
  "images"
  "konfig"
  "minio"
  "node-shell"
  "ns"
  "oidc-login"
  "open-svc"
  "openebs"
  "operator"
  "outdated"
  "rabbitmq"
  "rook-ceph"
  "starboard"
  "view-secret"
  "view-serviceaccount-kubeconfig"
  "view-utilization"
)
for p in "${plugins[@]}"; do
  KREW_ROOT="${KREW_ROOT}" /usr/local/krew/bin/kubectl-krew install "${p}"
done

chsh -s "$(command -v zsh)" root || true
chsh -s "$(command -v zsh)" "$(whoami)" && echo "$(whoami) ALL=(ALL) NOPASSWD: ALL >/etc/sudoers.d/$(whoami)"

chmod -R 777 \
  "${CARGO_HOME}" \
  "${GOPATH}" \
  "${KREW_ROOT}" \
  "${RUSTUP_HOME}"

# cleanup
rm -rf /tmp/*
