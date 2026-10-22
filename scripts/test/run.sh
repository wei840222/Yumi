#!/usr/bin/env bash
# Run every scripts/test/*.sh except run.sh and the lib.sh helper. Each test exits 0 on pass or skip.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
fail=0
for t in "$here"/*.sh; do
  case $(basename "$t") in run.sh|lib.sh) continue ;; esac
  printf '== %s\n' "$(basename "$t")"
  rc=0; bash "$t" || rc=$?
  if [ "$rc" -ne 0 ]; then printf 'FAIL: %s exited %s\n' "$(basename "$t")" "$rc"; fail=1; fi
done
exit "$fail"
