#!/usr/bin/env bash
# Public-release hygiene scan.
#
#   hygiene.sh [--root DIR] [--no-dist]
#
# Fails when personal values appear in
#   1. files tracked by git (skills/, this script, and the tests
#      are skipped: they necessarily name the patterns, or are third-party), or
#   2. anything built from local.example.yaml, which must also be bifrost-free.
# Tracked files are also checked for credential-shaped strings (key prefixes,
# private-key headers, bearer values).
#
# Personal patterns come only from local.yaml (see personal_patterns in lib.sh),
# so this script contains no personal string itself; without a local.yaml only
# the credential-shape and bifrost checks run.
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

root=$(repo_root) scan_dist=1
while [ $# -gt 0 ]; do
  case $1 in
    --root) root=$(cd "$2" && pwd); shift ;;
    --no-dist) scan_dist=0 ;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
  shift
done
need git grep

patterns=$(mktemp)
tmp_dist=$(mktemp -d)
trap 'rm -rf "$patterns" "$tmp_dist"' EXIT
personal_patterns "$root/local.yaml" > "$patterns" || true

# Shapes of real credentials: provider key prefixes, private keys, bearer tokens.
secrets=$(mktemp)
trap 'rm -rf "$patterns" "$tmp_dist" "$secrets"' EXIT
cat > "$secrets" <<'RE'
sk-[A-Za-z0-9_-]{20,}
ghp_[A-Za-z0-9]{30,}
AKIA[0-9A-Z]{16}
-----BEGIN [A-Z ]*PRIVATE KEY-----
x-bf-vk["']? *[=:] *["'][^"']{8,}
RE

status=0
hit() { printf 'HIT  %s\n' "$1"; status=1; }

# 1. tracked files
while IFS= read -r -d '' f; do
  case $f in skills/*|scripts/hygiene.sh|scripts/test/*|.gitmodules) continue ;; esac
  [ -f "$root/$f" ] || continue
  if [ -s "$patterns" ]; then
    while IFS= read -r line; do hit "$f:$line"; done < <(grep -nIF -f "$patterns" -- "$root/$f" | cut -c1-140 || true)
  fi
  while IFS= read -r line; do hit "$f: looks like a credential (line ${line%%:*})"; done < <(grep -nIE -f "$secrets" -- "$root/$f" | cut -c1-20 || true)
done < <(git -C "$root" ls-files -z)

# 2. an example build
if [ "$scan_dist" -eq 1 ] && [ -f "$root/src/prompt/main.md.tmpl" ] && command -v gomplate >/dev/null 2>&1; then
  YUMI_LOCAL="$root/local.example.yaml" YUMI_DIST="$tmp_dist" "$root/scripts/build.sh" >/dev/null 2>&1 \
    || { log "example build failed"; exit 1; }
  while IFS= read -r f; do
    while IFS= read -r line; do hit "dist:${f#"$tmp_dist"/}:$line"; done < <(grep -nIiF -e bifrost ${patterns:+-f "$patterns"} -- "$f" | cut -c1-140 || true)
  done < <(find "$tmp_dist" -type f | sort)
fi

if [ "$status" -eq 0 ]; then log "hygiene: clean"; else log "hygiene: personal values found"; fi
exit "$status"
