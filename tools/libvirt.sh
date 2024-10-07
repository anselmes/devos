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
DIR="$(dirname $(realpath $(dirname $0)))"
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
    --install)
      INSTALL=true
      shift
      ;;
    --create)
      CREATE=true
      shift
      ;;
    --configure)
      CONFIGURE=true
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

if [[ ${CLEANUP} == true ]]; then
  # todo: cleanup
  echo "cleaning up!!!"
fi

# install vbmc
if [[ ${INSTALL} == true ]]; then
  pip install virtualbmc
fi

virsh list --all
vbmc list

if [[ ${CREATE} == true ]]; then
  # todo: create vm
  echo "creating vm!!!"
fi

if [[ ${CONFIG} == true ]]; then
  # todo: configure vbmc
  echo "configuring vbmc!!!"
fi
