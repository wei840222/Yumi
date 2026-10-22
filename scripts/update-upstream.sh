#!/usr/bin/env bash
# Report what changed upstream for each skill submodule, and optionally move the pins.
#
#   update-upstream.sh            report only; no pin is changed
#   update-upstream.sh --apply    check out the new tips and stage the new pins
#
# The pins are the reviewed state of third-party skills, so moving them is a
# decision: read the report first, then run with --apply and commit the result.
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

apply=0
for arg in "$@"; do
  case $arg in
    --apply) apply=1 ;;
    -h|--help) sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $arg" ;;
  esac
done

root=$(repo_root)
need git gomplate
mapfile -t mods < <(git -C "$root" config -f .gitmodules --get-regexp '^submodule\..*\.path$' | awk '{print $2}')
[ "${#mods[@]}" -gt 0 ] || die "no submodules declared in .gitmodules"

changed=0
for path in "${mods[@]}"; do
  name=$(git -C "$root" config -f .gitmodules --get-regexp '^submodule\..*\.path$' | awk -v p="$path" '$2==p {print $1}' | sed -E 's/^submodule\.(.*)\.path$/\1/')
  branch=$(git -C "$root" config -f .gitmodules "submodule.$name.branch" || echo main)
  if [ ! -e "$root/$path/.git" ]; then printf '%-28s not initialized (git submodule update --init --depth 1)\n' "$path"; continue; fi
  pinned=$(git -C "$root/$path" rev-parse HEAD)
  git -C "$root/$path" fetch -q --depth 1 origin "$branch"
  tip=$(git -C "$root/$path" rev-parse FETCH_HEAD)
  if [ "$pinned" = "$tip" ]; then printf '%-28s up to date (%s)\n' "$path" "${pinned:0:7}"; continue; fi
  changed=$((changed + 1))
  printf '%-28s %s -> %s  %s\n' "$path" "${pinned:0:7}" "${tip:0:7}" "$(git -C "$root/$path" log -1 --format='%cs %s' FETCH_HEAD | cut -c1-90)"
  while IFS=$YUMI_FS read -r skill kind a b _ _; do
    [ "$kind" = submodule ] && [ "$a" = "$path" ] || continue
    spec=$b; [ "$b" = "." ] && spec=.
    n=$(git -C "$root/$path" diff --name-only "$pinned" "$tip" -- "$spec" | wc -l)
    printf '    skill %-22s %s file(s) changed\n' "$skill" "$n"
  done < <(skill_rows)
  if [ "$apply" -eq 1 ]; then
    git -C "$root/$path" checkout -q "$tip"
    git -C "$root" add "$path"
  fi
done

if [ "$changed" -eq 0 ]; then log "update-upstream: no updates"
elif [ "$apply" -eq 1 ]; then log "update-upstream: $changed pin(s) staged; review with 'git diff --cached --submodule', then commit"
else log "update-upstream: $changed update(s) available; nothing changed (re-run with --apply to stage the new pins)"; fi
