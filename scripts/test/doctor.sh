#!/usr/bin/env bash
# doctor.sh against a throw-away HOME: clean state passes, each kind of defect is
# reported with its own message, and the run writes nothing.
# shellcheck disable=SC2329  # the check functions are invoked indirectly through t()
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
# shellcheck source=scripts/test/lib.sh
. "$here/lib.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME=$tmp/home CLAUDE_HOME=$tmp/home/.claude CODEX_HOME=$tmp/home/.codex TMPDIR=$tmp/scratch
export YUMI_DIST=$tmp/dist YUMI_BACKUP_DIR=$tmp/backups YUMI_LOCAL="$root/local.example.yaml"
export YUMI_EPHEMERAL_GLOB='/nonexistent/*'
mkdir -p "$CLAUDE_HOME" "$CODEX_HOME" "$TMPDIR"
"$root/scripts/build.sh" >/dev/null 2>&1
"$root/scripts/install.sh" >/dev/null 2>&1

status=0
t() { local d=$1; shift; if "$@"; then pass "$d"; else printf 'FAIL: %s\n' "$d"; status=1; fi; }
run_doctor() { "$root/scripts/doctor.sh" > "$tmp/out" 2>&1 || true; }
exit_code()  { "$root/scripts/doctor.sh" >/dev/null 2>&1; echo $?; }
says()       { grep -qE -- "$1" "$tmp/out"; }
reinstall()  { "$root/scripts/install.sh" >/dev/null 2>&1; }
snapshot()   { (cd "$tmp" && find home dist -type f -o -type l | sort | while read -r f; do printf '%s %s\n' "$f" "$(if [ -L "$f" ]; then readlink "$f"; else sha256sum < "$f"; fi)"; done); }

# fixtures: pretend the submodules are initialised and pinned
export YUMI_SUBMODULE_STATUS_FILE=$tmp/submodule-ok
git -C "$root" config -f .gitmodules --get-regexp '^submodule\..*\.path$' | awk '{printf " 0000000 %s (test)\n", $2}' > "$tmp/submodule-ok"

# 1. clean state
run_doctor
t "a clean install exits 0" test "$(exit_code)" = 0
t "a clean install has no FAIL lines" bash -c "! grep -q '^FAIL' '$tmp/out'"

# 2. read-only: nothing under home/ or dist/ changes
before=$(snapshot)
run_doctor
t "doctor wrote nothing under the homes or dist" test "$(snapshot)" = "$before"

# 3. each defect is reported with its own message
echo tampered >> "$CLAUDE_HOME/CLAUDE.md"; run_doctor
t "edited CLAUDE.md is reported" says 'installed: CLAUDE.md differs'
t "an edited install makes doctor exit non-zero" bash -c "! '$root/scripts/doctor.sh' >/dev/null 2>&1"
reinstall

rm "$CLAUDE_HOME/agents/gate.md"; run_doctor
t "a missing agent is reported" says 'installed: claude agent gate.md is missing'
reinstall

rm "$CODEX_HOME/skills/analyze"; run_doctor
t "a missing skill link is reported" says 'skill analyze \(codex\): not installed'
reinstall

rm "$CLAUDE_HOME/skills/analyze"; mkdir "$CLAUDE_HOME/skills/analyze"; run_doctor
t "a real directory in place of a link is reported" says 'skill analyze \(claude\): .* real directory'
reinstall

rm "$CLAUDE_HOME/skills/plan"; ln -s "$tmp/gone" "$CLAUDE_HOME/skills/plan"; run_doctor
t "a dangling link is reported" says 'skill plan \(claude\): dangling link'
reinstall

rm "$CLAUDE_HOME/skills/plan"; ln -s "$root/skills/analyze" "$CLAUDE_HOME/skills/plan"; run_doctor
t "a link to the wrong target is reported" says 'skill plan \(claude\): points to'
reinstall

head -c 40000 /dev/zero | tr '\0' x > "$CODEX_HOME/AGENTS.md"; run_doctor
t "an oversized AGENTS.md is reported" says 'size: .*AGENTS.md is 40000 bytes'
reinstall

printf '%s\n' "-0000000 upstream/ponytail" > "$tmp/submodule-bad"
YUMI_SUBMODULE_STATUS_FILE=$tmp/submodule-bad run_doctor
t "an uninitialised submodule is reported" says 'submodule upstream/ponytail: not initialized'
printf '%s\n' "+0000000 upstream/ponytail (x)" > "$tmp/submodule-moved"
YUMI_SUBMODULE_STATUS_FILE=$tmp/submodule-moved run_doctor
t "a submodule off its pin is reported" says 'submodule upstream/ponytail: not at the commit'

echo stale >> "$tmp/dist/claude/CLAUDE.md"; run_doctor
t "a stale dist directory is a warning" says 'warn  dist/ is stale'
"$root/scripts/build.sh" >/dev/null 2>&1

rm -rf "$tmp/dist"; run_doctor
t "a missing dist directory is a warning, not a failure" says 'warn  dist/ has not been built'
exit "$status"
