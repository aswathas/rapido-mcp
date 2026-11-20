---
title: Home
type: index
tags:
  - map-of-content
updated: 2026-11-20
---

# rapido-mcp vault

This repository is an Obsidian vault. The vault root is the repo root, so every `.md` file tracked by git is a note, and every note is readable on GitHub without the app.

## Start here

| Note | What it is |
|---|---|
| [How this vault works](learning/obsidian-vault.md) | Vault mechanics: links, properties, search, templates, git. Read first. |
| [MCP protocol from the wire up](learning/mcp-protocol.md) | JSON-RPC framing, transports, the two protocol eras, the three primitives. |
| [Plain tools vs code mode](learning/plain-tools-vs-code-mode.md) | Where code mode came from, what it costs, when it wins. |
| [Node vs Bun vs Python](learning/runtime-node-vs-bun-vs-python.md) | SDK tiers, per-runtime trade-offs, why this server is TypeScript on Node. |
| [Building for an API that changes](learning/building-for-an-api-that-changes.md) | The five-layer robustness design for an unversioned, undocumented backend. |

## Project notes

| Note | What it is |
|---|---|
| [The server we are building](project/rapido-mcp-server.md) | What `rapido-mcp` is, its tool surface, its scope. |
| [What is verified about Rapido's API](project/rapido-api-uncertainty.md) | Live-verified endpoints versus third-party guesses. The trust boundary. |
| [Open questions](project/open-questions.md) | Decisions the grill interview has not yet settled. |

## Domain language

The shared vocabulary lives in [`CONTEXT.md`](../CONTEXT.md) at the repo root. Use those words exactly. The layout rule for those files is in [`docs/agents/domain.md`](../docs/agents/domain.md).

## Rules of this vault

1. Notes are plain Markdown with YAML properties on top. No Markdown inside a property value.
2. Links are Markdown links, not `[[wikilinks]]`, so GitHub renders them. See [How this vault works](learning/obsidian-vault.md).
3. One idea per note. Link notes together instead of growing one note.
4. Every note that states a decision points at the record that proves it: `docs/reviews/decision-log.md` for decisions, `docs/adr/` for architecture records.
