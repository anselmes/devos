#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

set -eo pipefail

# Check Dependencies
commands=()

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
"""
fi

if [[ ${CLEANUP} == true ]]; then
  echo "Cleaning up ${NAME}"
  exit 0
fi
