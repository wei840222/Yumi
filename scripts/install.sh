#!/usr/bin/env bash
# Install the rendered prompts and agents (copied) and the manifest's skills
# (symlinked, or copied where the manifest says so) into the Claude Code and
# Codex homes.
#
#   install.sh [--dry-run] [--allow-ephemeral] [--require-local]
#
#   --require-local   refuse to install files rendered from local.example.yaml
#                     (the generic public defaults) instead of your local.yaml
#
# Environment: CLAUDE_HOME, CODEX_HOME (install targets), YUMI_DIST (rendered
# files), YUMI_BACKUP_DIR (default ~/.yumi-backup), YUMI_EPHEMERAL_GLOB.
#
# Only paths named by the manifest or by dist/ are touched. Before anything is
# changed, dist/ must equal a fresh render of the values file recorded when it
# was built, and every existing target is copied into the backup directory. The
# changes are then applied one item at a time: the old target is moved aside,
# the new one put in place, and if any step fails every item is put back as it
# was. Settings files, credentials, history, sessions, skills/synced,
# skills/.system, and ~/.agents are never read or written.
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

dry=0 allow_eph=0 require_local=0
while [ $# -gt 0 ]; do
  case $1 in
    --dry-run) dry=1 ;;
    --allow-ephemeral) allow_eph=1 ;;
    --require-local) require_local=1 ;;
    -h|--help) sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
  shift
done

root=$(repo_root)
dist=${YUMI_DIST:-$root/dist}
chome=$(claude_home)
xhome=$(codex_home)
ephemeral_glob=${YUMI_EPHEMERAL_GLOB:-*/orca/workspaces/*}
backup_root=${YUMI_BACKUP_DIR:-$HOME/.yumi-backup}/install-$(date +%Y%m%d-%H%M%S)
need gomplate cmp sha256sum realpath

[ -d "$dist/claude" ] && [ -d "$dist/codex" ] || die "$dist has no rendered files; run 'make build' first"

# --- which values produced dist/, and is dist/ still exactly that render?
scratch=$(mktemp -d)
applied=()        # one record per item touched in phase 2: "<target><FS><aside or empty>"
install_done=0

rollback() {
  [ "$install_done" -eq 0 ] && [ "${#applied[@]}" -gt 0 ] || return 0
  log "install: failed; putting ${#applied[@]} item(s) back as they were"
  local i d o
  for ((i = ${#applied[@]} - 1; i >= 0; i--)); do
    IFS=$YUMI_FS read -r d o <<<"${applied[i]}"
    # Only remove what this run created: a path strictly inside one of the two homes.
    case $d in "$chome"/?*|"$xhome"/?*) ;; *) log "install: not removing unexpected path '$d' during rollback"; continue ;; esac
    case ${d##*/} in .|..) continue ;; esac
    rm -rf -- "$d" "$d.yumi-new" 2>/dev/null || true
    if [ -n "$o" ] && { [ -e "$o" ] || [ -L "$o" ]; }; then mv -- "$o" "$d" 2>/dev/null || log "could not restore $d; the original is at $o and in $backup_root"; fi
  done
  log "install: rolled back; backups of the originals are in $backup_root"
}
cleanup() { rollback; rm -rf -- "$scratch"; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

stamp=$(cat "$dist/.values" 2>/dev/null || true)
vhash=${stamp%% *}
vpath=${stamp#* }
example_hash=$(sha256sum "$root/local.example.yaml" | cut -d' ' -f1)
if [ -z "$stamp" ] || [ "$vhash" = "$stamp" ] || [ -z "$vpath" ]; then
  die "$dist/.values is missing or malformed; run 'make build'"
fi
[ -f "$vpath" ] || die "dist/ was rendered from $vpath, which no longer exists; run 'make build'"
log "install: rendered files come from $vpath"

is_example=0
if [ "$(basename "$vpath")" = local.example.yaml ] || [ "$vhash" = "$example_hash" ]; then is_example=1; fi
if [ "$is_example" -eq 1 ]; then
  log "warning: these files use the generic public defaults, not your personal values"
  [ "$require_local" -eq 0 ] || die "--require-local was given but dist/ was rendered from the example values; create local.yaml (or set YUMI_LOCAL) and run make build"
fi

# The stamp is only a label. What matters is that dist/ equals a fresh render of
# the file it names, so an edited stamp, an edited dist/, or values that changed
# since the build are all refused.
YUMI_LOCAL=$vpath YUMI_DIST=$scratch/fresh "$root/scripts/build.sh" >/dev/null 2>&1 \
  || die "cannot re-render from $vpath to check dist/"
if ! diff -rq -x .values "$scratch/fresh" "$dist" >/dev/null 2>&1; then
  die "dist/ is not a fresh render of $vpath (it was edited, or the values changed since the build); run 'make build'"
fi

# --- plan
# actions: kind FS source FS destination FS backup-label (label = home-relative path under the backup root)
actions=()
unchanged=0
problems=()

plan_copy() { # plan_copy <src> <dst> <label>
  if [ -f "$2" ] && [ ! -L "$2" ] && cmp -s "$1" "$2"; then unchanged=$((unchanged + 1))
  else actions+=("copy$YUMI_FS$1$YUMI_FS$2$YUMI_FS$3"); fi
}
plan_dircopy() { # plan_dircopy <src-dir> <dst> <label>
  if [ -d "$2" ] && [ ! -L "$2" ] && diff -rq "$1" "$2" >/dev/null 2>&1; then unchanged=$((unchanged + 1))
  else actions+=("dircopy$YUMI_FS$1$YUMI_FS$2$YUMI_FS$3"); fi
}
plan_link() { # plan_link <src> <dst> <label>
  if [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]; then unchanged=$((unchanged + 1))
  else actions+=("link$YUMI_FS$1$YUMI_FS$2$YUMI_FS$3"); fi
}

# Prompts and agents.
plan_copy "$dist/claude/CLAUDE.md" "$chome/CLAUDE.md" "claude/CLAUDE.md"
plan_copy "$dist/codex/AGENTS.md" "$xhome/AGENTS.md" "codex/AGENTS.md"
for f in "$dist"/claude/agents/*.md; do
  [ -f "$f" ] && plan_copy "$f" "$chome/agents/$(basename "$f")" "claude/agents/$(basename "$f")"
done
for f in "$dist"/codex/agents/*.toml; do
  [ -f "$f" ] && plan_copy "$f" "$xhome/agents/$(basename "$f")" "codex/agents/$(basename "$f")"
done

# Skills, from the manifest.
rows=$(skill_rows) || die "cannot read skills.yaml"
while IFS=$YUMI_FS read -r name kind a b platforms codexmode; do
  [ -n "$name" ] || continue
  if ! valid_skill_name "$name"; then problems+=("skill name '$name' is not a safe directory name"); continue; fi
  if [ "$kind" = external ]; then log "skip   $name (external: $a)"; continue; fi
  if ! src=$(skill_source_dir "$kind" "$a" "$b"); then problems+=("$name: the source path in skills.yaml leaves the repository"); continue; fi
  if [ ! -f "$src/SKILL.md" ] || [ ! -d "$src" ]; then
    problems+=("$name: $src/SKILL.md not found$([ "$kind" = submodule ] && printf ' (run: git submodule update --init --depth 1)')")
    continue
  fi
  # shellcheck disable=SC2254
  case $src in $ephemeral_glob)
    if [ "$allow_eph" -eq 0 ]; then problems+=("$name: source $src is under a temporary worktree; install from the main checkout, or pass --allow-ephemeral for tests"); continue; fi ;;
  esac
  case ",$platforms," in *,claude,*) plan_link "$src" "$chome/skills/$name" "claude/skills/$name" ;; esac
  case ",$platforms," in *,codex,*)
    if [ "$codexmode" = copy ]; then plan_dircopy "$src" "$xhome/skills/$name" "codex/skills/$name"
    else plan_link "$src" "$xhome/skills/$name" "codex/skills/$name"; fi ;;
  esac
done <<<"$rows"

if [ "${#problems[@]}" -gt 0 ]; then
  for p in "${problems[@]}"; do log "error: $p"; done
  exit 1
fi

if [ "${#actions[@]}" -eq 0 ]; then
  log "install: no changes ($unchanged items already up to date)"
  exit 0
fi

for a in "${actions[@]}"; do
  IFS=$YUMI_FS read -r kind src dst label <<<"$a"
  case $kind in
    copy) printf 'copy   %s\n' "$dst" ;;
    dircopy) printf 'copy   %s/ (directory)\n' "$dst" ;;
    *) printf 'link   %s -> %s\n' "$dst" "$src" ;;
  esac
  if [ -e "$dst" ] || [ -L "$dst" ]; then printf '       (existing target is backed up to %s/%s)\n' "$backup_root" "$label"; fi
done

if [ "$dry" -eq 1 ]; then
  log "install: dry run, ${#actions[@]} change(s) planned, $unchanged unchanged; nothing written"
  exit 0
fi

# --- phase 1: back everything up. Any failure aborts before a target is modified.
for a in "${actions[@]}"; do
  IFS=$YUMI_FS read -r kind src dst label <<<"$a"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$(dirname "$backup_root/$label")" \
      || die "cannot create backup directory under $backup_root; nothing was changed"
    cp -a -- "$dst" "$backup_root/$label" \
      || die "backup of $dst failed; nothing was changed"
  fi
done

# --- phase 2: apply, one item at a time. The old target is moved aside first,
# so a failure at any point leaves something to put back; the asides are deleted
# only after every item has succeeded.
for a in "${actions[@]}"; do
  IFS=$YUMI_FS read -r kind src dst label <<<"$a"
  mkdir -p "$(dirname "$dst")"
  aside=""
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    aside=$dst.yumi-old.$$
    mv -- "$dst" "$aside" || die "cannot move $dst aside; nothing further was changed"
  fi
  applied+=("$dst$YUMI_FS$aside")
  case $kind in
    copy)
      cp -- "$src" "$dst.yumi-new" || die "installing $dst failed"
      mv -f -- "$dst.yumi-new" "$dst" || die "installing $dst failed" ;;
    dircopy)
      cp -a -- "$src" "$dst.yumi-new" || die "installing $dst failed"
      mv -- "$dst.yumi-new" "$dst" || die "installing $dst failed" ;;
    link)
      ln -s -- "$src" "$dst" || die "linking $dst failed" ;;
  esac
done

install_done=1
for rec in "${applied[@]}"; do
  IFS=$YUMI_FS read -r d o <<<"$rec"
  [ -z "$o" ] || rm -rf -- "$o" || log "warning: could not remove the old copy $o (the backup in $backup_root is complete)"
done

log "install: ${#actions[@]} change(s) applied, $unchanged unchanged; backups in $backup_root"
