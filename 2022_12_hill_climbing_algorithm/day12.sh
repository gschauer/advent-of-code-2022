#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Remarks
# Unfortunately, Bash does not support multi-dimensional arrays.
# Thus, this implementation makes use of one dimensional arrays in several ways:
# - map: array of strings, use substring ${map[$y]:$x:1}
# - dist: array of ints, compute index as follows: ${dist[((y * w + x))]}
# - paths: array of x/y-tuples as strings: p=${paths[0]}; x=${p%/*}; y=${p#*/}
#
#
# Important:
# When ‘+=’ is applied to an array variable using compound assignment
# (see https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Arrays),
# the variable’s value is not unset (as it is when using ‘=’),
# and new values are appended to the array beginning at
# > one greater than the array’s maximum index (for indexed arrays), ...
#
# In other words:
#     list=(0); list[8]=8; list+=($((1)))
#     for i in "${!list[@]}"; do
#       echo "idx $i = ${list[$i]}"
#     done
#     echo "len ${#list[@]}"
# prints
#     idx 0 = 0
#     idx 8 = 8
#     idx 9 = 1
#     len 3
#
#
# The key points in this exercise are to
# - set dist[next]=${dist[((current + 1))}] whenever dist[next] is greater
# - the runtime could be improved by keeping the set of visited nodes
#   (although, it does not matter to re-visit them because of the check above)
#
# For part 2, it is worth mentioning that paths can be explored simultaneously.
# Any valid path to a certain field, which becomes longer than another path,
# will terminate because dist[next] would become larger.

# Part 1
function find_way() {
  declare -a dist=()
  declare -a map=()

  load_map "$1"
  [[ $(type -t find_starts) != "function" ]] || find_starts "${2:-S}" # part 2

  while [[ -n "${#paths[@]}" && -n "${paths[0]:-}" ]]; do
    local p="${paths[0]}"
    local -i c_x="${p%/*}" c_y="${p#*/}"
    declare -a paths=("${paths[@]:1}")

    update_dist "$c_x" $((c_y - 1))
    update_dist "$c_x" $((c_y + 1))
    update_dist $((c_x - 1)) "$c_y"
    update_dist $((c_x + 1)) "$c_y"
  done

  local -i offset=$((e_y * w + e_x))
  echo "${dist[$offset]}"
}

function load_map() {
  while IFS=$'\n' read -r l; do
    map+=("$l")
  done <"$1"
  h="${#map[@]}" w="${#map[0]}"

  # the minimum distance to every field is bound by the number of fields
  # dist is pre-initialized with larger values in case fields are not reachable
  for ((i = 0; i < h * w; i++)); do
    dist+=($((h * w * 10)))
  done

  # find start, remember it and erase it from the map
  s_y="$(nl "$1" | grep -F "S" | cut -f 1)"
  s_x="$(sed "${s_y}q;d" "$1" | grep -Eo '.*S' | wc -c)"
  ((s_y--, s_x -= 2)) || :
  map[s_y]="${map[$s_y]/S/a}"

  # by definition, the trailhead has distance 0
  dist[((s_y * w + s_x))]=0
  paths=("$s_x/$s_y")

  # find end, remember it and erase it from the map
  e_y="$(nl "$1" | grep -F "E" | cut -f 1)"
  e_x="$(sed "${e_y}q;d" "$1" | grep -Eo '.*E' | wc -c)"
  ((e_y--, e_x -= 2)) || :
  map[e_y]="${map[$e_y]/E/z}"
}

function update_dist() {
  local -i n_x=$1 n_y=$2

  local -i c_h n_h
  c_h=$(get_height "$c_x" "$c_y")
  n_h=$(get_height "$n_x" "$n_y")

  # explore the next field if it is max. one level higher or even lower
  if ((c_h + 1 >= n_h)); then
    local -i c_offset=$((c_y * w + c_x))
    local -i n_offset=$((n_y * w + n_x))
    local -i c_dist=${dist[$c_offset]}

    # if found a shorter way to the next field, update our notes
    # then re-visit the path to update also the following fields
    if [[ $((c_dist + 1)) -lt "${dist[$n_offset]}" ]]; then
      dist[$n_offset]=$((c_dist + 1))
      paths+=("$n_x/$n_y")
    fi
  fi
}

function get_height() {
  if [[ $1 -lt 0 || $1 -ge $w || $2 -lt 0 || $2 -ge $h ]]; then
    # reached the end of the map - stop
    echo 255
  else
    printf '%d' "'${map[$2]:$1:1}"
  fi
}

# Part 2
function find_starts() {
  for ((y = 0; y < h; y++)); do
    for ((x = 0; x < w; x++)); do
      if [[ "${map[$y]:$x:1}" == "$1" ]]; then
        dist[((y * w + x))]=0
        paths+=("$x/$y")
      fi
    done
  done
}

# Main
[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  find_way "${1:-input.txt}" "${2:-a}"
}
