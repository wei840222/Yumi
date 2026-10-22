#!/usr/bin/env bash
# update-upstream.sh with a local fake upstream: reports without moving the pin,
# and moves it only with --apply.
# shellcheck disable=SC2329  # the check functions are invoked indirectly through t()
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
# shellcheck source=scripts/test/lib.sh
. "$here/lib.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export GIT_CONFIG_GLOBAL=$tmp/gitconfig GIT_CONFIG_SYSTEM=/dev/null
git config --global user.email test@example.com; git config --global user.name test
git config --global protocol.file.allow always; git config --global init.defaultBranch main

git init -q "$tmp/up"
mkdir -p "$tmp/up/skills/a"
printf -- '---\nname: a\ndescription: a\n---\n' > "$tmp/up/skills/a/SKILL.md"
git -C "$tmp/up" add -A; git -C "$tmp/up" commit -qm one

git init -q "$tmp/parent"
cp -r "$root/scripts" "$tmp/parent/scripts"
printf 'skills:\n  - name: a\n    source: { submodule: upstream/up, path: skills/a }\n' > "$tmp/parent/skills.yaml"
git -C "$tmp/parent" submodule add -q -b main --depth 1 "file://$tmp/up" upstream/up
git -C "$tmp/parent" add -A; git -C "$tmp/parent" commit -qm base
pin=$(git -C "$tmp/parent/upstream/up" rev-parse HEAD)

status=0
t() { local d=$1; shift; if "$@"; then pass "$d"; else printf 'FAIL: %s\n' "$d"; status=1; fi; }
run() { "$tmp/parent/scripts/update-upstream.sh" "$@" > "$tmp/out" 2>&1; }
pin_is() { [ "$(git -C "$tmp/parent/upstream/up" rev-parse HEAD)" = "$1" ]; }
says() { grep -qE -- "$1" "$tmp/out"; }

run
t "an unchanged upstream reports no updates" says 'no updates'

printf 'more\n' >> "$tmp/up/skills/a/SKILL.md"
git -C "$tmp/up" commit -qam two
run
t "a new upstream commit is reported with the skill that changed" says 'skill a +1 file\(s\) changed'
t "report-only leaves the pin alone" pin_is "$pin"

run --apply
t "--apply moves the pin" bash -c "! [ \"\$(git -C '$tmp/parent/upstream/up' rev-parse HEAD)\" = '$pin' ]"
t "--apply stages the new pin" bash -c "git -C '$tmp/parent' diff --cached --submodule=short | grep -q 'upstream/up'"
exit "$status"
