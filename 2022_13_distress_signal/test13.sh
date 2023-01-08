#!/usr/bin/env bash
set -euo pipefail

setup_suite() {
  source day13.sh
}

test_is_list() {
  assert_status_code 0 'is_list []'
  assert_status_code 0 'is_list [[3,14]]'
  assert_status_code 1 'is_list ""'
  assert_status_code 1 'is_list 3'
}

test_is_num() {
  assert_status_code 1 'is_num []'
  assert_status_code 1 'is_num ""'
  assert_status_code 0 'is_num 0'
  assert_status_code 0 'is_num 11'
  assert_status_code 1 'is_num 11a'
}

test_cmp() {
  assert_equals "0" "$(cmp 0 0)"
  assert_equals "2" "$(cmp 5 3)"
  assert_equals "-5" "$(cmp 0 5)"
  assert_equals "0" "$(cmp "[]" "[]")"
  assert_equals "-99" "$(cmp "[]" "[1]")"
  assert_equals "99" "$(cmp "[1,2]" "[]")"

  assert_equals "-2" "$(cmp "[1,1,3,1,1]" "[1,1,5,1,1]")"
  assert_equals "-2" "$(cmp "[[1],[2,3,4]]" "[[1],4]")"
  assert_equals "1" "$(cmp "[9]" "[[8,7,6]]")"
  assert_equals "-99" "$(cmp "[[4,4],4,4]" "[[4,4],4,4,4]")"
  assert_equals "99" "$(cmp "[7,7,7,7]" "[7,7,7]")"
  assert_equals "-99" "$(cmp "[]" "[3]")"
  assert_equals "99" "$(cmp "[[[]]]" "[[]]")"
  assert_equals "7" "$(cmp "[1,[2,[3,[4,[5,6,7]]]],8,9]" "[1,[2,[3,[4,[5,6,0]]]],8,9]")"

  assert_equals "99" "$(cmp "[1,1,3,1,1]" "[]")"
  assert_equals "-99" "$(cmp "[]" "[1,1,3,1,1]")"
}

test_check_signals_example() {
  assert_equals 13 "$(check_signals example.txt)"
}

test_check_signals_input() {
  assert_equals 6420 "$(check_signals input.txt)"
}

test_decode_example() {
  assert_equals 140 "$(decode example.txt)"
}

test_decode_input() {
  assert_equals 22000 "$(decode input.txt)"
}
