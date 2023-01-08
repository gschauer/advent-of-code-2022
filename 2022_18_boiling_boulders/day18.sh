#!/usr/bin/env bash

# Remarks
# Since Bash does not support complex data structures, I decided to use
# associative arrays with composite keys ($x,$y,$z).
# In this way, part 1 is pretty simple by enumerating the lava and counting
# all neighboring fields, which are not lava.
#
# Part 2 is a bit more complex. The most efficient algorithm depends on the
# shape of the lava droplets.
# In the worst case, the lava is kind a closed labyrinth.
# Then it would be necessary to do a lot of comparisons with surrounding fields.
# I decided to go for a brute force approach with O(k*n^3) where n is the
# length/width/height and k is the number of iterations to "fill" the array.
# Then, the surface can be determined similarly to part 1.
# Since lava ("L") can be on the edge (0), water ("W") must be placed at -1.

function calc_surface() {
  local l
  local -A lava

  while read -r l; do
    lava["$l"]="L"
  done <"$1"

  local -i x y z cnt=0
  for l in "${!lava[@]}"; do
    IFS=, read -r x y z <<<"$l"
    if [[ ${lava["$((x - 1)),$y,$z"]} != "L" ]]; then ((cnt++)) || :; fi
    if [[ ${lava["$((x + 1)),$y,$z"]} != "L" ]]; then ((cnt++)) || :; fi
    if [[ ${lava["$x,$((y - 1)),$z"]} != "L" ]]; then ((cnt++)) || :; fi
    if [[ ${lava["$x,$((y + 1)),$z"]} != "L" ]]; then ((cnt++)) || :; fi
    if [[ ${lava["$x,$y,$((z - 1))"]} != "L" ]]; then ((cnt++)) || :; fi
    if [[ ${lava["$x,$y,$((z + 1))"]} != "L" ]]; then ((cnt++)) || :; fi
  done
  echo "Surface: $cnt"

  # Part 2
  lava["0,0,0"]="W"
  local -i filled=0
  while [[ ${#lava[@]} -ne $filled ]]; do
    filled=${#lava[@]}
    for ((x = -1; x < 25; x++)); do
      for ((y = -1; y < 25; y++)); do
        for ((z = -1; z < 25; z++)); do
          if [[ -z ${lava["$x,$y,$z"]:-} ]]; then
            if [[ ${lava["$((x - 1)),$y,$z"]} == "W" ]]; then lava["$x,$y,$z"]="W"; fi
            if [[ ${lava["$((x + 1)),$y,$z"]} == "W" ]]; then lava["$x,$y,$z"]="W"; fi
            if [[ ${lava["$x,$((y - 1)),$z"]} == "W" ]]; then lava["$x,$y,$z"]="W"; fi
            if [[ ${lava["$x,$((y + 1)),$z"]} == "W" ]]; then lava["$x,$y,$z"]="W"; fi
            if [[ ${lava["$x,$y,$((z - 1))"]} == "W" ]]; then lava["$x,$y,$z"]="W"; fi
            if [[ ${lava["$x,$y,$((z + 1))"]} == "W" ]]; then lava["$x,$y,$z"]="W"; fi
          fi
        done
      done
    done
  done

  cnt=0
  for ((x = 0; x < 25; x++)); do
    for ((y = 0; y < 25; y++)); do
      for ((z = 0; z < 25; z++)); do
        if [[ ${lava["$x,$y,$z"]:-} == "L" ]]; then
          if [[ ${lava["$((x - 1)),$y,$z"]} == "W" ]]; then ((cnt++)) || :; fi
          if [[ ${lava["$((x + 1)),$y,$z"]} == "W" ]]; then ((cnt++)) || :; fi
          if [[ ${lava["$x,$((y - 1)),$z"]} == "W" ]]; then ((cnt++)) || :; fi
          if [[ ${lava["$x,$((y + 1)),$z"]} == "W" ]]; then ((cnt++)) || :; fi
          if [[ ${lava["$x,$y,$((z - 1))"]} == "W" ]]; then ((cnt++)) || :; fi
          if [[ ${lava["$x,$y,$((z + 1))"]} == "W" ]]; then ((cnt++)) || :; fi
        fi
      done
    done
  done
  echo "Outside: $cnt"
}

# Main
[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  calc_surface "${1:-input.txt}"
}
