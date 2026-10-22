#!/usr/bin/env bash
# Start claude or codex with a prompt that finishes the settings step.
#
#   handoff.sh claude|codex [--print]
#
# Builds a read-only drift report (template vs the live settings file) and a
# prompt that points at it, then execs the CLI with that prompt. The script
# edits nothing itself; the agent asks before every write. With --print it only
# shows the prompt and the report path.
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

platform=${1:-}; shift || true
print_only=0
for arg in "$@"; do
  case $arg in
    --print) print_only=1 ;;
    *) die "unknown option: $arg" ;;
  esac
done

root=$(repo_root)
case $platform in
  claude) home=$(claude_home); template=$root/templates/claude/settings.json; live=$home/settings.json; cli=claude ;;
  codex)  home=$(codex_home);  template=$root/templates/codex/config.toml;    live=$home/config.toml;   cli=codex ;;
  *) die "usage: handoff.sh claude|codex [--print]" ;;
esac
need gomplate python3
[ "$print_only" -eq 1 ] || need "$cli"

report=$(mktemp "${TMPDIR:-/tmp}/yumi-handoff-$platform.XXXXXX.md")
"$root/scripts/settings-drift.sh" "$platform" > "$report"

prompt=$(YUMI_REPO=$root YUMI_HOME=$home YUMI_TEMPLATE=$template YUMI_LIVE=$live YUMI_REPORT=$report \
  gomplate -f "$root/src/handoff/$platform.md")

if [ "$print_only" -eq 1 ]; then
  printf '%s\n\n(report: %s)\n' "$prompt" "$report"
  exit 0
fi
log "handoff: starting $cli with the settings prompt (report: $report)"
exec "$cli" "$prompt"
