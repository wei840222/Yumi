#!/usr/bin/env bash
# Shared helpers for the Yumi scripts. Source this file; do not execute it.

repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

log() { printf '%s\n' "$*" >&2; }
die() { log "error: $*"; exit 1; }

# need <command>...: fail with a clear message when a tool is missing.
need() {
  local missing=0 c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || { log "missing required command: $c"; missing=1; }
  done
  [ "$missing" -eq 0 ] || exit 1
}

# local_values: path of the personal-values file. YUMI_LOCAL overrides; otherwise
# local.yaml wins and the committed example is the public default, so a fresh
# clone can still build.
local_values() {
  local root; root=$(repo_root)
  if [ -n "${YUMI_LOCAL:-}" ]; then
    # file:// URLs need an absolute path; a relative one is read as a host name.
    realpath -- "$YUMI_LOCAL" 2>/dev/null || printf '%s\n' "$YUMI_LOCAL"
  elif [ -f "$root/local.yaml" ]; then
    printf '%s\n' "$root/local.yaml"
  else
    printf '%s\n' "$root/local.example.yaml"
  fi
}

# Install targets can be redirected for tests.
claude_home() { printf '%s\n' "${CLAUDE_HOME:-$HOME/.claude}"; }
codex_home()  { printf '%s\n' "${CODEX_HOME:-$HOME/.codex}"; }

# Field separator for records that carry free text (manifest notes, paths): the
# ASCII unit separator, which cannot appear in YAML text and is not whitespace,
# so empty fields survive `read`.
# shellcheck disable=SC2034  # used by the scripts that source this file
YUMI_FS=$'\037'

# skill_rows: one line per manifest entry, fields separated by $YUMI_FS:
#   name local <path> "" <platforms> <codex-mode>
#   name submodule <submodule> <path> <platforms> <codex-mode>
#   name external <note> "" <platforms> <codex-mode>
# <codex-mode> is "link" (default) or "copy". Codex namespaces a skill that sits
# inside an upstream plugin ("plugin:skill") when it is reached through a link,
# so such skills are copied into the Codex home to keep their plain names.
skill_rows() {
  local root; root=$(repo_root)
  # shellcheck disable=SC2016  # the template is a gomplate expression, not shell
  gomplate -c "m=file://$root/skills.yaml" -i '{{ $s := "\x1f" }}{{ range .m.skills -}}
{{ .name }}{{ $s }}{{ if has .source "local" }}local{{ $s }}{{ .source.local }}{{ $s }}{{ else if has .source "submodule" }}submodule{{ $s }}{{ .source.submodule }}{{ $s }}{{ .source.path }}{{ else }}external{{ $s }}{{ .source.external }}{{ $s }}{{ end }}{{ $s }}{{ if has . "platforms" }}{{ range $i, $p := .platforms }}{{ if $i }},{{ end }}{{ $p }}{{ end }}{{ else }}claude,codex{{ end }}{{ $s }}{{ if and (has . "install") (has .install "codex") }}{{ .install.codex }}{{ else }}link{{ end }}
{{ end }}'
}

# skill_source_dir <kind> <a> <b>: the skill's directory, or empty for external.
# Fails (status 1) when the manifest path would leave the repo: a ".." segment,
# or a symlink that resolves outside the allowed base.
skill_source_dir() {
  local root p base
  root=$(repo_root)
  case $1 in
    local) p=$root/$2; base=$root ;;
    submodule) base=$root/$2; if [ "$3" = "." ]; then p=$base; else p=$base/$3; fi ;;
    *) printf '\n'; return 0 ;;
  esac
  if [[ "/$2/$3/" == *"/../"* ]]; then return 1; fi
  case $1 in local) [ -n "$2" ] || return 1 ;; submodule) [ -n "$2" ] && [ -n "$3" ] || return 1 ;; esac
  local rp rb rr
  rp=$(realpath -m -- "$p"); rb=$(realpath -m -- "$base"); rr=$(realpath -m -- "$root")
  case $rb in "$rr"|"$rr"/*) ;; *) return 1 ;; esac
  case $rp in "$rb"|"$rb"/*) ;; *) return 1 ;; esac
  # A missing path is reported by the caller (it may just be an uninitialised submodule);
  # a path that exists but is not a directory can never be a skill.
  if [ -e "$p" ] && [ ! -d "$p" ]; then return 1; fi
  printf '%s\n' "$p"
}

# valid_skill_name <name>: names become directory names under <home>/skills, so
# keep them to a safe character set (no slashes, no leading dot).
valid_skill_name() {
  [[ $1 =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] && [ "$1" != "." ] && [ "$1" != ".." ]
}

# personal_patterns <values-file>: one search pattern per line, derived from the
# hosts, organisations, and logins in a values file (normally the maintainer's
# local.yaml), so no personal string is ever written into a tracked file. For a
# host it also yields the registrable domain (last two labels); for "a@b" both
# sides. gitea.user is the public handle and is deliberately not a pattern.
personal_patterns() {
  [ -f "$1" ] || return 0
  command -v gomplate >/dev/null 2>&1 || return 0
  # shellcheck disable=SC2016  # the template is a gomplate expression, not shell
  gomplate -c "l=file://$1" -i '{{ .l.gitea.user }}
{{ range $v := coll.Slice .l.gitea.host .l.gitea.org .l.gitea.login .l.gitea.default_login .l.hindsight.url .l.bifrost.url }}{{ $v }}
{{ end }}' 2>/dev/null | python3 -I -c '
import re, sys
lines = [l.strip() for l in sys.stdin]
public = lines[0] if lines else ""
out = set()
for v in lines[1:]:
    v = re.sub(r"^[a-z]+://", "", v)
    for part in re.split(r"[@:/]", v):
        part = part.strip()
        if len(part) < 4 or part == public:
            continue
        out.add(part)
        labels = part.split(".")
        if len(labels) >= 3 and all(len(x) >= 2 for x in labels[-2:]):
            out.add(".".join(labels[-2:]))
print("\n".join(sorted(out)))
'
}
