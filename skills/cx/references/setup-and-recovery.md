# cx Setup and Recovery

## First-Run Checks

```bash
command -v cx
cx overview .
cx lang list
```

Run `cx overview .` as the initial project probe. If a grammar is missing, cx
prints detected languages and the exact `cx lang add ...` command to run.

## Installation

```bash
brew tap ind-igo/cx && brew install cx
cargo install cx-cli
curl -sL https://raw.githubusercontent.com/ind-igo/cx/master/install.sh | sh
```

Install required grammars as needed:

```bash
cx lang add rust typescript python go swift dart
```

Set `CX_CACHE_DIR` when the default cache location is not writable in a sandbox.

## Failure Modes

### `cx: unsupported file type: .yaml`

Use normal read tools for YAML, JSON, TOML, binary files, and non-symbol regions.

### `cx: database locked, waiting...`

Wait two or three seconds and retry. If the lock persists, run `cx cache clean`.
Use process inspection only as a last resort for a stale cx process.

### `cx: file not in index: <path>`

Ensure the file is within the git root, or pass `--root <path>` for the intended
project boundary.

### `cx: missing grammar for <language>`

Install the grammar with `cx lang add <language>`, then rerun the query.

### `cx: symbol not found: <name>`

Search with a glob such as `cx symbols --name "*partial*"`, inspect the file with
`cx overview`, and verify spelling and case before retrying.
