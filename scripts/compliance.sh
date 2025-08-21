#!/usr/bin/env bash

# SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>
# SPDX-License-Identifier: Apache-2.0

# Code Quality & Compliance Check Script
# Uses mega-linter, reuse-tool and conform to check various linting, licenses, and commit compliance.
# Dependent on Docker or Podman

set -euo pipefail

EXITCODES=()
SUCCESS_MESSAGES=()

# Colors and symbols
readonly RED=$'\e[31m'
readonly NC=$'\e[0m'
readonly GREEN=$'\e[32m'
readonly YELLOW=$'\e[0;33m'
readonly BLUE=$'\e[34m'
readonly BOLD=$'\e[1m'
readonly CHECKMARK=$'\xE2\x9C\x94'
readonly MISSING=$'\xE2\x9D\x8C'
readonly TIME_FORMAT="%Y-%m-%d %H:%M:%S"

# Print a colored section header with timestamp
print_header() {
  local header="$1"
  local now
  now=$(date +"$TIME_FORMAT")
  printf '\n%b[%s] ====== %s ======%b\n' "$BLUE" "$now" "$header" "$NC"
}

# Print script banner
print_banner() {
  local msg="$1"
  local now
  now=$(date +"$TIME_FORMAT")
  printf '\n%b[%s] %s%b\n' "$BOLD$YELLOW" "$now" "$msg" "$NC"
}

# Store exit code and message, for summary table
store_exit_code() {
  local status="$1"
  local check_name="$2"
  local invalid_msg="$3"
  local valid_msg="$4"
  if [[ "$status" -ne 0 ]]; then
    EXITCODES+=("$check_name")
    SUMMARY_TABLE+=("$check_name|FAIL|$invalid_msg")
  else
    SUCCESS_MESSAGES+=("$check_name")
    SUMMARY_TABLE+=("$check_name|PASS|$valid_msg")
  fi
}

# Detect container engine (Docker or Podman) using Makefile targets
CONTAINER_ENGINE=""
detect_container_engine() {
  if [[ -n "$CONTAINER_ENGINE" ]]; then
    return
  fi
  if command -v docker >/dev/null 2>&1 && make check-docker | grep -q 'Docker is installed.'; then
    CONTAINER_ENGINE="docker"
  elif command -v podman >/dev/null 2>&1 && make check-podman | grep -q 'Podman is installed.'; then
    CONTAINER_ENGINE="podman"
  else
    print_banner "${RED}No supported container engine found (Docker/Podman required).${NC}"
    make
    exit 1
  fi
}

# Linting with MegaLinter
lint() {
  detect_container_engine
  export MEGALINTER_DEF_WORKSPACE='/repo'
  print_header 'LINTER HEALTH (MEGALINTER)'
  "$CONTAINER_ENGINE" run --rm --volume "$(pwd)":/repo \
    -e MEGALINTER_CONFIG='config/mega-linter.yml' \
    -e DEFAULT_WORKSPACE=${MEGALINTER_DEF_WORKSPACE} \
    -e LOG_LEVEL=INFO \
    ghcr.io/oxsecurity/megalinter-java:latest
  store_exit_code "$?" "Lint" "Lint check failed, see logs (std out and/or ./megalinter-reports) and fix problems." "Lint check passed."
  printf '\n'
}

# Lint publiccode.yml
publiccodelint() {
  detect_container_engine
  print_header 'LINTER publiccode.yml (publiccode.yml)'
  "$CONTAINER_ENGINE" run --rm -i italia/publiccode-parser-go -no-network /dev/stdin <publiccode.yml
  store_exit_code "$?" "publiccode.yml" "Lint of publiccode check failed, see logs and fix problems." "Lint check for publiccode.yml passed."
  printf '\n'
}

# License compliance with REUSE
license() {
  detect_container_engine
  print_header 'LICENSE HEALTH (REUSE)'
  "$CONTAINER_ENGINE" run --rm --volume "$(pwd)":/data docker.io/fsfe/reuse:4-debian lint
  store_exit_code "$?" "License" "License check failed, see logs and fix problems." "License check passed."
  printf '\n'
}

# Commit compliance with Conform
commit() {
  detect_container_engine
  local compareToBranch='main'
  local currentBranch
  currentBranch=$(git branch --show-current)
  print_header 'COMMIT HEALTH (CONFORM)'

  if [[ "$(git rev-list --count ${compareToBranch}..)" == 0 ]]; then
    printf "%s\n" "${YELLOW}No commits found in current branch: ${currentBranch}, compared to: ${compareToBranch}${NC}"
    store_exit_code 0 "Commit" "Commit check skipped, no new commits found in current branch: ${currentBranch}" "Commit check skipped, no new commits found."
  else
    "$CONTAINER_ENGINE" run --rm -i --volume "$(pwd)":/repo -w /repo ghcr.io/siderolabs/conform:latest enforce --base-branch="${compareToBranch}"
    store_exit_code "$?" "Commit" "Commit check failed, see logs (std out) and fix problems." "Commit check passed."
  fi
  printf '\n'
}

# Print summary of results as a table
check_exit_codes() {
  print_banner "CODE QUALITY & COMPLIANCE RUN SUMMARY"
  printf '\n%b| %-18s | %-6s | %-50s |%b\n' "$BOLD$BLUE" "Check" "Status" "Message" "$NC"
  printf '%b|--------------------|--------|----------------------------------------------------|%b\n' "$BLUE" "$NC"
  for row in "${SUMMARY_TABLE[@]}"; do
    IFS='|' read -r check status msg <<<"$row"
    # Color status only
    if [[ "$status" == "PASS" ]]; then
      status_disp="${GREEN}PASS ${CHECKMARK}${NC}"
    else
      status_disp="${RED}FAIL ${MISSING}${NC}"
    fi
    # Truncate/pad message for alignment
    msg_disp=$(printf '%-50.50s' "$msg")
    printf '| %-18s | %-13b | %-50s |
' "$check" "$status_disp" "$msg_disp"
  done
  printf '\n'
  if ((${#EXITCODES[@]} > 0)); then
    print_banner "${RED}Some checks failed. See above for details.${NC}"
    exit 1
  else
    print_banner "${GREEN}All checks passed!${NC}"
  fi
}

# Main execution: run all checks
main() {
  print_banner "Starting Code Quality & Compliance Checks"
  SUMMARY_TABLE=()
  lint
  publiccodelint
  license
  commit
  check_exit_codes
  print_banner "Compliance Script Completed"
}

main "$@"
