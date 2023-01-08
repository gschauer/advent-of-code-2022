#!/usr/bin/env bash
set -euo pipefail

setup_suite() {
  source day09.sh
}

test_move_uu() {
  declare -a r_x=(0 0) r_y=(0 0)
  move_head U && assert_equals "0/1 0/0" "$(rope_string)"
  move_head U && assert_equals "0/2 0/1" "$(rope_string)"
}

test_move_dd() {
  declare -a r_x=(0 0) r_y=(0 0)
  move_head D && assert_equals "0/-1 0/0" "$(rope_string)"
  move_head D && assert_equals "0/-2 0/-1" "$(rope_string)"
}

test_move_ll() {
  declare -a r_x=(0 0) r_y=(0 0)
  move_head L && assert_equals "-1/0 0/0" "$(rope_string)"
  move_head L && assert_equals "-2/0 -1/0" "$(rope_string)"
}

test_move_rr() {
  declare -a r_x=(0 0) r_y=(0 0)
  move_head R && assert_equals "1/0 0/0" "$(rope_string)"
  move_head R && assert_equals "2/0 1/0" "$(rope_string)"
}

test_move_uru() {
  declare -a r_x=(0 0) r_y=(0 0)
  move_head U && assert_equals "0/1 0/0" "$(rope_string)"
  move_head R && assert_equals "1/1 0/0" "$(rope_string)"
  move_head U && assert_equals "1/2 1/1" "$(rope_string)"
}

test_move_urr() {
  declare -a r_x=(0 0) r_y=(0 0)
  move_head U && assert_equals "0/1 0/0" "$(rope_string)"
  move_head R && assert_equals "1/1 0/0" "$(rope_string)"
  move_head R && assert_equals "2/1 1/1" "$(rope_string)"
}

test_move_rope_example() {
  assert_equals 1 "$(move_rope example.txt)"
}

test_move_rope_example2() {
  assert_equals 36 "$(move_rope example2.txt)"
}

test_move_stair3() {
  declare -a r_x=(0 0 0) r_y=(0 0 0)
  move_head U && assert_equals "0/1 0/0 0/0" "$(rope_string)"
  move_head R && assert_equals "1/1 0/0 0/0" "$(rope_string)"
  move_head U && assert_equals "1/2 1/1 0/0" "$(rope_string)"
  move_head R && assert_equals "2/2 1/1 0/0" "$(rope_string)"
  # diagonal jump
  move_head U && assert_equals "2/3 2/2 1/1" "$(rope_string)"
  move_head R && assert_equals "3/3 2/2 1/1" "$(rope_string)"
}

test_move_rope_input() {
  vis="$(move_rope input.txt)"
  assert_equals 2331 "$vis"
}

function rope_string() {
  local s=""
  for ((i = 0; i < ${#r_x[@]}; i++)); do
    s+=" ${r_x[i]}/${r_y[i]}"
  done
  echo "${s:1}"
}
