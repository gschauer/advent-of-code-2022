#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2034
set -euo pipefail

setup_suite() {
  source day08.sh
}

test_is_visible_edge() {
  trees="$(
    cat <<EOF
123
798
654
EOF
  )"

  for y in {0..2}; do
    for x in {0..2}; do
      [[ $x -eq 1 && $y -eq 1 ]] ||
        assert_status_code 0 'is_visible "$trees" "$x" "$y"'
    done
  done
}

test_is_largest() {
  assert_status_code 0 'is_largest 3 012'
  assert_status_code 1 'is_largest 3 030'
  assert_status_code 1 'is_largest 3 9'
}

test_is_visible() {
  trees="$(
    cat <<EOF
0123
2345
4567
6789
EOF
  )"

  assert_status_code 0 'is_visible "$trees" 2 2'
}
