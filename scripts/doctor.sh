#!/usr/bin/env bash
# Read-only health check of the repo and of what is installed.
#
#   doctor.sh [--probe]
#
# Prints ok / warn / FAIL lines and exits 1 if anything FAILs. Warnings never
# change the exit code. It writes nothing under the repo or the install homes
# (scratch files live in a temporary directory).
#
#   --probe   also ask Codex, with a throw-away CODEX_HOME, whether it still
#             discovers a symlinked skill. No login or model call is needed.
#
# Environment: CLAUDE_HOME, CODEX_HOME, YUMI_DIST, YUMI_EPHEMERAL_GLOB,
# YUMI_SUBMODULE_STATUS_FILE (read instead of running git submodule status).
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

probe=0
for arg in "$@"; do
  case $arg in
    --probe) probe=1 ;;
    -h|--help) sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $arg" ;;
  esac
done

root=$(repo_root)
dist=${YUMI_DIST:-$root/dist}
chome=$(claude_home)
xhome=$(codex_home)
ephemeral_glob=${YUMI_EPHEMERAL_GLOB:-*/orca/workspaces/*}
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
fails=0 warns=0
ok()   { printf 'ok    %s\n' "$*"; }
warn() { printf 'warn  %s\n' "$*"; warns=$((warns + 1)); }
fail() { printf 'FAIL  %s\n' "$*"; fails=$((fails + 1)); }

# --- tools
for c in gomplate git python3; do
  if command -v "$c" >/dev/null 2>&1; then ok "tool: $c"; else fail "tool missing: $c"; fi
done
if command -v shellcheck >/dev/null 2>&1; then ok "tool: shellcheck"; else warn "tool missing: shellcheck (only needed for development)"; fi
command -v gomplate >/dev/null 2>&1 || { printf 'doctor: cannot continue without gomplate\n'; exit 1; }

# --- fresh render, compared with dist/ and with what is installed
fresh=$scratch/fresh
if YUMI_DIST="$fresh" "$root/scripts/build.sh" >/dev/null 2>"$scratch/build.err"; then
  ok "build: templates render with $(basename "$(local_values)")"
  if [ "$(basename "$(local_values)")" = local.example.yaml ]; then warn "values: using local.example.yaml (generic public defaults), not local.yaml"; fi
else
  fail "build: templates do not render ($(tail -n 1 "$scratch/build.err" | cut -c1-140))"
fi

if [ -d "$fresh" ]; then
  if [ -d "$dist" ]; then
    if diff -rq "$fresh" "$dist" >/dev/null 2>&1; then ok "dist/ is up to date"; else warn "dist/ is stale (run: make build)"; fi
  else
    warn "dist/ has not been built (run: make build)"
  fi

  check_installed() { # check_installed <rendered> <installed> <label>
    if [ ! -e "$2" ]; then fail "installed: $3 is missing ($2)"
    elif [ -L "$2" ]; then fail "installed: $3 is a symlink, expected a copied file"
    elif cmp -s "$1" "$2"; then ok "installed: $3 matches the repo"
    else fail "installed: $3 differs from the repo render (run: make install)"; fi
  }
  check_installed "$fresh/claude/CLAUDE.md" "$chome/CLAUDE.md" "CLAUDE.md"
  check_installed "$fresh/codex/AGENTS.md" "$xhome/AGENTS.md" "AGENTS.md"
  for f in "$fresh"/claude/agents/*.md; do
    [ -f "$f" ] && check_installed "$f" "$chome/agents/$(basename "$f")" "claude agent $(basename "$f")"
  done
  for f in "$fresh"/codex/agents/*.toml; do
    [ -f "$f" ] && check_installed "$f" "$xhome/agents/$(basename "$f")" "codex agent $(basename "$f")"
  done

  for f in "$fresh/codex/AGENTS.md" "$xhome/AGENTS.md"; do
    [ -f "$f" ] || continue
    size=$(wc -c < "$f")
    if [ "$size" -ge 32768 ]; then fail "size: $f is $size bytes; Codex truncates AGENTS.md at 32768"
    else ok "size: $(basename "$(dirname "$f")")/AGENTS.md is $size bytes (limit 32768)"; fi
  done
fi

# --- skills
check_link() { # check_link <name> <expected-source> <home-label> <home>
  local link=$4/skills/$1
  if [ ! -e "$link" ] && [ ! -L "$link" ]; then fail "skill $1 ($3): not installed"
  elif [ ! -L "$link" ]; then fail "skill $1 ($3): $link is a real directory, not a link (run: make install)"
  elif [ ! -e "$link" ]; then fail "skill $1 ($3): dangling link to $(readlink "$link")"
  elif [ "$(readlink "$link")" != "$2" ]; then fail "skill $1 ($3): points to $(readlink "$link"), expected $2"
  else
    # shellcheck disable=SC2254
    case $(readlink "$link") in $ephemeral_glob) fail "skill $1 ($3): link target is under a temporary worktree" ;; *) ok "skill $1 ($3): linked" ;; esac
  fi
}
rows=$(skill_rows) || { fail "skills.yaml cannot be read"; rows=""; }
check_dircopy() { # check_dircopy <name> <source-dir> <home-label> <home>
  local dst=$4/skills/$1
  if [ ! -e "$dst" ] && [ ! -L "$dst" ]; then fail "skill $1 ($3): not installed"
  elif [ -L "$dst" ]; then fail "skill $1 ($3): is a link, expected a copied directory (run: make install)"
  elif diff -rq "$2" "$dst" >/dev/null 2>&1; then ok "skill $1 ($3): copy matches the source"
  else fail "skill $1 ($3): copy differs from the source (run: make install)"; fi
}
while IFS=$YUMI_FS read -r name kind a b platforms codexmode; do
  [ -n "$name" ] || continue
  if ! valid_skill_name "$name"; then fail "skill '$name': not a safe directory name"; continue; fi
  if [ "$kind" = external ]; then
    if [ -e "$chome/skills/$name" ] || [ -e "$xhome/skills/$name" ]; then ok "skill $name: present (external)"
    else warn "skill $name: external ($a) and not found in either home"; fi
    continue
  fi
  if ! src=$(skill_source_dir "$kind" "$a" "$b"); then fail "skill $name: the source path in skills.yaml is empty, not a directory, or leaves the repository"; continue; fi
  if [ ! -f "$src/SKILL.md" ]; then fail "skill $name: $src/SKILL.md not found$([ "$kind" = submodule ] && printf ' (run: git submodule update --init --depth 1)')"; continue; fi
  # Frontmatter is the block between the first two "---" lines.
  fm=$(awk 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit} NR>1 {print}' "$src/SKILL.md")
  if ! grep -q '^name:' <<<"$fm" || ! grep -q '^description:' <<<"$fm"; then
    fail "skill $name: SKILL.md frontmatter lacks name or description"
  fi
  case ",$platforms," in *,claude,*) check_link "$name" "$src" claude "$chome" ;; esac
  case ",$platforms," in *,codex,*)
    if [ "$codexmode" = copy ]; then check_dircopy "$name" "$src" codex "$xhome"; else check_link "$name" "$src" codex "$xhome"; fi ;;
  esac
done <<<"$rows"

# --- submodules
if [ -n "${YUMI_SUBMODULE_STATUS_FILE:-}" ]; then sm=$(cat "$YUMI_SUBMODULE_STATUS_FILE"); else sm=$(git -C "$root" submodule status 2>/dev/null || true); fi
if [ -z "$sm" ]; then warn "submodules: none found"; else
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    path=$(awk '{print $2}' <<<"$line")
    case ${line:0:1} in
      -) fail "submodule $path: not initialized (run: git submodule update --init --depth 1)" ;;
      +) fail "submodule $path: not at the commit this repo pins (run: git submodule update --init --depth 1)" ;;
      U) fail "submodule $path: merge conflict" ;;
      *) ok "submodule $path: at the pinned commit" ;;
    esac
  done <<<"$sm"
fi

# --- public-release hygiene
if "$root/scripts/hygiene.sh" >"$scratch/hygiene.out" 2>&1; then ok "hygiene: no personal values in tracked files or the example build"
else fail "hygiene: personal values found ($(grep -c '^HIT' "$scratch/hygiene.out") hit(s); run: make hygiene)"; fi

# --- README and manifest agree
if [ -f "$root/README.md" ]; then
  readme=$({ grep -oE '^\| \*\*[^*]+\*\*' "$root/README.md" || true; } | sed -E 's/^\| \*\*//; s/\*\*$//' | sort -u)
  manifest=$(skill_rows | cut -d"$YUMI_FS" -f1 | sort -u)
  if [ -z "$readme" ]; then warn "README.md has no skills table"
  elif [ "$readme" = "$manifest" ]; then ok "README skills table matches the manifest"
  else warn "README skills table and the manifest differ: $(diff <(echo "$readme") <(echo "$manifest") | grep '^[<>]' | tr '\n' ' ')"; fi
else
  warn "README.md not found"
fi

# --- everything the README links to or embeds must be tracked (the .gitignore is a
# whitelist, so a new file is silently ignored until it is added to it)
if [ -f "$root/README.md" ] && git -C "$root" rev-parse --git-dir >/dev/null 2>&1; then
  untracked=()
  while IFS= read -r target; do
    case $target in ''|http://*|https://*|mailto:*|\#*) continue ;; esac
    target=${target%%#*}
    [ -n "$target" ] || continue
    if git -C "$root" ls-files --error-unmatch -- "$target" >/dev/null 2>&1 \
       || [ -n "$(git -C "$root" ls-files -- "${target%/}/" 2>/dev/null | head -n 1)" ]; then continue; fi
    untracked+=("$target")
  done < <({ grep -oE '\]\([^)]*\)' "$root/README.md" | sed -E 's/^\]\(//; s/\)$//'; grep -oE 'src="[^"]+"' "$root/README.md" | sed -E 's/^src="//; s/"$//'; } | sort -u)
  if [ "${#untracked[@]}" -eq 0 ]; then ok "README: every relative link and image points at a tracked file"
  else fail "README points at files that are not tracked by git: ${untracked[*]} (the .gitignore whitelist may be hiding them)"; fi
fi

# --- settings drift (informational: the repo never writes these files)
for p in claude codex; do
  rep=$("$root/scripts/settings-drift.sh" "$p" 2>/dev/null || true)
  miss=$(awk '/^## In the template/{f=1;next} /^## /{f=0} f&&/^- `/{n++} END{print n+0}' <<<"$rep")
  diffc=$(awk '/^## Different values/{f=1;next} /^## /{f=0} f&&/^- `/{n++} END{print n+0}' <<<"$rep")
  if grep -q 'Nothing to compare' <<<"$rep"; then warn "settings ($p): the live file is missing or unreadable"
  elif [ "$miss" -eq 0 ] && [ "$diffc" -eq 0 ]; then ok "settings ($p): the live file covers the template"
  else warn "settings ($p): $miss template key(s) missing and $diffc value(s) differ (run: make drift P=$p)"; fi
done

# --- optional: does Codex still discover a symlinked skill?
if [ "$probe" -eq 1 ]; then
  if ! command -v codex >/dev/null 2>&1; then warn "probe: codex is not installed"
  else
    pname="yumi-probe-$$-$RANDOM"
    mkdir -p "$scratch/probe/real/$pname" "$scratch/probe/home/skills"
    printf -- '---\nname: %s\ndescription: Probe for skill discovery. Use only if asked for %s.\n---\n\nProbe.\n' "$pname" "$pname" > "$scratch/probe/real/$pname/SKILL.md"
    ln -s "$scratch/probe/real/$pname" "$scratch/probe/home/skills/$pname"
    if CODEX_HOME="$scratch/probe/home" timeout 90 codex debug prompt-input hello 2>/dev/null </dev/null | grep -q "$pname"; then
      ok "probe: Codex discovers a symlinked skill under CODEX_HOME/skills"
    else
      fail "probe: Codex did not list the symlinked probe skill; the skills install path may no longer work"
    fi
  fi
fi

printf '\ndoctor: %d failure(s), %d warning(s)\n' "$fails" "$warns"
[ "$fails" -eq 0 ]
