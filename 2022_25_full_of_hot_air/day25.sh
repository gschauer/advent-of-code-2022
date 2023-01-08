#!/usr/bin/env bash
set -euo pipefail

function stoi() {
  local s="$1"
  local pos="${s//[-=]/0}"
  local neg="${s//[0-9]/0}"
  neg="${neg//-/1}"
  neg="${neg//=/2}"
  echo "$((5#$pos - 5#$neg))"
}

function itos() {
  local s=""
  local -i i="$1"
  while [[ $i -gt 0 ]]; do
    local -i rem=$((i % 5))
    case $rem in
    0) s="0$s" ; ((i-=rem)) || :;;
    1) s="1$s"; ((i-=rem)) || : ;;
    2) s="2$s"; ((i-=rem)) || : ;;
    3) s="=$s"; i+=2 ;;
    4) s="-$s"; i+=1 ;;
    esac
    ((i/= 5)) || :
  done
  echo "$s"
}

function calc_fuel() {
  local -i i=0
  while read -r l; do
    ((i += "$(stoi "$l")")) || :
  done <"$1"
  itos "$i"
}

# Main
[[ "$0" != "${BASH_SOURCE[0]}" ]] || {
  calc_fuel "${1:-input.txt}"
}
