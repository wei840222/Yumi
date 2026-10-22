#!/usr/bin/env bash
# install.sh edge cases found in review: a forged values stamp, a failure part-way
# through (everything must be put back), free text in the manifest, a source path
# that leaves the repo, and restore's note about items that had no backup.
# shellcheck disable=SC2329,SC2016  # check functions run through t(); bash -c bodies are single-quoted on purpose
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
# shellcheck source=scripts/test/lib.sh
. "$here/lib.sh"

tmp=$(mktemp -d)
trap 'chmod -R u+rwX "$tmp" 2>/dev/null; rm -rf "$tmp"' EXIT
export HOME=$tmp/home CLAUDE_HOME=$tmp/home/.claude CODEX_HOME=$tmp/home/.codex
export YUMI_BACKUP_DIR=$tmp/backups YUMI_EPHEMERAL_GLOB='/nonexistent/*'
status=0
t() { local d=$1; shift; if "$@"; then pass "$d"; else printf 'FAIL: %s\n' "$d"; status=1; fi; }

# A throw-away copy of the repo, so the manifest and sources can be changed freely.
m=$tmp/repo
mkdir -p "$m" "$HOME"
cp -r "$root/scripts" "$root/src" "$root/platforms" "$m/"
cp "$root/local.example.yaml" "$m/"
printf 'features:\n  bifrost: false\n  gitea: false\ngitea: {host: h, user: u, org: o, login: l, default_login: "", default_login_owner: ""}\nhindsight: {url: "https://other.example/", bank: other}\nbifrost: {url: "https://b.example/mcp"}\n' > "$tmp/other.yaml"
mkskill() { mkdir -p "$m/skills/$1"; printf -- '---\nname: %s\ndescription: d\n---\n' "$1" > "$m/skills/$1/SKILL.md"; }
mkskill aaa; mkskill zzz
build() { YUMI_LOCAL=$1 YUMI_DIST=$2 "$m/scripts/build.sh" >/dev/null 2>&1; }
install() { YUMI_DIST=$1 "$m/scripts/install.sh" "${@:2}"; }

# --- 1. a forged or stale values stamp is refused by --require-local
printf 'skills:\n  - name: aaa\n    source: { local: skills/aaa }\n' > "$m/skills.yaml"
build "$m/local.example.yaml" "$tmp/dist-example"
forged_stamp_refused() {
  local h; h=$(sha256sum "$tmp/other.yaml" | cut -d' ' -f1)
  printf '%s %s\n' "$h" "$tmp/other.yaml" > "$tmp/dist-example/.values"
  ! install "$tmp/dist-example" --dry-run --require-local >/dev/null 2>"$tmp/err" && grep -q 'not a fresh render' "$tmp/err"
}
t "an example render with a forged stamp is refused" forged_stamp_refused
build "$tmp/other.yaml" "$tmp/dist-other"
genuine_accepted() { install "$tmp/dist-other" --dry-run --require-local >/dev/null 2>&1; }
t "a genuine render of non-example values is accepted" genuine_accepted
cp "$tmp/other.yaml" "$tmp/other.bak"
changed_after_build_refused() {
  sed -i 's#https://other.example/#https://changed.example/#' "$tmp/other.yaml"
  ! install "$tmp/dist-other" --dry-run --require-local >/dev/null 2>"$tmp/err" && grep -q 'not a fresh render' "$tmp/err"
}
t "values edited after the build are refused" changed_after_build_refused
cp "$tmp/other.bak" "$tmp/other.yaml"

# --- 2. a failure part-way through puts every item back
if [ "$(id -u)" -eq 0 ]; then printf 'SKIP: rollback test needs a non-root user (chmod 000 is ignored for root)\n'
else
  printf 'skills:\n  - name: aaa\n    source: { local: skills/aaa }\n  - name: zzz\n    source: { local: skills/zzz }\n    install: { codex: copy }\n' > "$m/skills.yaml"
  printf 'unreadable\n' > "$m/skills/zzz/secret"; chmod 000 "$m/skills/zzz/secret"
  mkdir -p "$CLAUDE_HOME/skills/aaa" "$CODEX_HOME/skills/zzz"
  echo "old prompt" > "$CLAUDE_HOME/CLAUDE.md"; echo "old agents" > "$CODEX_HOME/AGENTS.md"
  echo "old aaa" > "$CLAUDE_HOME/skills/aaa/SKILL.md"; echo "old zzz" > "$CODEX_HOME/skills/zzz/SKILL.md"
  build "$tmp/other.yaml" "$tmp/dist-rb"
  rolled_back() {
    ! install "$tmp/dist-rb" >/dev/null 2>"$tmp/err"
  }
  t "a failure part-way makes install exit non-zero" rolled_back
  t "the failure says it rolled back" grep -q 'rolled back' "$tmp/err"
  t "the prompt is back as it was" test "$(cat "$CLAUDE_HOME/CLAUDE.md")" = "old prompt"
  t "AGENTS.md is back as it was" test "$(cat "$CODEX_HOME/AGENTS.md")" = "old agents"
  t "an already-linked skill directory is back as it was" test "$(cat "$CLAUDE_HOME/skills/aaa/SKILL.md")" = "old aaa" -a ! -L "$CLAUDE_HOME/skills/aaa"
  t "the skill that failed is back as it was" test "$(cat "$CODEX_HOME/skills/zzz/SKILL.md")" = "old zzz"
  t "no temporary or aside files are left behind" test -z "$(find "$HOME" -name '*.yumi-*' | head -n 1)"
  chmod u+r "$m/skills/zzz/secret"
fi

# --- 3. free text in the manifest cannot shift fields
printf 'skills:\n  - name: aaa\n    source: { local: skills/aaa }\n  - name: ext\n    source: { external: "note with | pipe and, comma" }\n    platforms: [claude]\n' > "$m/skills.yaml"
rm -rf "$HOME/.claude" "$HOME/.codex"; mkdir -p "$HOME"
pipe_note_ok() {
  install "$tmp/dist-rb" > "$tmp/out" 2>&1 && grep -q 'skip   ext (external: note with | pipe and, comma)' "$tmp/out" \
    && [ -L "$CLAUDE_HOME/skills/aaa" ] && [ -L "$CODEX_HOME/skills/aaa" ]
}
t "a pipe in a manifest note does not shift the fields" pipe_note_ok

# --- 4. a source path that leaves the repo is refused
printf 'skills:\n  - name: evil\n    source: { local: ../outside }\n' > "$m/skills.yaml"
mkdir -p "$tmp/outside"; printf -- '---\nname: x\ndescription: d\n---\n' > "$tmp/outside/SKILL.md"
escape_refused() { ! install "$tmp/dist-rb" --dry-run >/dev/null 2>"$tmp/err" && grep -q 'leaves the repository' "$tmp/err"; }
t "a manifest path with .. is refused" escape_refused
printf 'skills:\n  - name: evil\n    source: { local: skills/link }\n' > "$m/skills.yaml"
ln -s "$tmp/outside" "$m/skills/link"
symlink_escape_refused() { ! install "$tmp/dist-rb" --dry-run >/dev/null 2>"$tmp/err" && grep -q 'leaves the repository' "$tmp/err"; }
t "a symlink that resolves outside the repo is refused" symlink_escape_refused
rm -f "$m/skills/link"

# --- 4b. a skill name that is not a safe directory name is refused
printf 'skills:\n  - name: "../hooks"\n    source: { local: skills/aaa }\n' > "$m/skills.yaml"
unsafe_name_refused() { ! install "$tmp/dist-rb" --dry-run >/dev/null 2>"$tmp/err" && grep -q 'not a safe directory name' "$tmp/err"; }
t "a skill name with a slash is refused" unsafe_name_refused

# --- 4c. empty and non-directory sources are rejected by the helper, and doctor reports them
src_rejected() { ! bash -c '. "$1/scripts/lib.sh"; skill_source_dir "$2" "$3" "$4" >/dev/null' _ "$m" "$@"; }
t "an empty local path is rejected" src_rejected local "" ""
printf 'not a directory\n' > "$m/skills/afile"
t "a path that is a file is rejected" src_rejected local skills/afile ""
t "a normal skill directory is accepted" bash -c '. "$1/scripts/lib.sh"; skill_source_dir local skills/aaa "" >/dev/null' _ "$m"
printf 'skills:\n  - name: evil\n    source: { local: ../outside }\n  - name: aaa\n    source: { local: skills/aaa }\n' > "$m/skills.yaml"
git init -q "$m" && git -C "$m" add -A >/dev/null 2>&1
printf ' 0000000 upstream/none (test)\n' > "$tmp/sm"
doctor_reports_bad_path() {
  YUMI_DIST=$tmp/dist-rb YUMI_SUBMODULE_STATUS_FILE=$tmp/sm "$m/scripts/doctor.sh" > "$tmp/doctor.out" 2>&1 || true
  grep -q 'FAIL  skill evil: the source path' "$tmp/doctor.out" && grep -q '^doctor: ' "$tmp/doctor.out"
}
t "doctor reports a rejected source path and keeps going" doctor_reports_bad_path

# --- 5. restore says which items it cannot undo
printf 'skills:\n  - name: aaa\n    source: { local: skills/aaa }\n  - name: zzz\n    source: { local: skills/zzz }\n' > "$m/skills.yaml"
rm -rf "$HOME/.claude" "$HOME/.codex" "$tmp/backups"; mkdir -p "$CLAUDE_HOME/skills/aaa"; echo "old aaa" > "$CLAUDE_HOME/skills/aaa/SKILL.md"
install "$tmp/dist-rb" >/dev/null 2>&1
bk=$(find "$tmp/backups" -mindepth 1 -maxdepth 1 -type d | head -n 1)
restore_notes() { "$m/scripts/restore.sh" "$bk" 2>&1 | grep -q 'left in place because this backup has no copy.*claude/skills/zzz'; }
t "restore lists the items that had no backup" restore_notes
t "restore still puts back what had a backup" test "$(cat "$CLAUDE_HOME/skills/aaa/SKILL.md")" = "old aaa"
exit "$status"
