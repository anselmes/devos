#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

set -eo pipefail

# Check Dependencies
commands=("multipass")

for command in "${commands[@]}"; do
  if [[ $(command -v "${command}" > /dev/null) ]]; then
    echo "${command} not found"
    exit 1
  fi
done

ARGS=${@}

DIR="$(dirname $(realpath $(dirname $0)))"
DEST="/home/ubuntu/cloudos"
NAME="devos"

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
    --mount)
      MOUNT=true
      shift
      ;;
    --config)
      [[ -z ${MOUNT} ]] && echo "Mount is required" && exit 1
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
  -d, --debug     Enable debug mode
  -V, --verbose   Enable verbose mode
  --name string   Name of the instance (default: devos)
  --sshkey string SSH Key to add to the instance (default: ~/.ssh/id_ed25519.pub)
  --mount         Mount directory to the instance
  --config        Configure the instance (requires --mount)
  --cleanup       Cleanup the instance
  -v, --version   Show version
  -h, --help      Show this help message
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
Name: ${NAME}
SSH Key: ${SSHKEY}
Mount: ${DIR}
ARGS: ${ARGS}
"""
fi

if [[ ${CLEANUP} == true ]]; then
  multipass delete --purge "${NAME}"
  exit 0
fi

if grep -q "${NAME}" <(multipass ls); then
  multipass info "${NAME}"
elif grep -q Running <(multipass info "${NAME}" --format yaml | yq ".\"${NAME}\"[].state"); then
  multipass start "${NAME}"
  multipass info "${NAME}"
else
  multipass launch lts -n "${NAME}" -c 4 -m 16g -d 64g
  multipass info "${NAME}"
fi

# Check if ssh key is added
if [[ ${SSHKEY} == true ]]; then
  multipass exec "${NAME}" -- bash -c "grep -q \"$(cat ${SSHKEY})\" ~/.ssh/authorized_keys" ||
    echo "$(cat ${SSHKEY})" | multipass exec "${NAME}" -- bash -c 'tee -a ~/.ssh/authorized_keys'
fi

# Check if directory is mounted
if [[ ${MOUNT} == true ]]; then
  grep -q "${DEST}" <(multipass info ${NAME} --format yaml | yq ".\"${NAME}\"[].mounts") ||
    multipass mount "${DIR}" "${NAME}:${DEST}"
fi

# Configure devos
if [[ ${CONFIG} == true ]]; then
  multipass exec "${NAME}" -- sudo "${DEST}/scripts/init-devos.sh"
  multipass exec "${NAME}" -- "${DEST}/scripts/config-devos.sh"
  multipass exec "${NAME}" -- bash -c 'eval $(ssh-agent -s) && ssh-add -l || true'
  multipass exec "${NAME}" -- gpg -k
fi
