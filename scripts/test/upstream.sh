#!/usr/bin/env bash
# Manifest and submodule consistency: every submodule skill resolves to a
# directory with a SKILL.md, every manifest source exists, and no skill is
# listed twice or shadowed by a local copy.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
# shellcheck source=scripts/test/lib.sh
. "$here/lib.sh"
# shellcheck source=scripts/lib.sh
. "$root/scripts/lib.sh"

status=0
declare -A seen=()
while IFS=$YUMI_FS read -r name kind a b _ _; do
  [ -n "$name" ] || continue
  if [ -n "${seen[$name]:-}" ]; then printf 'FAIL: %s is listed twice\n' "$name"; status=1; fi
  seen[$name]=1
  [ "$kind" = external ] && continue
  if ! src=$(skill_source_dir "$kind" "$a" "$b"); then printf 'FAIL: %s: the source path is empty, not a directory, or leaves the repository\n' "$name"; status=1; continue; fi
  if [ ! -f "$src/SKILL.md" ]; then
    printf 'FAIL: %s: %s/SKILL.md not found%s\n' "$name" "$src" "$([ "$kind" = submodule ] && printf ' (git submodule update --init --depth 1)')"
    status=1
  fi
  if [ "$kind" = submodule ] && [ -d "$root/skills/$name" ]; then
    printf 'FAIL: %s has a local copy that shadows its submodule source\n' "$name"; status=1
  fi
done < <(skill_rows)

# Every submodule in .gitmodules is used by the manifest, and vice versa.
used=$(skill_rows | awk -F"$YUMI_FS" '$2=="submodule"{print $3}' | sort -u)
declared=$(git -C "$root" config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | awk '{print $2}' | sort -u)
if [ "$used" != "$declared" ]; then
  printf 'FAIL: .gitmodules and the manifest disagree\n  manifest: %s\n  .gitmodules: %s\n' "$(echo "$used" | tr '\n' ' ')" "$(echo "$declared" | tr '\n' ' ')"
  status=1
fi
[ "$status" -eq 0 ] && pass "manifest sources and submodules are consistent"
exit "$status"
