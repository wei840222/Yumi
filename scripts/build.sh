#!/usr/bin/env bash
# Render dist/ from src/ with gomplate.
#
#   YUMI_LOCAL  personal-values file (default: local.yaml, else local.example.yaml)
#   YUMI_DIST   output directory (default: <repo>/dist)
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

root=$(repo_root)
dist=${YUMI_DIST:-$root/dist}
local_file=$(local_values)
need gomplate sha256sum

[ -f "$root/src/prompt/main.md.tmpl" ] \
  || die "no templates found: $root/src/prompt/main.md.tmpl is missing"
[ -f "$local_file" ] || die "personal values file not found: $local_file"

# render <platform> <template> <output>
render() {
  local platform=$1 template=$2 out=$3
  mkdir -p "$(dirname "$out")"
  gomplate \
    -c "platform=file://$root/platforms/$platform.yaml" \
    -c "local=file://$local_file" \
    -t "partials=$root/src/prompt/partials/" \
    -f "$template" -o "$out"
}

platforms=(claude codex)
for platform in "${platforms[@]}"; do
  prompt_file=$(gomplate -c "p=file://$root/platforms/$platform.yaml" -i '{{ .p.prompt_file }}')
  render "$platform" "$root/src/prompt/main.md.tmpl" "$dist/$platform/$prompt_file"
done

# render_agent <platform> <agent-dir> <template> <output>
render_agent() {
  local platform=$1 dir=$2 template=$3 out=$4
  mkdir -p "$(dirname "$out")"
  gomplate \
    -c "platform=file://$root/platforms/$platform.yaml" \
    -c "local=file://$local_file" \
    -c "meta=file://$dir/meta.yaml" \
    -t "partials=$dir/partials/" \
    -t "body=$dir/body.md.tmpl" \
    -f "$template" -o "$out"
}

for dir in "$root"/src/agents/*/; do
  dir=${dir%/}
  name=$(basename "$dir")
  render_agent claude "$dir" "$dir/claude.md.tmpl" "$dist/claude/agents/$name.md"
  render_agent codex "$dir" "$dir/codex.toml.tmpl" "$dist/codex/agents/$name.toml"
done

# Codex reads at most project_doc_max_bytes (32 KiB by default) of AGENTS.md.
agents_md=$dist/codex/AGENTS.md
if [ -f "$agents_md" ]; then
  size=$(wc -c < "$agents_md")
  [ "$size" -lt 32768 ] || die "$agents_md is $size bytes; Codex truncates at 32768"
fi

# Record which values file produced dist/ ("<sha256> <path>"). install.sh re-renders
# from that file and compares, so this stamp is a pointer, not something to trust.
printf '%s %s\n' "$(sha256sum "$local_file" | cut -d' ' -f1)" "$local_file" > "$dist/.values"

log "build: rendered into $dist (values: $local_file)"
