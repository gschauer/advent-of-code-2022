#!/usr/bin/env bash
set -euo pipefail

setup_suite() {
  source day05.sh
}

test_move_one() {
  local got
  got="$(move A B 1)"
  assert_equals " BA" "$got"
}

test_move() {
  local got
  got="$(move MDPNGQ NFVQDGTZ 3)"
  assert_equals "MDP NFVQDGTZQGN" "$got"
}

test_transpose() {
  local in got
  in="$(
    cat <<EOF
    [D]
[N] [C]
[Z] [M] [P]
EOF
  )"

  got="$(transpose "$in" 3)"
  assert_equals ZN$'\n'MCD$'\n'P "$got"
}

test_read_stacks() {
  local got
  got="$(read_stacks example.txt)"
  IFS=$'\n' readarray -t got <<<"$got"
  assert_equals "ZN MCD P" "${got[*]}"
  assert_equals 3 "${#got[@]}"
}

test_move_stacks_example() {
  local got
  got="$(move_stacks example.txt)"
  assert_equals "C M PDNZ" "$got"
}

test_get_top() {
  local got
  got="$(get_top "C M PDNZ")"
  assert_equals "CMZ" "$got"
}

test_reorg_stacks_example() {
  local got
  got="$(reorg_stacks example.txt)"
  assert_equals "CMZ" "$got"
}

test_reorg_stacks_input() {
  local got
  got="$(reorg_stacks input.txt)"
  assert_equals "QMBMJDFTD" "$got"
}

test_reorg_stacks_move_atomic_example() {
  local got
  got="$(MOVE_MODE="ALL" reorg_stacks example.txt)"
  assert_equals "MCD" "$got"
}

test_reorg_stacks_move_atomic_input() {
  local got
  got="$(MOVE_MODE="ALL" reorg_stacks input.txt)"
  assert_equals "NBTVTJNFJ" "$got"
}
