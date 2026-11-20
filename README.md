# rapido-mcp

An MCP server that lets an AI agent search Rapido locations, estimate fares, book rides (bike taxi, auto, cab), track them and cancel them.

Status: pre-spec. The interface is being pinned down; see [`docs/reviews/decision-log.md`](docs/reviews/decision-log.md) for what is settled and why.

## This repo is an Obsidian vault

The repo root is the vault root. Every `.md` file tracked by git is a note, and every note renders on GitHub without the app.

Start at [`notes/Home.md`](notes/Home.md).

| Folder | Holds |
|---|---|
| `notes/learning/` | The MCP, code-mode, runtime and API-robustness references. |
| `notes/project/` | What we are building, what is verified about Rapido's API, and the open questions. |
| `notes/templates/` | Note skeletons. |
| `docs/adr/` | Architecture decision records. |
| `docs/reviews/` | The decision log, the change inventory and the prompt record. |
| `docs/agents/` | How the engineering skills consume this repo. |
| `CONTEXT.md` | Shared vocabulary. Use these words exactly. |

Obsidian configuration lives in `.obsidian/`. Configuration is committed; machine state (`workspace.json`, caches, plugin data) is ignored. Notes are plain Markdown with YAML properties, so an agent can read and write every note without Obsidian running.

## Build and test locally first

The server core — tool surface, schemas, ride lifecycle, backend interface, fixtures and tests — belongs in this repo.

The live client that talks to Rapido's undocumented consumer API is written and run locally, and is **not** pushed until the publication split has been decided. See [D-010](docs/reviews/decision-log.md) and [What is verified about Rapido's API](notes/project/rapido-api-uncertainty.md).

## Layout

- `AGENTS.md` — agent instructions for this repo.
- `docs/agents/` — issue tracker, triage label vocabulary, and domain doc layout.
- `docs/reviews/` — decision log, change inventory, prompt record.
- `docs/adr/` — architecture decision records.

## Workflow

Matt Pocock skills, configured by `/setup-matt-pocock-skills`:

- `/grill-with-docs` → `/to-spec` → `/to-tickets` → `/implement`
- Issues live in GitHub Issues via `gh`.

## The access question

Rapido publishes no developer API, no OpenAPI spec and no SDK. The consumer web API is undocumented, and Rapido's terms forbid automated programs that make multiple server requests per second. See [`docs/reviews/decision-log.md`](docs/reviews/decision-log.md) for the routes considered, and [`notes/project/rapido-api-uncertainty.md`](notes/project/rapido-api-uncertainty.md) for exactly which endpoints we verified ourselves.
