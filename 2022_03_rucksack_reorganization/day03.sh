#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Remarks
# For me, the most difficult thing was how to map categories to priorities
# (a..z => 1..26 and A..Z => 27..52) as efficient as possible
# without subshells, eval, awk, perl or conditional arithmetic.
# I decided to use a loop for populating an associative array.

cat=({a..z})
declare -A prio_by_cat=()
for i in ${!cat[*]}; do
  prio_by_cat[${cat[i]}]=$((i + 1))
  prio_by_cat[${cat[i]^^}]=$((i + 27))
done

# Part 1
sum=0
while read -r r; do
  c1="${r:0:${#r}/2}" # compartment 1 is substring 0..len(r)/2
  c2="${r:${#r}/2}"   # compartment 2 is substring len(r)/2 till end

  # use regex for the sake of simplicity to print only ("grep -o") common chars
  # "grep -o ." matches each char, effectively splitting into lines of 1 char
  comm="$(echo "$c1" | grep -Eo "[$c2]" | grep -Eo . | sort | uniq)"

  # finally, add up the priorities of unique common categories found
  for c in $comm; do
    sum=$((sum + ${prio_by_cat[$c]}))
  done
done <input.txt
echo $sum

# Part 2
# In my opinion, the exercise is written way to complicated.
# Essentially, we want to split the input into groups of 3 and find the single
# category, which appears in all 3 lines.
#
# Hence, we adapt the loop to read 3 lines at a time.
# (I shamelessly stole the idea from: https://stackoverflow.com/a/41268405)
# And for comparison, we don't split the rucksack into 2 compartments.
# Instead where look for the commonality in 3 rucksacks (one more "grep").

sum=0
# read 3 lines at a time (without newline '-t') and proceed
# "till there are lines to read (number of array elements return something)"
while mapfile -t -n 3 r && ((${#r[@]})); do
  r0="${r[0]}"
  r1="${r[1]}"
  r2="${r[2]}"

  comm="$(echo "$r0" | grep -Eo "[$r1]" | grep -Eo "[$r2]" | grep -Eo . | sort | uniq)"

  for c in $comm; do
    sum=$((sum + ${prio_by_cat[$c]}))
  done
done <input.txt
echo $sum
