#!/usr/bin/env bash
# Read-only report of how a live settings file differs from its template.
#
#   settings-drift.sh claude|codex
#
# Prints Markdown. Values are shown only for keys the template defines, and
# anything whose name looks like a secret is redacted. Keys that exist only in
# the live file are listed by name and never by value.
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

platform=${1:-}
root=$(repo_root)
case $platform in
  claude) template=$root/templates/claude/settings.json live=$(claude_home)/settings.json ;;
  codex)  template=$root/templates/codex/config.toml    live=$(codex_home)/config.toml ;;
  *) die "usage: settings-drift.sh claude|codex" ;;
esac
need python3

python3 -I - "$platform" "$template" "$live" "$HOME" <<'PY'
import json, os, re, sys, tomllib

platform, template_path, live_path, home = sys.argv[1:5]
SECRET = re.compile(r"(token|secret|password|passwd|credential|api[-_]?key|authorization|x-bf-vk|auth)", re.I)

def load(path):
    if not os.path.exists(path):
        return None
    with open(path, "rb") as f:
        return json.load(f) if path.endswith(".json") else tomllib.load(f)

def expand(v):
    if isinstance(v, str):
        return v.replace("$HOME", home)
    if isinstance(v, list):
        return [expand(x) for x in v]
    if isinstance(v, dict):
        return {k: expand(x) for k, x in v.items()}
    return v

def show(path, v):
    if SECRET.search(path):
        return "«redacted»"
    s = json.dumps(v, ensure_ascii=False)
    return s if len(s) <= 100 else s[:97] + "..."

missing, differs, live_only, unreadable = [], [], [], None
tpl = load(template_path)
try:
    live = load(live_path)
except Exception as e:  # unreadable or invalid live file
    live, unreadable = None, str(e)

def walk(t, l, path):
    for k, tv in t.items():
        p = f"{path}.{k}" if path else k
        if not isinstance(l, dict) or k not in l:
            missing.append((p, tv)); continue
        lv = l[k]
        if isinstance(tv, dict) and isinstance(lv, dict):
            walk(tv, lv, p)
        elif isinstance(tv, list) and isinstance(lv, list):
            for item in tv:
                if item not in lv:
                    missing.append((f"{p}[]", item))
        elif tv != lv:
            differs.append((p, tv, lv))
    if isinstance(l, dict):
        for k in l:
            if k not in t:
                live_only.append(f"{path}.{k}" if path else k)

print(f"# Settings drift: {platform}\n")
print(f"- template: `{template_path}`")
print(f"- live: `{live_path}`\n")
if live is None:
    print(f"The live file {'is unreadable: ' + unreadable if unreadable else 'does not exist'}. Nothing to compare.")
    sys.exit(0)
walk(expand(tpl), live, "")
print("## In the template but missing from the live file\n")
print("\n".join(f"- `{p}` = `{show(p, v)}`" for p, v in missing) or "- none")
print("\n## Different values\n")
print("\n".join(f"- `{p}`: template `{show(p, a)}`, live `{show(p, b)}`" for p, a, b in differs) or "- none")
print("\n## Only in the live file (names only; keep these)\n")
print("\n".join(f"- `{p}`" for p in sorted(live_only)) or "- none")
PY
