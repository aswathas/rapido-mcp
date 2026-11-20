# rapido-mcp

MCP server for Rapido rides. Public repo.

## Start here

This repo is an Obsidian vault. The vault root is the repo root, so every `.md` file is a note and every note renders on GitHub.

- [`notes/Home.md`](notes/Home.md) — the map of content.
- [`CONTEXT.md`](CONTEXT.md) — shared vocabulary. Use those words exactly.
- [`notes/project/open-questions.md`](notes/project/open-questions.md) — the design interview's frontier, with a recommendation for each question.

## Agent skills

### Issue tracker

Issues and specs live as GitHub issues; use the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout: `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

### Notes

Vault notes live under `notes/`. They are plain Markdown with YAML properties, so they can be read and written without Obsidian running. See `notes/learning/obsidian-vault.md` for the conventions.
