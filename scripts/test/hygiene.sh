#!/usr/bin/env bash
# The hygiene scan must pass on a clean tree and fail when a personal value is
# planted in a tracked file.
# shellcheck disable=SC2329  # the check functions are invoked indirectly through t()
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
# shellcheck source=scripts/test/lib.sh
. "$here/lib.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git init -q "$tmp/repo"
# The fixture's personal values are invented; the scan learns them from local.yaml,
# exactly as it learns the maintainer's real ones.
cat > "$tmp/repo/local.yaml" <<'YAML'
features: {bifrost: false, gitea: false}
gitea: {host: git.leaky-example.net, user: fixture-user, org: leaky-org, login: fixture-user@leaky-org, default_login: ghost-login@leaky-org, default_login_owner: ghost}
hindsight: {url: "https://mem.leaky-example.net/", bank: yumi}
bifrost: {url: "https://llm.leaky-example.net/mcp"}
YAML
printf 'nothing personal here\n' > "$tmp/repo/notes.txt"
git -C "$tmp/repo" add notes.txt

status=0
t() { local d=$1; shift; if "$@"; then pass "$d"; else printf 'FAIL: %s\n' "$d"; status=1; fi; }
scan_passes() { "$root/scripts/hygiene.sh" --root "$tmp/repo" --no-dist >/dev/null 2>&1; }
scan_fails()  { ! "$root/scripts/hygiene.sh" --root "$tmp/repo" --no-dist >/dev/null 2>&1; }

t "a clean tree passes" scan_passes
printf 'see wiki.leaky-example.net for details\n' > "$tmp/repo/leak.txt"
git -C "$tmp/repo" add leak.txt
t "a host under the registrable domain from local.yaml is caught" scan_fails
git -C "$tmp/repo" rm -qf leak.txt
t "removing it makes the scan pass again" scan_passes
printf 'owner: ghost-login\n' > "$tmp/repo/other.txt"
git -C "$tmp/repo" add other.txt
t "a login learned from local.yaml is caught" scan_fails
git -C "$tmp/repo" rm -qf other.txt
printf 'maintained by fixture-user\n' > "$tmp/repo/handle.txt"
git -C "$tmp/repo" add handle.txt
t "the public handle (gitea.user) is deliberately allowed" scan_passes
git -C "$tmp/repo" rm -qf handle.txt
mkdir -p "$tmp/repo/docs" "$tmp/repo/tasks"
printf 'host: wiki.leaky-example.net\n' > "$tmp/repo/docs/note.md"
git -C "$tmp/repo" add docs/note.md
t "a personal value under docs/ is no longer exempt" scan_fails
git -C "$tmp/repo" rm -qf docs/note.md
printf 'host: wiki.leaky-example.net\n' > "$tmp/repo/tasks/todo.md"
git -C "$tmp/repo" add tasks/todo.md
t "a personal value under tasks/ is no longer exempt" scan_fails
git -C "$tmp/repo" rm -qf tasks/todo.md
printf 'token = "sk-abcdefghijklmnopqrstuvwxyz0123456789"\n' > "$tmp/repo/cfg.txt"
git -C "$tmp/repo" add cfg.txt
t "a credential-shaped string is caught" scan_fails
git -C "$tmp/repo" rm -qf cfg.txt
printf -- '-----BEGIN OPENSSH PRIVATE KEY-----\n' > "$tmp/repo/key.txt"
git -C "$tmp/repo" add key.txt
t "a private-key header is caught" scan_fails
exit "$status"
