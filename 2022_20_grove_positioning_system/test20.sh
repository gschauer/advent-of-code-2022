#!/usr/bin/env bash
set -euo pipefail

setup_suite() {
  source day20.sh
}

test_move() {
  declare -a seq=(1 2 -3 3 -2 0 4)
  move 0 1 && assert_equals "2 1_ -3 3 -2 0 4" "${seq[*]}"
  move 0 2 && assert_equals "1_ -3 2_ 3 -2 0 4" "${seq[*]}"
  move 1 -3 && assert_equals "1_ 2_ 3 -2 -3_ 0 4" "${seq[*]}"
  move 2 3 && assert_equals "1_ 2_ -2 -3_ 0 3_ 4" "${seq[*]}"
  move 2 -2 && assert_equals "1_ 2_ -3_ 0 3_ 4 -2_" "${seq[*]}"
  move 3 0 && assert_equals "1_ 2_ -3_ 0_ 3_ 4 -2_" "${seq[*]}"
  move 5 4 && assert_equals "1_ 2_ -3_ 4_ 0_ 3_ -2_" "${seq[*]}"
}
