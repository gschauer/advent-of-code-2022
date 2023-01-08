#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Remarks
# I knew that subshells are slow, but I did not know that they are that slow.
# 2500 times 'var=$(printf "%d" "'$n")' takes approx. 1.1 seconds
# 2500 times 'printf -v var "%d" "'$n"' takes approx. 0.025 seconds

# Part 1
# I wanted to use pure arithmetic expressions (modulo) to calculate the score.
# This turned out to be more difficult without tests because
# '(a-b)%m == -1' if b>a, which could lead to wrong results
# In this exercise, we often want 1..3 instead of 0..2 or -1..1.
# Hence, it is necessary to take the absolute value and/or add an offset and use
# '(a-b+x)%m' OR '(a-b)%m+y' or even '(a-b+x)%m+y'.
sum=0
while read -r op my; do
  printf -v op "%d" "'$op"       # convert A..C to 65..67
  printf -v my "%d" "'$my"       # convert X..Z to 88..90
  my=$((my - 23))                # "normalize" 88..90 to 65..67

  shape=$(((my + 1) % 3 + 1))    # A=1P,B=2P... => solve eq: (65+x)%3==1
  res=$(((my - op + 4) % 3 * 3)) # solve eq: (my-op)%3==1: 6P, (my-op)%3==2: 0P
  sum=$((sum + shape + res))
done <input.txt
echo $sum

# Part 2
# Once part 1 is correct, is is fairly simple to get to this.
# Additionally, we need to solve 'my=f(op, end)' where 'end' is {X,Y,Z}.
sum=0
while read -r op my; do
  printf -v op "%d" "'$op"       # convert A..C to 65..67
  printf -v my "%d" "'$my"       # convert X..Z to 88..90
  my=$((my - 23))                # "normalize" 88..90 to 65..67

  my=$((op + (my % 3)))          # solve eq: (65+x)%3==-1, op+result (-1/0/1)

  shape=$(((my + 1) % 3 + 1))    # A=1P,B=2P... => solve eq: (65+x)%3==1
  res=$(((my - op + 4) % 3 * 3)) # solve eq: (my-op)%3==1: 6P, (my-op)%3==2: 0P
  sum=$((sum + shape + res))
done <input.txt
echo $sum

[[ "${BASH_VERSINFO[0]:-}" -ge 4 ]] || exit 1

# Bonus 1
# This implementation makes use of associative arrays - a feature from Bash 4.
# We map shape to points {X,Y,Z} => {1,2,3}
# and results to points {AX,...,CZ} => {0,3,6}.
# The total score is the sum of those points for each game.
declare -A S2P=([X]=1 [Y]=2 [Z]=3)
declare -A R2P=([AX]=3 [AY]=6 [AZ]=0 [BX]=0 [BY]=3 [BZ]=6 [CX]=6 [CY]=0 [CZ]=3)
sum=0
while read -r op my; do
  points=${R2P[${op}${my}]}
  sum=$((sum + ${S2P[$my]} + points))
done <input.txt
echo $sum

# Bonus 2
# Like in part 2, we just need to change the mapping as follows:
# First, we map the results to our target shape {AX,...,CZ} => {A,B,C}.
# Then, we map our shape to points {A,B,C} => {1,2,3}
# and the outcome to points {X,Y,Z} => {0,3,6}.
# The total score is the sum of those points for each game.
declare -A S2P=([A]=1 [B]=2 [C]=3 [X]=0 [Y]=3 [Z]=6)
declare -A R2P=([AX]=C [AY]=A [AZ]=B [BX]=A [BY]=B [BZ]=C [CX]=B [CY]=C [CZ]=A)
sum=0
while read -r op my; do
  shape=${R2P[${op}${my}]}
  sum=$((sum + ${S2P[$my]} + ${S2P[$shape]}))
done <input.txt
echo $sum
