#!/usr/bin/env bash
# install.sh against a throw-away HOME: dry run, first install, idempotence,
# backups, the ephemeral-path guard, and the "never touch" list.
# shellcheck disable=SC2329  # the check functions are invoked indirectly through t()
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
# shellcheck source=scripts/test/lib.sh
. "$here/lib.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME=$tmp/home
export CLAUDE_HOME=$HOME/.claude CODEX_HOME=$HOME/.codex
export YUMI_DIST=$tmp/dist YUMI_BACKUP_DIR=$tmp/backups YUMI_LOCAL="$root/local.example.yaml"
mkdir -p "$CLAUDE_HOME/skills/hindsight-coding-agent" "$CLAUDE_HOME/skills/analyze" "$CLAUDE_HOME/skills/synced" "$CLAUDE_HOME/skills/unrelated" \
         "$CODEX_HOME/skills/.system" "$CODEX_HOME/skills/pdf" "$HOME/.agents/skills/shared"
echo "managed elsewhere" > "$CLAUDE_HOME/skills/hindsight-coding-agent/SKILL.md"
echo "old prompt" > "$CLAUDE_HOME/CLAUDE.md"
echo "old skill" > "$CLAUDE_HOME/skills/analyze/SKILL.md"
echo '{"keep":"me"}' > "$CLAUDE_HOME/settings.json"
echo 'model = "keep"' > "$CODEX_HOME/config.toml"
echo "secret" > "$CODEX_HOME/auth.json"
echo "sync" > "$CLAUDE_HOME/skills/synced/x"
echo "sys" > "$CODEX_HOME/skills/.system/x"
echo "other" > "$HOME/.agents/skills/shared/SKILL.md"

"$root/scripts/build.sh" >/dev/null 2>&1

snapshot() {
  (cd "$HOME" && find . \( -type f -o -type l \) | sort | while read -r f; do
    printf '%s %s\n' "$f" "$(if [ -L "$f" ]; then readlink "$f"; else sha256sum < "$f"; fi)"
  done)
}
before=$(snapshot)
status=0
# t <description> <command...>: pass when the command succeeds.
t() { local d=$1; shift; if "$@"; then pass "$d"; else printf 'FAIL: %s\n' "$d"; status=1; fi; }

home_unchanged()  { [ "$(snapshot)" = "$before" ]; }
no_backup_dir()   { [ ! -d "$tmp/backups" ]; }
guard_refuses()   { ! YUMI_EPHEMERAL_GLOB="$root/*" "$root/scripts/install.sh" >/dev/null 2>"$tmp/err" && grep -q 'temporary worktree' "$tmp/err"; }
links_to_repo()   { [ -L "$1/skills/analyze" ] && [ "$(readlink "$1/skills/analyze")" = "$root/skills/analyze" ]; }
backup_dir()      { find "$tmp/backups" -mindepth 1 -maxdepth 1 -type d | head -n 1; }
backups_exist()   { local b; b=$(backup_dir); [ -n "$b" ] && [ "$(cat "$b/claude/CLAUDE.md")" = "old prompt" ] && [ "$(cat "$b/claude/skills/analyze/SKILL.md")" = "old skill" ]; }
secrets_intact()  { [ "$(cat "$CLAUDE_HOME/settings.json")" = '{"keep":"me"}' ] && [ "$(cat "$CODEX_HOME/config.toml")" = 'model = "keep"' ] && [ "$(cat "$CODEX_HOME/auth.json")" = secret ]; }
unlisted_intact() { [ "$(cat "$CLAUDE_HOME/skills/synced/x")" = sync ] && [ "$(cat "$CODEX_HOME/skills/.system/x")" = sys ] && [ -d "$CLAUDE_HOME/skills/unrelated" ] && [ -d "$CODEX_HOME/skills/pdf" ]; }
agents_home_intact() { [ "$(cat "$HOME/.agents/skills/shared/SKILL.md")" = other ]; }
agents_installed()   { [ -f "$CLAUDE_HOME/agents/gate.md" ] && [ -f "$CODEX_HOME/agents/gate.toml" ]; }
backup_count()    { find "$tmp/backups" -mindepth 1 -maxdepth 1 -type d | wc -l; }

require_local_refuses() {
  ! "$root/scripts/install.sh" --allow-ephemeral --require-local >/dev/null 2>"$tmp/err3" && grep -q 'require-local' "$tmp/err3"
}

# 1. ephemeral guard: a source under a matching path is refused and nothing changes.
t "refuses symlink sources under an ephemeral path" guard_refuses
t "refused install changed nothing" home_unchanged

# 2. dry run writes nothing.
"$root/scripts/install.sh" --dry-run --allow-ephemeral >/dev/null 2>&1
t "dry run changed nothing" home_unchanged
t "dry run created no backup directory" no_backup_dir

# 3. real install.
t "install succeeds" "$root/scripts/install.sh" --allow-ephemeral >/dev/null 2>&1
t "CLAUDE.md copied" cmp -s "$YUMI_DIST/claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
t "AGENTS.md copied" cmp -s "$YUMI_DIST/codex/AGENTS.md" "$CODEX_HOME/AGENTS.md"
t "agents copied" agents_installed
t "claude skill is a link to the repo" links_to_repo "$CLAUDE_HOME"
t "codex skill is a link to the repo" links_to_repo "$CODEX_HOME"
t "replaced files and directories were backed up" backups_exist
t "external skill is left exactly as it was" test "$(cat "$CLAUDE_HOME/skills/hindsight-coding-agent/SKILL.md")" = "managed elsewhere"
t "external skill is not turned into a link" test ! -L "$CLAUDE_HOME/skills/hindsight-coding-agent"
t "submodule skill links to its subpath" test "$(readlink "$CLAUDE_HOME/skills/handoff")" = "$root/upstream/mattpocock-skills/skills/productivity/handoff"
t "a nested upstream skill is copied, not linked, into Codex" test -d "$CODEX_HOME/skills/defuddle" -a ! -L "$CODEX_HOME/skills/defuddle"
t "the Codex copy equals the pinned source" diff -rq "$root/upstream/obsidian-skills/skills/defuddle" "$CODEX_HOME/skills/defuddle"
t "the same skill is still linked for Claude" test "$(readlink "$CLAUDE_HOME/skills/defuddle")" = "$root/upstream/obsidian-skills/skills/defuddle"
t "a Claude-only skill is not installed for Codex" test ! -e "$CODEX_HOME/skills/handoff"
t "submodule skill at the repo root links to the submodule" test "$(readlink "$CLAUDE_HOME/skills/kubernetes-skill")" = "$root/upstream/kubernetes-skill"

# 4. never-touch list.
t "settings, config, and credentials untouched" secrets_intact
t "synced, .system, and unlisted skills untouched" unlisted_intact
t "the shared ~/.agents directory untouched" agents_home_intact

# 5. restore puts the originals back (and a dry run changes nothing).
bk=$(backup_dir)
pre_restore=$(snapshot)
"$root/scripts/restore.sh" "$bk" --dry-run >/dev/null 2>&1
t "restore --dry-run changed nothing" test "$(snapshot)" = "$pre_restore"
"$root/scripts/restore.sh" "$bk" >/dev/null 2>&1
t "restore brings back the old prompt" test "$(cat "$CLAUDE_HOME/CLAUDE.md")" = "old prompt"
t "restore brings back a replaced skill directory" test "$(cat "$CLAUDE_HOME/skills/analyze/SKILL.md")" = "old skill"
t "restore leaves the settings and credentials alone" secrets_intact
"$root/scripts/install.sh" --allow-ephemeral >/dev/null 2>&1

# 6. unsafe skill names and --require-local.
t "--require-local refuses files rendered from the example values" require_local_refuses

# 7. idempotence.
count=$(backup_count)
out=$("$root/scripts/install.sh" --allow-ephemeral 2>&1)
t "second run reports no changes" grep -q 'no changes' <<<"$out"
t "second run made no new backup" test "$(backup_count)" = "$count"
exit "$status"
