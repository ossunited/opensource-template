#!/usr/bin/env bash

# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
#
# SPDX-License-Identifier: Apache-2.0

# Code Quality Check Script
# Uses mega-linter, reuse-tool and conform to check various linting, licenses, and commit compliance.
# Dependent on Docker

EXITCODES=()
SUCCESS_MESSAGES=()

readonly RED=$'\e[31m'
readonly NC=$'\e[0m'
readonly GREEN=$'\e[32m'
readonly YELLOW=$'\e[0;33m'

#Terminal chars
readonly CHECKMARK=$'\xE2\x9C\x94'
readonly MISSING=$'\xE2\x9D\x8C'

is_command_available() {
  local COMMAND="${1}"
  local INFO="${2}"

  if ! [ -x "$(command -v "${COMMAND}")" ]; then
    printf '%b Error:%b %s is not available in path/installed.\n' "${RED}" "${NC}" "${COMMAND}" >&2
    printf 'See %s for more info about the command.\n' "${INFO}" >&2
    exit 1
  fi
}

print_header() {
  local HEADER="$1"
  printf '%b\n************ %s ***********%b\n\n' "${YELLOW}" "$HEADER" "${NC}"
}

store_exit_code() {
  declare -i STATUS="$1"
  local INVALID_MESSAGE="$3"
  local VALID_MESSAGE="$4"

  if [[ "${STATUS}" -ne 0 ]]; then
    EXITCODES+=("${INVALID_MESSAGE}")
  else
    SUCCESS_MESSAGES+=("${VALID_MESSAGE}")
  fi
}

# Detect container engine (Docker or Podman)
CONTAINER_ENGINE=""
if command -v docker &>/dev/null; then
  CONTAINER_ENGINE="docker"
elif command -v podman &>/dev/null; then
  CONTAINER_ENGINE="podman"
else
  printf '%b Error:%b Neither Docker nor Podman is available in path/installed.\n' "${RED}" "${NC}" >&2
  printf 'See https://docs.docker.com/get-docker/ or https://podman.io/getting-started/ for more info.\n' >&2
  exit 1
fi

lint() {
  export MEGALINTER_DEF_WORKSPACE='/repo'
  print_header 'LINTER HEALTH (MEGALINTER)'
  "$CONTAINER_ENGINE" run --rm --volume "$(pwd)":/repo -e MEGALINTER_CONFIG='config/mega-linter.yml' -e DEFAULT_WORKSPACE=${MEGALINTER_DEF_WORKSPACE} -e LOG_LEVEL=INFO ghcr.io/oxsecurity/megalinter-java:latest
  store_exit_code "$?" "Lint" "${MISSING} ${RED}Lint check failed, see logs (std out and/or ./megalinter-reports) and fix problems.${NC}\n" "${GREEN}${CHECKMARK}${CHECKMARK} Lint check passed${NC}\n"
  printf '\n\n'
}

publiccodelint() {
  print_header 'LINTER publiccode.yml (publiccode.yml)'
  "$CONTAINER_ENGINE" run --rm -i italia/publiccode-parser-go -no-network /dev/stdin <publiccode.yml
  store_exit_code "$?" "publiccode" "${MISSING} ${RED}Lint of publiccode check failed, see logs and fix problems.${NC}\n" "${GREEN}${CHECKMARK}${CHECKMARK} Lint check for publiccode.yml passed${NC}\n"
  printf '\n\n'
}

license() {
  print_header 'LICENSE HEALTH (REUSE)'
  "$CONTAINER_ENGINE" run --rm --volume "$(pwd)":/data docker.io/fsfe/reuse:4-debian lint
  store_exit_code "$?" "License" "${MISSING} ${RED}License check failed, see logs and fix problems.${NC}\n" "${GREEN}${CHECKMARK}${CHECKMARK} License check passed${NC}\n"
  printf '\n\n'
}

commit() {
  local compareToBranch='main'
  local currentBranch
  currentBranch=$(git branch --show-current)
  # siderolabs/conform:v0.1.0-alpha.27
  print_header 'COMMIT HEALTH (CONFORM)'

  if [[ "$(git rev-list --count ${compareToBranch}..)" == 0 ]]; then
    printf "%s" "${GREEN} No commits found in current branch: ${YELLOW}${currentBranch}${NC}, compared to: ${YELLOW}${compareToBranch}${NC} ${NC}"
    store_exit_code "$?" "Commit" "${MISSING} ${RED}Commit check count failed, see logs (std out) and fix problems.${NC}\n" "${YELLOW}${CHECKMARK}${CHECKMARK} Commit check skipped, no new commits found in current branch: ${YELLOW}${currentBranch}${NC}\n"
  else
    "$CONTAINER_ENGINE" run --rm -i --volume "$(pwd)":/repo -w /repo ghcr.io/siderolabs/conform:latest enforce --base-branch="${compareToBranch}"
    store_exit_code "$?" "Commit" "${MISSING} ${RED}Commit check failed, see logs (std out) and fix problems.${NC}\n" "${GREEN}${CHECKMARK}${CHECKMARK} Commit check passed${NC}\n"
  fi

  printf '\n\n'
}

check_exit_codes() {
  printf '%b********* CODE QUALITY RUN SUMMARY ******%b\n\n' "${YELLOW}" "${NC}"

  for message in "${EXITCODES[@]}"; do
    printf '%b' "${message}"
  done
  printf "\n"

  for message in "${SUCCESS_MESSAGES[@]}"; do
    printf '%b' "${message}"
  done
  printf "\n"
}

lint
publiccodelint
license
commit

check_exit_codes
