# rapido-mcp

An MCP server that lets an AI agent search Rapido locations, estimate fares, book rides (bike taxi, auto, cab), track them and cancel them.

Status: pre-spec. The interface is being pinned down; see `docs/reviews/decision-log.md` for what is settled and why.

## Layout

- `AGENTS.md` — agent instructions for this repo.
- `docs/agents/` — issue tracker, triage label vocabulary, and domain doc layout.
- `docs/reviews/` — decision log, change inventory, prompt record.
- `docs/adr/` — architecture decision records.
- `CONTEXT.md` — domain glossary (created once terms are settled).

## Workflow

Matt Pocock skills, configured by `/setup-matt-pocock-skills`:

- `/grill-with-docs` → `/to-spec` → `/to-tickets` → `/implement`
- Issues live in GitHub Issues via `gh`.

## The access question

Rapido publishes no developer API, no OpenAPI spec and no SDK. See `docs/reviews/decision-log.md` for the routes considered and the terms-of-service finding that constrains this project.
