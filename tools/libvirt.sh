#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

set -eo pipefail

# Check Dependencies
commands=(
  "pip"
  "python3"
)

for command in "${commands[@]}"; do
  if [[ $(command -v "${command}" > /dev/null) ]]; then
    echo "${command} not found"
    exit 1
  fi
done

ARGS=${@}

NAME="devos"
ARCH="arm64"
VERSION="noble"

DIR="$(dirname $(realpath $(dirname $0)))"
DEST="/var/lib/libvirt/images"

IMG="${DEST}/${VERSION}.img"
VOL="${DEST}/${NAME}.img"

# Parse Arguments
while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--debug)
      DEBUG=true
      shift
      ;;
    -V|--verbose)
      VERBOSE=true
      shift
      ;;
    --name)
      NAME="${2}"
      [[ -z ${NAME} ]] && echo "Name is required" && exit 1
      shift 2
      ;;
    --sshkey)
      SSHKEY="${2}"
      [[ -z ${SSHKEY} ]] && echo "SSH Key is required" && exit 1
      shift 2
      ;;
    --install)
      INSTALL=true
      shift
      ;;
    --create)
      CREATE=true
      shift
      ;;
    --config)
      CONFIG=true
      shift
      ;;
    --cleanup)
      CLEANUP=true
      shift
      ;;
    -v|--version)
      echo "${0} $(git describe --all)"
      exit 0
      ;;
    -h|--help)
      echo """
Usage: ${0} [options]
Options:
  -d, --debug   Enable debug mode
  -V, --verbose Enable verbose mode
  --name string Name of the instance (default: devos)
  --install     Install vbmc locally
  --create      Create the instance
  --configure   Configure vbmc
  --cleanup     Cleanup the instance
  -v, --version Show version
  -h, --help    Show this help message
"""
      exit 0
      ;;
    *)
      ARGS+=("${1}")
      echo "Unknown option: ${1}"
      exit 1
  esac
done

# Enable Debug Mode
if [[ ${DEBUG} == true ]]; then
  set -x
fi

# Enable Verbose Mode
if [[ ${VERBOSE} == true ]]; then
  echo """
ARGS: ${ARGS}
"""
fi

# cleanup
if [[ ${CLEANUP} == true ]]; then
  vbmc delete "${NAME}"
  virsh destroy "${NAME}" || true
  virsh undefine --nvram
  virsh undefine "${NAME}" || true
  rm -f "/tmp/${NAME}-cidata.iso"
  rm -f "/tmp/metadata"
  rm -f "/tmp/userdata"
  rm -f "${VOL}"
  virsh list --all
  vbmc list
fi

# install vbmc
if [[ ${INSTALL} == true ]]; then
  pip install virtualbmc
fi

# create vm
if [[ ${CREATE} == true ]]; then
  # download image
  if [[ ! -f "${IMG}" ]]; then
    curl -fsSLo "${IMG}" "http://cloud-images.ubuntu.com/${VERSION}/current/${VERSION}-server-cloudimg-${ARCH}.img"
    qemu-img info "${IMG}"
  fi

  # create volume
  if [[ ! -f "${VOL}" ]]; then
    qemu-img create -b "${IMG}" -f qcow2 -F qcow2 "${VOL}" 16G
    qemu-img info "${VOL}"
  fi

  # create metadata
  cat <<eof > /tmp/metadata
instance-id: ${NAME}
local-hostname: ${NAME}
eof

  # create userdata
  cat <<eof > /tmp/userdata
#cloud-config
users:
  - name: ${NAME}
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - "${SSHKEY:-$(cat ~/.ssh/id_ed25519.pub)}"
eof

  ISOCMD="genisoimage"
  if [[ -z $(command -v ${ISOCMD}) ]]; then
    ISOCMD="mkisofs"
    if [[ -z $(command -v ${ISOCMD}) ]]; then
      echo "genisoimage nor mkisofs found"
      exit 1
    fi
  fi
  ${ISOCMD} -output /tmp/${NAME}-cidata.iso -volid cidata -joliet -rock /tmp/userdata /tmp/metadata

  # check vm exists
  if [[ -z $(virsh list --all | grep "${NAME}") ]]; then
    virt-install \
      --name ${NAME} \
      --os-variant ubuntu20.04 \
      --memory 2048 \
      --network none \
      --vcpus 2 \
      --disk path=${VOL},format=qcow2 \
      --disk path=/tmp/${NAME}-cidata.iso,device=cdrom \
      --import \
      --noautoconsole
  fi
fi

# configure vbmc
if [[ ${CONFIG} == true ]]; then
  grep -q "${NAME}" <(vbmc list) || vbmc add "${NAME}"
fi

virsh list --all
vbmc list
