#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Remarks
# First, I thought the the CPU keeps ticking while addx is executed.
# Hence, I implemented a "ring buffer" of size 3 to store the values.
# By incrementing the cycles "correctly", this also leads to the result.
#
# Since part 2 added quite a bit of complexity with regards to index matching,
# I extracted the code for step progression to a function and did a cleanup.
#
# For the sake of simplicity, calc_sig_str uses a couple of global variables.
# Personally, I dislike it, because it could lead to accidental overrides.

# Part 1
function calc_sig_str() {
  x=1
  sig=0
  cyc=0

  while IFS=' ' read -r op v; do
    run "$op" "$v"
  done <"$1"

  echo "$sig"
  echo "$crt" | fold -w 40
}

function run() {
  if [[ "$1" == "noop" ]]; then
    next
  elif [[ "$1" == "addx" ]]; then
    next
    next
    ((x += "$2")) || :
  fi
}

function next() {
  ((cyc++)) || :
  [[ $(((cyc - 20) % 40)) -ne 0 ]] || ((sig += cyc * x))
  draw "$cyc" "$x"
}

# Part 2
crt=""

function draw() {
  local -i cyc=$1
  local -i x=$2

  offset=$((((cyc - 1) % 40) - x))
  if [[ "${offset#-}" -le 1 ]]; then
    crt+='#'
  else
    crt+=' '
  fi
}

# Main
[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  calc_sig_str "${1:-input.txt}"
}
