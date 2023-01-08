#!/usr/bin/env bash
set -euo pipefail

while read -r txt; do
  solved="**"
  if [[ -f "${txt%.txt}.sh" ]]; then
    grep -Eiq "part [12]" "${txt%.txt}.sh" 2>/dev/null || solved="${solved:1:1}"
  elif [[ ! -f "${txt%/*}/main.go" ]]; then
    solved="  "
  fi

  header="$(head -n 1 "${txt%/*}"/day??.txt)"
  IFS=': ' read -r _ _ day title <<<"$header"
  txt="${txt#./}"
  if [[ "$solved" == "*"* ]]; then
    printf -- "- [\`%2d %-2s\` %s](../../tree/main/%s)\n" "$day" "${solved:-**}" "${title% ---}" "${txt%/*}"
  else
    printf -- "- \`%2d %-2s\` %s\n" "$day" "${solved:-**}" "${title% ---}"
  fi
done <<<"$(find "$(dirname "${BASH_SOURCE[0]}")" -name day??.txt | sort -r)"
