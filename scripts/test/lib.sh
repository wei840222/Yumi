#!/usr/bin/env bash
# Helpers shared by the test scripts.

# baseline_dir: directory holding the pre-migration copies of the live files.
# YUMI_BASELINE overrides; otherwise the newest ~/.yumi-backup/baseline-*.
baseline_dir() {
  if [ -n "${YUMI_BASELINE:-}" ]; then printf '%s\n' "$YUMI_BASELINE"; return; fi
  local d
  d=$(find "${HOME}/.yumi-backup" -maxdepth 1 -type d -name 'baseline-*' 2>/dev/null | sort | tail -n 1)
  printf '%s\n' "$d"
}

skip() { printf 'SKIP: %s\n' "$*"; exit 0; }
fail() { printf 'FAIL: %s\n' "$*"; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }
