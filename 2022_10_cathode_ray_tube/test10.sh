#!/usr/bin/env bash
set -euo pipefail

setup_suite() {
  source day10.sh
}

setup() {
  cyc=x=sig=0
}

test_noop() {
  run "noop"
  assert_equals "1 0 0" "$cyc $x $sig"
}

test_addx() {
  run "addx" 4
  assert_equals "2 4 0" "$cyc $x $sig"
  run "addx" 2
  assert_equals "4 6 0" "$cyc $x $sig"
  run "addx" 1
  assert_equals "6 7 0" "$cyc $x $sig"
  run "addx" -8
  assert_equals "8 -1 0" "$cyc $x $sig"
  for _ in {1..14}; do
    run "noop"
  done
  assert_equals "22 -1 -20" "$cyc $x $sig"
}
