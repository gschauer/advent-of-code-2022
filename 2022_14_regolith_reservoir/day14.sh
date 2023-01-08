#!/usr/bin/env bash
set -euo pipefail

# Remarks
# First, I tried to tokenize the lines using solely Bash features.
# This should be possible, but would lead to code, which is hard to read.
# Instead, I tokenized the code using "grep -o".
# Unfortunately, neither read nor mapfile support limiting the number of fields.
# I could have split the string, store it in an array and loop over it.
# However, grep is performant enough to deal with just 174 lines.
#
# Part 2 was quite easy. Although, it shows that performance really matters.
# It was necessary to fill the room with 30k units of sand, which takes 30 sec.

declare -a room=()

declare -i y_max=0
while read -r l; do
  IFS=", " read -r x1 y1 _ <<<"$l"
  while IFS=, read -r x2 y2; do
    for ((y = (y1 < y2 ? y1 : y2); y <= (y1 > y2 ? y1 : y2); y++)); do
      for ((x = (x1 < x2 ? x1 : x2); x <= (x1 > x2 ? x1 : x2); x++)); do
        room[((y * 1000 + x))]="#"
        [[ $y_max -ge $y ]] || y_max="$y" # Part 2
      done
    done
    x1="$x2"
    y1="$y2"
  done <<<"$(grep -Eo "[0-9]+,[0-9]+" <<<"$l")"
done <"${1:-input.txt}"

# Part 2
for x in {0..999}; do
  room[(((y_max + 2) * 1000 + x))]="#"
done

declare -i cnt=1
while true; do
  declare -i x=500 y=0
  while [[ $y -lt 200 ]]; do
    if [[ "${room[(((y + 1) * 1000 + x))]:-}" == "" ]]; then
      ((y++)) || :
    elif [[ "${room[(((y + 1) * 1000 + (x - 1)))]:-}" == "" ]]; then
      ((y++, x--)) || :
    elif [[ "${room[(((y + 1) * 1000 + (x + 1)))]:-}" == "" ]]; then
      ((y++, x++)) || :
    else
      break
    fi
  done
  [[ "$y" -lt 200 && $y -ne 0 ]] || break # Part 1
  ((cnt++)) || :
  room[((y * 1000 + x))]="o"
  [[ $y -ne 0 ]] || break # Part 2
done
echo "Sand: $cnt"
