#!/usr/bin/env bash
# Byte-for-byte regression: with the maintainer's local.yaml, the rendered files
# must equal the pre-migration baseline. Skips (exit 0) when either input is
# absent, which is the normal state for anyone but the maintainer.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
# shellcheck source=scripts/test/lib.sh
. "$here/lib.sh"

[ -f "$root/local.yaml" ] || skip "no local.yaml (maintainer-only regression)"
base=$(baseline_dir)
[ -n "$base" ] && [ -d "$base" ] || skip "no baseline snapshot under ~/.yumi-backup"

out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT
YUMI_LOCAL="$root/local.yaml" YUMI_DIST="$out" "$root/scripts/build.sh" 2>/dev/null

status=0
check() { # check <rendered> <baseline-name>
  if cmp -s "$out/$1" "$base/$2"; then pass "$1 == baseline/$2"
  else printf 'FAIL: %s differs from baseline/%s\n' "$1" "$2"; { diff -u "$base/$2" "$out/$1" || true; } | head -40; status=1; fi
}
check claude/CLAUDE.md CLAUDE.md
check codex/AGENTS.md AGENTS.md
for a in gate librarian; do
  check "claude/agents/$a.md" "$a.md"
  check "codex/agents/$a.toml" "$a.toml"
done
exit "$status"
