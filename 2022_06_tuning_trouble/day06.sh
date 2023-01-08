#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Remarks

# Part 1
function find_marker() {
  if [[ "$#" -eq 1 ]]; then
    sign=$(<"$1")
  else
    read -r sign
  fi

  for ((i = 4; i < ${#sign}; i++)); do
    if ! grep -q "\(.\).*\1" <<<"${sign:i-4:4}"; then
      echo "$i"
      return
    fi
  done
}

# Part 2
function find_marker() {
  pre="${1:-4}"
  if [[ "$#" -eq 2 ]]; then
    sign=$(<"$2")
  else
    read -r sign
  fi

  for ((i = pre; i < ${#sign}; i++)); do
    if ! grep -q "\(.\).*\1" <<<"${sign:i-pre:pre}"; then
      echo "$i"
      return
    fi
  done
}

# Main
[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  find_marker "${1:-14}" "${2:-input.txt}"
}
