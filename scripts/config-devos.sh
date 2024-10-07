#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

set -euxo pipefail

DIR="$(dirname $(realpath $(dirname $0)))"

# check dependencies
commands=(
  "curl"
  "git"
  "gnupg2"
  "zsh"
)

sudo apt-get update -y
for command in "${commands[@]}"; do
  if [[ ! $(command -v "${command}") ]]; then
    sudo apt-get install -y "${command}"
  fi
done

# configure environment
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  curl -fsSLo /tmp/ohmyzsh-install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  bash /tmp/ohmyzsh-install.sh --unattended
  rm -f /tmp/ohmyzsh-install.sh
fi

sudo ln -sf "${DIR}/scripts/aliases.sh" /etc/profile.d/aliases.sh
sudo ln -sf "${DIR}/scripts/environment.sh" /etc/profile.d/environment.sh

ln -sf "${DIR}/config/bashrc" "${HOME}/.bashrc"
ln -sf "${DIR}/config/gitconfig" "${HOME}/.gitconfig"
ln -sf "${DIR}/config/sshconfig" "${HOME}/.ssh/config"
ln -sf "${DIR}/config/zshrc" "${HOME}/.zshrc"

zsh="$(command -v zsh)"
sudo chsh -s "${zsh}" "$(whoami)"
