#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Remarks
# I already wrote about "paste" in the DevOps guild blog:
# https://wiki.rbinternational.corp/confluence/display/RBIG/2021/08/02/Tool+of+the+Week%3A+paste
# Hence, I knew that it is ideal to build arithmetic expressions.
# The rest was just putting a couple of commands together.

# Part 1
paste -sd + input.txt |  # concatenate all lines, replace \n with +
  sed -E 's/\+\+/\n/g' | # ++ means there was an empty line => split
  bc |                   # evaluate the mathematical expressions
  sort -r |              # sort in descending order
  head -n 1              # the first one is the largest one

# Part 2
paste -sd + input.txt | sed -E 's/\+\+/\n/g' | bc | sort -r |
  head -n 3 |     # pick the top 3 instead
  paste -sd + - | # same story, except reading from stdin (note the '-')
  bc

# Bonus
# I use a sorted array of size N for the top N calories. This is more efficient.
# Especially when N is much smaller than the number of elves.
elves=(0 0 0) # initialized array for calories of top N elves
elf=0
while read -r l; do
  if [[ "$l" != "" ]]; then # still the same elf?
    ((elf += "$l"))
    continue
  elif [[ "$elf" -gt "${elves[0]}" ]]; then # current elf carries more calories
    elves[0]="$elf"                         # replaced Nth elf
    # shellcheck disable=SC2207
    IFS=$'\n' elves=($(sort <<<"${elves[*]}")) # re-sort known top N elves
  fi
  elf=0
done <input.txt

echo "${elves[*]}" | paste -sd '+' - | bc
# OR if you prefer tr over paste
# echo "${elves[@]}" | tr ' ' '+' | bc
