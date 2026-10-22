#!/usr/bin/env bash
# Put back what install.sh replaced, from one of its backup directories.
#
#   restore.sh <backup-dir> [--dry-run]
#
# <backup-dir> is one of ~/.yumi-backup/install-<timestamp>. Each item in it is
# copied back over the current target (a link is removed first). Items that did
# not exist before the install have no backup and are left in place; restore
# lists them at the end, because a restore is not an uninstall.
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

need gomplate
backup=${1:-}; shift || true
dry=0
for arg in "$@"; do
  case $arg in
    --dry-run) dry=1 ;;
    *) die "unknown option: $arg" ;;
  esac
done
[ -n "$backup" ] && [ -d "$backup" ] || die "usage: restore.sh <backup-dir> [--dry-run]"
backup=$(cd "$backup" && pwd)

count=0
restore_one() { # restore_one <backup-item> <target>
  count=$((count + 1))
  if [ "$dry" -eq 1 ]; then printf 'restore %s <- %s\n' "$2" "$1"; return; fi
  mkdir -p "$(dirname "$2")"
  if [ -L "$2" ] || [ -f "$2" ]; then rm -f -- "$2"; elif [ -d "$2" ]; then rm -rf -- "$2"; fi
  cp -a -- "$1" "$2"
  printf 'restored %s\n' "$2"
}

for plat in claude codex; do
  [ -d "$backup/$plat" ] || continue
  if [ "$plat" = claude ]; then home=$(claude_home); else home=$(codex_home); fi
  shopt -s nullglob dotglob
  for item in "$backup/$plat"/*; do
    case $(basename "$item") in agents|skills) continue ;; esac
    restore_one "$item" "$home/$(basename "$item")"
  done
  for item in "$backup/$plat"/agents/*; do restore_one "$item" "$home/agents/$(basename "$item")"; done
  for item in "$backup/$plat"/skills/*; do
    valid_skill_name "$(basename "$item")" || { log "skip $item: unsafe name"; continue; }
    restore_one "$item" "$home/skills/$(basename "$item")"
  done
  shopt -u nullglob dotglob
done

# Manifest skills that exist now but have no copy in this backup were created by
# the install; say so instead of letting the restore look like a full undo.
kept=()
while IFS=$YUMI_FS read -r name kind _ _ platforms _; do
  [ "$kind" = external ] && continue
  for plat in claude codex; do
    case ",$platforms," in *,"$plat",*) ;; *) continue ;; esac
    if [ "$plat" = claude ]; then home=$(claude_home); else home=$(codex_home); fi
    [ -e "$home/skills/$name" ] || [ -L "$home/skills/$name" ] || continue
    [ -e "$backup/$plat/skills/$name" ] || [ -L "$backup/$plat/skills/$name" ] || kept+=("$plat/skills/$name")
  done
done < <(skill_rows)
if [ "${#kept[@]}" -gt 0 ]; then
  log "restore: left in place because this backup has no copy (they did not exist before the install): ${kept[*]}"
fi

if [ "$count" -eq 0 ]; then log "restore: nothing to restore in $backup"
elif [ "$dry" -eq 1 ]; then log "restore: dry run, $count item(s); nothing written"
else log "restore: $count item(s) restored from $backup"; fi
