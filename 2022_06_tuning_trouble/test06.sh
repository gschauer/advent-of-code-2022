#!/usr/bin/env bash
set -euo pipefail

setup_suite() {
  source day06.sh
}

test_find_marker_begin() {
  got="$(find_marker 1 <<<"ab")"
  assert_equals 1 "$got"
}

test_find_packet_example() {
  got="$(find_marker 4 example.txt)"
  assert_equals 7 "$got"
}

test_find_packet_input() {
  got="$(find_marker 4 input.txt)"
  assert_equals 1538 "$got"
}

test_find_message_example() {
  got="$(find_marker 14 example.txt)"
  assert_equals 19 "$got"
}

test_find_message_input() {
  got="$(find_marker 14 input.txt)"
  assert_equals 2315 "$got"
}
