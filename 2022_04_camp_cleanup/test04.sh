#!/usr/bin/env bash
set -euo pipefail

setup_suite() {
  source day04.sh
}

test_subset_not() {
  assert_status_code 1 'is_subset 2-4 6-8'
  assert_status_code 1 'is_subset 6-8 2-4'
}

test_subset_equal() {
  assert_status_code 0 'is_subset 1-99 1-99'
}

test_subset_intersection_mid() {
  assert_status_code 1 'is_subset 6-50 49-51'
  assert_status_code 1 'is_subset 49-51 6-50'
}

test_subset_begin() {
  assert_status_code 0 'is_subset 4-4 4-6'
  assert_status_code 0 'is_subset 4-6 4-4'
}

test_subset_end() {
  assert_status_code 0 'is_subset 6-6 4-6'
  assert_status_code 0 'is_subset 4-6 6-6'
}

test_subset_contains() {
  assert_status_code 0 'is_subset 2-8 3-7'
}

test_subset_example() {
  assert_equals 2 "$(count_subsets example.txt)"
}

test_subset_input() {
  assert_equals 532 "$(count_subsets input.txt)"
}

test_overlap_not() {
  assert_status_code 1 'is_overlap 1-1 2-7'
}

test_overlap_contains() {
  assert_status_code 0 'is_overlap 2-8 3-7'
}

test_overlap_example() {
  assert_equals 4 "$(count_overlaps example.txt)"
}

test_overlap_input() {
  got="$(count_overlaps input.txt)"
  assert_equals 854 "$got"
}
