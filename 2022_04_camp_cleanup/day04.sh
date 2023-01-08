#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Remarks
# 'read' might be a Bash builtin, but executing 1000 times
# IFS="-" read -r r1l r1h <<<"$1"
# is approx. 0.03s slower than
# r1l="${1%-*}"; r1h="${1#*-}"
# This might not be a lot, but it seems that bash_unit does intercept read.
# $ time bash_unit -p overlap_input test.sh &>/dev/null
# real    0m4.618s
# # compared to
# real    0m0.096s
#
# This is clearly bash_unit specific, because
# IFS="-" echo "$1" | read -r r1l r1h
# is technically wrong, but adds only 2 seconds execution time, whereas
# IFS="-" read -r r1l r1h <<<"$1"
# adds 4 seconds.
#
# IFS="-" read -r r1l r1h < <(echo "$1")
# SOMETIMES causes an memory corruption like this:
#   Running test_subset_input ... bash(92892,0x10445c580) malloc: Incorrect checksum for freed object 0x14670ab00: probably modified after being freed.
#   Corrupt value: 0x2000000014670a01
#   bash(92892,0x10445c580) malloc: *** set a breakpoint in malloc_error_break to debug

# Part 1
# I wanted to keep the number of comparisons to a bare minimum.
# Hence, I started to sort both ranges, having the lower start first.
# However, I missed one edge case where r1l == r2l and r1h < r2h.
# In these cases, I did not swap the ranges and the check failed.
function is_subset() {
  # IFS="-" read -r r1l r1h <<<"$1"
  # IFS="-" read -r r2l r2h <<<"$2"
  local r1l="${1%-*}"
  local r1h="${1#*-}"
  local r2l="${2%-*}"
  local r2h="${2#*-}"

  # In order to skip the "symmetric" check later, the ranges are swapped so that
  # r1l < r2l (or r1l == r2l and r1h > r2h
  # In other words, the potentially (!) larger range comes first.
  if [[ $r1l -gt $r2l || ($r1l -eq $r2l && $r1h -lt $r2h) ]]; then
    ((r1l -= r2l, r2l += r1l, r1l = r2l - r1l))
    ((r1h -= r2h, r2h += r1h, r1h = r2h - r1h))
  fi

  [[ "$r1l" -le "$r2l" && "$r1h" -ge "$r2h" ]]
}

function count_subsets() {
  local sum=0
  while IFS=, read -r a a2; do
    ! is_subset "$a" "$a2" || ((sum += 1))
  done <"$1"
  echo "$sum"
}

# Part 2
# Here, the condition becomes trivial (r1h >= r2l) because ranges are sorted
# (r1l is guaranteed to be less than or equal to r2l).
function is_overlap() {
  # IFS="-" read -r r1l r1h <<<"$1"
  # IFS="-" read -r r2l r2h <<<"$2"
  local r1l="${1%-*}"
  local r1h="${1#*-}"
  local r2l="${2%-*}"
  local r2h="${2#*-}"

  # In order to skip the "symmetric" check later, the ranges are swapped so that
  # r1l < r2l (or r1l == r2l and r1h > r2h
  # In other words, the potentially (!) larger range comes first.
  if [[ $r1l -gt $r2l || ($r1l -eq $r2l && $r1h -lt $r2h) ]]; then
    ((r1l -= r2l, r2l += r1l, r1l = r2l - r1l))
    ((r1h -= r2h, r2h += r1h, r1h = r2h - r1h))
  fi

  [[ "$r1h" -ge "$r2l" ]]
}

function count_overlaps() {
  local sum=0
  while IFS=, read -r a1 a2; do
    ! is_overlap "$a1" "$a2" || ((sum += 1))
  done <"$1"
  echo "$sum"
}

[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  count_subsets "${1:-input.txt}"
  count_overlaps "${1:-input.txt}"
}
