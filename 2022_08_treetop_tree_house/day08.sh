#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Remarks
# Similar as on day 2, the performance was not great due to usage of subshells.
# My first attempt required several seconds to process 99 lines from the input.
# Never ever use subshells in loops! Strongly prefer Bash features instead.

function count_trees() {
  readarray -t trees <"$1"
  local -i cnt=0 max_view=0
  local -i h=${#trees}
  local -i w=${#trees[@]}
  ((h--, w--))

  for ((y = 0; y <= h; y++)); do
    for ((x = 0; x <= w; x++)); do
      # optimization for part 1
      # if [[ $x -eq 0 || $x -eq $w || $y -eq 0 || $y -eq $h ]]; then
      #   ((cnt++)) || :
      if view="$(is_visible "$x" "$y")"; then
        ((cnt++)) || :
      fi
      [[ $view -le $max_view ]] || max_view=$view
    done
  done

  echo "Trees: $cnt"
  echo "View:  $max_view"
}

function is_visible() {
  local -i x="$1" y="$2"
  local row="${trees[y]}"
  local t="${row:x:1}"
  local view=1

  local -i vis_l=0
  for ((i = x - 1; i >= 0; i--)); do
    if [[ "${row:i:1}" -ge $t ]]; then
      vis_l=1
      break
    fi
  done
  ((view *= (x - i - 1 + vis_l))) || :

  local -i vis_r=0
  for ((i = x + 1; i < ${#row}; i++)); do
    if [[ "${row:i:1}" -ge $t ]]; then
      vis_r=1
      break
    fi
  done
  ((view *= (i - x - 1 + vis_r))) || :

  local -i vis_t=0
  for ((i = y - 1; i >= 0; i--)); do
    row="${trees[i]}"
    if [[ ${row:x:1} -ge $t ]]; then
      vis_t=1
      break
    fi
  done
  ((view *= (y - i - 1 + vis_t))) || :

  local -i vis_b=0
  for ((i = y + 1; i < ${#trees[@]}; i++)); do
    row="${trees[i]}"
    if [[ ${row:x:1} -ge $t ]]; then
      vis_b=1
      break
    fi
  done
  ((view *= (i - y - 1 + vis_b))) || :

  echo "$view"
  return $((vis_l * vis_r * vis_t * vis_b))
}

[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  count_trees "${1:-input.txt}"
}
