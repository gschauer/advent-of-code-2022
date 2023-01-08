#!/usr/bin/env bash
set -euo pipefail

# Remarks
# Part 1 was quite simple by "marking" all moved numbers with a "_" suffix.
#
# Part 2 was more challenging, since I didn't plan to mix the numbers 10 times.
# So I decided to go for a naive approach and append the indexes to the values.
# This was almost correct, except I didn't consider index overflows.
# So I had to recalculate the target position as follows:
# pos=$(((pos % (len - 1) + (len - 1)) % (len - 1)))
#
# Please note that this implementation is terribly slow.
# For example, one array allocation like
# seq=("${seq[@]:0:$from}" "${seq[@]:$from+1}")
# takes approx. 0.005 seconds and I used 2 of them for every move.
# Repeating this for 5000 values takes 50 seconds.
# Besides that, there are a couple of other operations, which add up to 2 min.
# Finally, repeating this for 10 rounds...
#
# Future Ideas:
# Using only 1 array allocation per move should lead to a ~25 % improvement.
# Other than that, change the implementation to move indexes instead of values.
# In other words, initialize an array as follows: seq=(0 1 2 3 ... 4999)
# Additionally, store the input in an (immutable) array "values".
# Then move mix seq my moving each index $idx by an offset of ${values[$idx]}.
# Finally, calculate the result as ${values[${seq[1000]}]} + ...

function move() {
  if [[ $2 -eq 0 ]]; then
    seq[$1]="0_"
    return
  fi
  local -i from="$1" to="$(($1 + $2))"
  [[ $to -gt 0 ]] || ((to %= ${#seq[@]} - 1, to += ${#seq[@]} - 1)) || :
  [[ $to -lt ${#seq[@]} ]] || ((to %= ${#seq[@]} - 1)) || :
  local e="${seq[$from]}"
  seq=("${seq[@]:0:$from}" "${seq[@]:$from+1}")
  seq=("${seq[@]:0:$to}" "${e}_" "${seq[@]:$to}")
}

function decrypt() {
  for ((i = 0; i < ${#seq[@]}; i++)); do
    [[ ${seq[i]} != *_ ]] || continue
    move "$i" ${seq[i]}
    ((i -= 1)) || :
  done
  local -i a=${seq[1000]%_} b=${seq[2000]%_} c=${seq[3000]%_}
  echo "$a+$b+$c=$((a + b + c))"
}

# Part 2

function move2() {
  if [[ $2 == 0* ]]; then
    return
  fi
  local pos="${2%_*}"
  pos=$(((pos % (len - 1) + (len - 1)) % (len - 1)))

  local -i from="$1" to="$(($1 + pos))"
  [[ $to -gt 0 ]] || ((to %= ${#seq[@]} - 1, to += ${#seq[@]} - 1)) || :
  [[ $to -lt ${#seq[@]} ]] || ((to %= ${#seq[@]} - 1)) || :
  local e="${seq[$from]}"
  seq=("${seq[@]:0:$from}" "${seq[@]:$from+1}")
  seq=("${seq[@]:0:$to}" "${e}" "${seq[@]:$to}")
}

function decrypt2() {
  for ((i = 0; i < ${#seq[@]}; i++)); do
    seq[i]="$(("${seq[i]}" * 811589153))_$i"
  done

  for ((round = 0; round < 10; round++)); do
    for ((n = 0; n < len; n++)); do
      for ((i = 0; i < len; i++)); do
        [[ "${seq[i]}" == *_$n ]] || continue
        move2 "$i" "${seq[i]}" "$n"
        break
      done
    done
  done
  local -i a=${seq[((1000 % len))]%_*}
  local -i b=${seq[((2000 % len))]%_*}
  local -i c=${seq[((3000 % len))]%_*}
  echo "$a+$b+$c=$((a + b + c))"
}

# Main
[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  mapfile -t seq <"${1:-input.txt}"
  declare -i len="${#seq[@]}"
  decrypt2 "${1:-input.txt}"
}
