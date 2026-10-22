#!/usr/bin/env bash
# handoff.sh with fake claude/codex executables: the right arguments arrive, the
# report never contains secret values, and no settings file is modified.
# shellcheck disable=SC2329,SC2016  # check functions run through t(); the backticks are literal report text
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
# shellcheck source=scripts/test/lib.sh
. "$here/lib.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME=$tmp/home CLAUDE_HOME=$tmp/home/.claude CODEX_HOME=$tmp/home/.codex TMPDIR=$tmp
mkdir -p "$CLAUDE_HOME" "$CODEX_HOME" "$tmp/bin"
cat > "$CLAUDE_HOME/settings.json" <<'JSON'
{"model": "opus", "apiKeyHelper": "SECRET-VALUE-123", "permissions": {"defaultMode": "auto"}}
JSON
cat > "$CODEX_HOME/config.toml" <<'TOML'
model = "keep"
[mcp_servers.x]
http_headers = { "x-bf-vk" = "SECRET-VALUE-456" }
TOML
for cli in claude codex; do
  cat > "$tmp/bin/$cli" <<FAKE
#!/usr/bin/env bash
printf '%s\n' "\$#" > "$tmp/$cli.argc"
printf '%s' "\$1" > "$tmp/$cli.prompt"
FAKE
  chmod +x "$tmp/bin/$cli"
done
export PATH=$tmp/bin:$PATH
before=$(sha256sum "$CLAUDE_HOME/settings.json" "$CODEX_HOME/config.toml")

status=0
t() { local d=$1; shift; if "$@"; then pass "$d"; else printf 'FAIL: %s\n' "$d"; status=1; fi; }
one_arg()        { [ "$(cat "$tmp/$1.argc")" = 1 ]; }
mentions()       { grep -q -- "$2" "$tmp/$1.prompt"; }
report_of()      { grep -o '/[^ )]*yumi-handoff-'"$1"'[^ )]*\.md' "$tmp/$1.prompt" | head -n 1; }
no_secret()      { ! grep -rq 'SECRET-VALUE' "$tmp/$1.prompt" "$(report_of "$1")"; }
shows_difference() { grep -qF 'template `"sonnet"`, live `"opus"`' "$(report_of claude)"; }
settings_intact() { [ "$(sha256sum "$CLAUDE_HOME/settings.json" "$CODEX_HOME/config.toml")" = "$before" ]; }

for p in claude codex; do
  "$root/scripts/handoff.sh" "$p" >/dev/null 2>&1
  t "$p: the CLI receives exactly one argument" one_arg "$p"
  t "$p: the prompt names the template" mentions "$p" "templates/$p/"
  t "$p: the prompt asks before writing" mentions "$p" 'Ask me before writing'
  t "$p: the prompt forbids touching credentials" mentions "$p" 'Do not print, copy, or move credentials'
  t "$p: no secret value reaches the prompt or the report" no_secret "$p"
done
t "claude: the report shows a changed value" shows_difference
t "settings files were not modified" settings_intact
exit "$status"
