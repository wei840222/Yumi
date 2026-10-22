.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

.PHONY: help build install restore doctor update-upstream handoff hygiene drift test

help: ## List targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | sed -E 's/:.*## /\t/' | column -t -s $$'\t'

build: ## Render dist/ from src/ with gomplate
	@scripts/build.sh

install: build ## Install into ~/.claude and ~/.codex (use ARGS=--dry-run to preview)
	@scripts/install.sh $(ARGS)

doctor: ## Read-only health check (add ARGS=--probe to test Codex skill discovery)
	@scripts/doctor.sh $(ARGS)

update-upstream: ## Report upstream skill updates (add ARGS=--apply to stage new pins)
	@scripts/update-upstream.sh $(ARGS)

restore: ## Put back what an install replaced: make restore B=~/.yumi-backup/install-<timestamp>
	@scripts/restore.sh $(B) $(ARGS)

handoff: ## Start claude or codex to finish settings (P=claude|codex; add ARGS=--print to preview)
	@scripts/handoff.sh $(P) $(ARGS)

hygiene: ## Scan tracked files and an example build for personal values
	@scripts/hygiene.sh

drift: ## Show how live settings differ from the templates (P=claude|codex)
	@scripts/settings-drift.sh $(P)

test: ## Run the script tests (temporary HOME)
	@scripts/test/run.sh
