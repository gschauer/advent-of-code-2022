#!/usr/bin/env bash
set -euo pipefail

# Remarks
# Part 1 was much simpler than I thought. I would have stored the lines in an
# associative array and iteratively evaluated all expressions.
# Instead, $(()) performs recursive expansion, which solves the expression.
#
# For part 2, I replaced "+" with "==" and tried to find humn as {0..10000}.
# It turned out that the number is significantly larger.
# Hence, I was forced to transform the equation and resolve all static branches.
# The tricky part was to leveraging the unbound humn variable, while preventing
# Bash from exiting. This was achieved with subshells e.g.,
# res_a="$(echo $((a)))" || res_a="???"
# and redirecting stderr to /dev/null.
# Despite that, the equation can be solved relatively fast in 0.6s.

: "${DEBUG:=}"

mapfile -t monkeys <"${1:-input.txt}"
for m in "${monkeys[@]}"; do
  IFS=': ' read -r n t <<<"$m"
  # shellcheck disable=SC2140
  if [[ $t == *[+-*/]* ]]; then
    export "$n"="($t)"
  else
    export "$n"="$t"
  fi
done
# shellcheck disable=SC2154
echo "$((root))"

# Part 2
# we could replace '+' by '==' and enumerate all possible values
# however, it is more efficient to evaluate only the necessary branch
unset humn

# shellcheck disable=SC2116
function solve() {
  [[ ! $DEBUG ]] || echo "solve \$1=$1 \$2=$2"
  IFS=' ' read -r a op b <<<"$1"
  a="${a#(}"
  b="${b%)}"
  if [[ "$a" == "" ]]; then
    echo "$(($2))"
    return
  fi

  [[ ! $DEBUG ]] || echo "EQ: $a $op $b"
  if [[ "${op:-}" == '+' ]]; then
    res_a="$(echo $((a)))" || res_a="???"
    res_b="$(echo $((b)))" || res_b="???"
    [[ ! $DEBUG ]] || echo "res_a: $res_a, res_b: $res_b, a: $a, b: $b"
    if [[ "${res_a}" == "???" ]]; then
      solve "${!a:-}" "$(($2 - res_b))"
    else
      solve "${!b:-}" "$(($2 - res_a))"
    fi
  elif [[ "${op:-}" == '-' ]]; then
    res_a="$(echo $((a)))" || res_a="???"
    res_b="$(echo $((b)))" || res_b="???"
    [[ ! $DEBUG ]] || echo "res_a: $res_a, res_b: $res_b, a: $a, b: $b"
    if [[ "${res_a}" == "???" ]]; then
      solve "${!a:-}" "$(($2 + res_b))"
    else
      solve "${!b:-}" "$((res_a - $2))"
    fi
  elif [[ "${op:-}" == '*' ]]; then
    res_a="$(echo $((a)))" || res_a="???"
    res_b="$(echo $((b)))" || res_b="???"
    [[ ! $DEBUG ]] || echo "res_a: $res_a, res_b: $res_b, a: $a, b: $b"
    if [[ "${res_a}" == "???" ]]; then
      solve "${!a:-}" "$(($2 / res_b))"
    else
      solve "${!b:-}" "$(($2 / res_a))"
    fi
  elif [[ "${op:-}" == '/' ]]; then
    res_a="$(echo $((a)))" || res_a="???"
    res_b="$(echo $((b)))" || res_b="???"
    [[ ! $DEBUG ]] || echo "res_a: $res_a, res_b: $res_b, a: $a, b: $b"
    if [[ "${res_a}" == "???" ]]; then
      solve "${!a:-}" "$(($2 * res_b))"
    else
      solve "${!b:-}" "$((res_a / $2))"
    fi
  fi
  exit 1
}

solve "${root%+*}-${root#*+}" "0" 2>/dev/null
