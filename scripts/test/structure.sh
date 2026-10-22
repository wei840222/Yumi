#!/usr/bin/env bash
# Public-safe structure test: build with local.example.yaml only. Runs anywhere.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
# shellcheck source=scripts/test/lib.sh
. "$here/lib.sh"

out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT
YUMI_LOCAL="$root/local.example.yaml" YUMI_DIST="$out" "$root/scripts/build.sh" 2>/dev/null \
  || fail "build with local.example.yaml failed"

# Personal strings, when the maintainer's local.yaml exists (none are written here).
# shellcheck source=scripts/lib.sh
. "$root/scripts/lib.sh"
mapfile -t personal < <(personal_patterns "$root/local.yaml")

status=0
while IFS= read -r f; do
  for pat in "${personal[@]}"; do
    [ -n "$pat" ] || continue
    if grep -qF -- "$pat" "$f"; then printf 'FAIL: %s contains a personal value from local.yaml\n' "${f#"$out"/}"; status=1; fi
  done
  if grep -q 'bifrost' "$f"; then printf 'FAIL: %s mentions bifrost with features.bifrost=false\n' "${f#"$out"/}"; status=1; fi
  if grep -q '{{' "$f"; then printf 'FAIL: %s has unrendered template syntax\n' "${f#"$out"/}"; status=1; fi
done < <(find "$out" -type f | sort)
# TOML agents must parse; Markdown agents must keep a complete frontmatter.
python3 -I - "$out" <<'PY' || status=1
import glob, sys, tomllib
out = sys.argv[1]
bad = 0
for f in sorted(glob.glob(out + "/codex/agents/*.toml")):
    try:
        d = tomllib.load(open(f, "rb"))
        assert {"name", "description", "developer_instructions"} <= set(d)
    except Exception as e:
        print(f"FAIL: {f}: {e}"); bad = 1
for f in sorted(glob.glob(out + "/claude/agents/*.md")):
    parts = open(f, encoding="utf-8").read().split("---\n")
    keys = [l.split(":")[0] for l in parts[1].splitlines()] if len(parts) > 2 else []
    if keys != ["name", "description", "tools", "disallowedTools", "omitClaudeMd", "maxTurns"]:
        print(f"FAIL: {f}: frontmatter keys {keys}"); bad = 1
sys.exit(bad)
PY

[ "$status" -eq 0 ] && pass "example build is generic, fully rendered, and structurally valid"
exit "$status"
