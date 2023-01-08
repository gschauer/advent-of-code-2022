#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Remarks
# This solution contains a few "special" utilities like
#  - negated globe matching: "$1" != *[!0-9-]*
#  - read file without empty lines: awk 'NF' $file
#
# In part 2, I struggled quite a bit with performance.
# Since there's no optimized sort algorithm for semi-structured data,
# I implemented a naive sort using the cmp function (-1,0,+1).
# This does not work for larger data sets because 10000 comparisons would take
# approx. 10 seconds, excluding the invocation of jq in subshells!
# Since I'm not able to write a reasonable O(n*log(n)) algorithm for this kind
# of data, I decided to transform the strings into something sort can work with.
#
# By transforming the lists into sequences of zero-padded numbers, sort
# can be applied. This ensures that (almost) all packets are sorted correctly.
#
# THIS IMPLEMENTATION HAS ONE BUG WHEN IT COMES TO "AMBIGUOUS" PACKETS!
# There are certain edge cases where packets are not ordered correctly e.g.,
# [[[]]]
# [[]]
# After applying the transformation, this sequence would be
# 00000,
# 00000,
# Hence, the algorithm would not sort them according to the specification.
# Instead, it would be necessary to count the number of brackets e.g.,
# [[[1],[2]]]
# should be
# 0001,0002
# instead of
# 0001,02
#
# Anyhow, sorting it properly is an overkill for this exercise.
# We are just interested in the indexes of [2] and [6].
# There cannot be a [2,...], [[2,...], etc. which is smaller than [2].
# Hence, sorting the packets by their first value is sufficient to determine
# the indexes of [2] and [6].
# Nevertheless, I kept the previous code to demonstrate zero-padded sorting.

function is_list() {
  [[ "$1" == '['* ]]
}

function is_num() {
  # here it is necessary to use "inverse" globing, which means:
  # only if it does NOT contain anything that is NOT a number (or empty)
  [[ "$1" != *[!0-9-]* && "$1" != "" ]]
}

# Part 1
function cmp() {
  local -i i res
  local a=0 b=0

  [[ "$1" != "$2" ]] || { echo "0" && return; }

  if is_num "$1" && is_num "$2"; then
    echo $(($1 - $2)) && return 0
  elif is_list "$1" && is_list "$2"; then
    for ((i = 0; ; i++)); do
      (is_list "$a" || [[ "$a" -ge 0 ]]) || return
      a="$(jq -cr ".[$i] // -1" <<<"$1")"
      b="$(jq -cr ".[$i] // 99" <<<"$2")"
      if [[ "$a" == "-1" && "$b" == "99" ]]; then
        echo "0" && return
      elif [[ "$a" == "-1" ]]; then
        echo "-99" && return
      elif [[ "$b" == "99" ]]; then
        echo "99" && return
      fi
      res="$(cmp "$a" "$b")"
      if [[ "$res" != 0 || "$a" == "-1" || "$b" == "99" ]]; then
        echo "$res" && return
      fi
    done
  elif is_list "$1" && is_num "$2"; then
    cmp "$1" "[$2]" && return
  elif is_num "$1" && is_list "$2"; then
    cmp "[$1]" "$2" && return
  fi
  echo "0"
}

function check_signals() {
  local cnt=0 idx=0
  while mapfile -t -n 3 s && ((${#s[@]})); do
    ((idx++)) || :
    [[ "$(cmp "${s[0]}" "${s[1]}" | tail -n 1)" -gt 0 ]] || ((cnt += idx))
  done <"$1"
  echo "$cnt"
}

# Part 2
function decode() {
  mapfile -t ps <<<"$(awk 'NF' "$1")"
  ps+=("[[2]]" "[[6]]")
  sort_packets "${ps[@]}" |
    nl |                          # prefix lines with their index
    grep -E -m 2 '\t0000[26],$' | # take only "00002" and "00006"
    cut -f 1 |                    # keep only the indexes
    paste -sd "*" - | bc          # multiply them to get the key
}

function sort_packets() {
  # shellcheck disable=SC2086
  echo "$@" |
    tr ' ' $'\n' |  # make sure that there is one packet per line
    grep -Ev '^$' | # remove empty lines
    # next, perform several transformations:
    #  - remove all "]"
    #  - replace "[" with "0" (level of nesting)
    #  - append a "," to every line
    #  - prefix all numbers with "0000" (which could lead to too many zeroes)
    sed -E \
      -e 's/([0-9]+)/0000\1/g' \
      -e 's/\]//g' \
      -e 's/\[/0/g' \
      -e 's/$/,/' |
    sed -E -n -e 's/(0+,)|([0-9]*([0-9]{5},))/\1\3/gp' | # keep 5 digits each
    sort
}

# Main
[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  check_signals "${1:-input.txt}"
  decode "${1:-input.txt}"
}
