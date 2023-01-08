#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Remarks
# The trickiest change between part 1 and part 2 was adding "diagonal jumps".
# Is is possible that the distance between 2 segments becomes 2/2.
# In this case, both coordinates need to be updated.

visited=("0/0")
r_x=(0 0 0 0 0 0 0 0 0 0)
r_y=(0 0 0 0 0 0 0 0 0 0)

function move_rope() {
  while IFS=' ' read -r d l; do
    for ((s = 0; s < l; s++)); do
      move_head "$d"
    done
  done <"$1"

  echo -e "${visited[@]}" | tr ' ' $'\n' | sort | uniq | grep -c .
}

function move_head() {
  case "$1" in
  U) ((r_y[0]++)) || : ;;
  D) ((r_y[0]--)) || : ;;
  L) ((r_x[0]--)) || : ;;
  R) ((r_x[0]++)) || : ;;
  esac

  move_all
}

function move_all() {
  # move all additional rope segments r[i]..r[end]
  local -i end="$((${#r_x[@]} - 1))"
  for ((n = 1; n <= end; n++)); do
    move "$n"
  done

  # in most cases the tail does not move, so we can skip updating the list
  [[ ${visited[${#visited[@]} - 1]} == "${r_x[$end]}/${r_y[$end]}" ]] || {
    visited+=("${r_x[$end]}/${r_y[$end]}")
  }
}

function move() {
  # calculate the distance between r[i] and r[i-1]
  local -i n="$1"
  local -i y=$((r_y[n - 1] - r_y[n]))
  local -i x=$((r_x[n - 1] - r_x[n]))

  # |x| == 2 && |y| == 2 is a diagonal jump.
  # It happens if the rope repeatedly alternates in the same 2 directions.
  if [[ ${x#-} == 2 && ${y#-} == 2 ]]; then
    ((r_x[n] += x / 2, r_y[n] += y / 2)) || :
  elif [[ ${x#-} == 2 ]]; then
    ((r_x[n] += x / 2, r_y[n] = r_y[n - 1])) || :
  elif [[ ${y#-} == 2 ]]; then
    ((r_y[n] += y / 2, r_x[n] = r_x[n - 1])) || :
  fi
}

[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  move_rope "${1:-input.txt}"
}
