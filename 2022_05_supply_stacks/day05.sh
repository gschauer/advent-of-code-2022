#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Remarks
# This exercise was pretty straightforward, in my opinion.
# The trickiest part was a bit of whitespace handling.
# Especially when reading/transposing the stacks.
# "cut -c $n" does a pretty nice job to read columns of text including spaces.
# "${str: -$n}" extracts the last n characters (note the space).

# Part 1
function move() {
  local c="${1: -$3}"
  echo "${1:0: -$3} $2$(rev <<<"$c")"
}

function transpose() {
  local inv="$1"
  local cnt="$2"
  local a i col

  # cut out every x-th column, remove all \n to squash them to a single line
  # then trim (leading) spaces and turn it "upside-down" (access from right)
  for ((i = 0; i <= "$cnt"; i++)); do
    col="$(cut -c "$((2 + 4 * i))" <<<"$inv")"
    stacks+=$(echo "${col}" | tr -d $'\n' | xargs | rev)$'\n'
  done
  echo "$stacks"
}

function read_stacks() {
  local inv=""

  # collect the inventory by reading up to the first empty line
  while IFS='' read -r l; do
    [[ -n "$l" ]] || break
    inv+="$l"$'\n'
  done <"$1"

  # determine the number of stacks by taking the last field from previous line
  local cnt
  cnt="$(tail -n 2 <<<"$inv")"
  cnt="${cnt##* }"

  # remove the line containing the stack numbers and transpose the inventory
  inv="${inv%$'\n'*$'\n'}"
  transpose "$inv" "$cnt"
}

function get_top() {
  # split line into multiple lines (can have different length)
  # then turn the stacks upside down to pick the "top" conveniently
  echo "$@" | tr ' ' $'\n' | rev | cut -c 1 | tr -d $'\n'
  echo
}

function move_stacks() {
  local stacks
  stacks="$(read_stacks "$1")"
  IFS=$'\n' readarray -t stacks <<<"$stacks"

  while read -r _ n _ a _ b; do
    ((a--, b--))
    crates="$(move "${stacks[$a]}" "${stacks[$b]}" "$n")"
    stacks[$a]="${crates% *}"
    stacks[$b]="${crates#* }"
  done <<<"$(grep -Eo "move .*" "$1")"
  echo "${stacks[@]}"
}

function reorg_stacks() {
  get_top "$(move_stacks "$1")"
}

# Part 2
function move() {
  local c="${1: -$3}"
  if [[ "${MOVE_MODE:-}" == "ALL" ]]; then
    echo "${1:0: -$3} $2$c"
  else
    echo "${1:0: -$3} $2$(rev <<<"$c")"
  fi
}

# Main
[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  reorg_stacks "${1:-input.txt}"
}
