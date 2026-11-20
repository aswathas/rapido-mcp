---
title: How this vault works
type: learning
tags:
  - obsidian
  - tooling
updated: 2026-11-20
---

# How this vault works

The mechanics you need to read and write notes in this repo. Everything here was checked against the Obsidian help docs, and the settings were written into `.obsidian/app.json` so the behaviour is the behaviour, not a preference.

## The vault is the repo

Obsidian's vault is a plain folder on disk. Its notes are plain `.md` files. Its only special folder is `.obsidian/`, which holds settings. There is no database, no proprietary format, no lock-in: `git clone` this repo and you have every note.

That is why the vault root is the repo root. `CONTEXT.md`, `docs/adr/`, `README.md` and `AGENTS.md` are all vault notes. There is no second copy of anything.

## Properties, not frontmatter decoration

A property is a YAML key at the top of a note, between `---` fences:

```markdown
---
title: How this vault works
type: learning
tags:
  - obsidian
  - tooling
updated: 2026-11-20
---
```

Obsidian reads these as structured fields, and so does any script that parses YAML. That makes them queryable.

Supported property types are Text, List, Number, Checkbox, Date, Date & time, and Tags. The type is fixed by the first note that uses that property name, so keep one meaning per name across the vault.

Rules that matter here:

- Text properties hold one line. Markdown does not render inside them.
- Internal links inside properties must be quoted.
- Nested properties are not rendered. Use source mode if you need to read them.
- Bulk editing properties is not supported in the app. Use a script.

This vault uses these property names, and only these:

| Property | Type | Meaning |
|---|---|---|
| `title` | Text | Human name of the note. |
| `type` | Text | `index`, `learning`, `project`, `adr`, `template`. |
| `tags` | Tags | Free-form labels. Never a second way to express `type`. |
| `status` | Text | For project notes: `open`, `settled`, `rejected`. |
| `updated` | Date | Last time a human or agent changed the meaning. |

## Links are Markdown links, not wikilinks

Obsidian supports two link formats and they are not interchangeable in practice.

Wikilink:

```markdown
[[How this vault works]]
```

Markdown link:

```markdown
[How this vault works](obsidian-vault.md)
```

Obsidian renders both. GitHub renders only the second. Since this repo is public and read on GitHub, this vault is configured with `"useMarkdownLinks": true` and `"newLinkFormat": "relative"`. Write Markdown links.

The rules that follow from that:

- Paths are relative to the current note, and start from the vault root with a forward slash.
- Spaces must be percent-encoded as `%20`.
- A link to a note that does not exist yet still works; Obsidian creates it when you click it. That is a feature for capture, a trap for typos. Check the path.
- Anchor links work: `note.md#Heading` and `note.md#^block-id`.
- Block references (`#^id`) are an Obsidian-only extension. They break outside the app. Use them sparingly.

The one Obsidian-only feature used here is the link graph. It reads Markdown links fine.

## Search, properties and the graph

Three ways to find things, in increasing order of power:

1. **Quick switcher** (`Ctrl+O`) — by title. Fastest.
2. **Global search** (`Ctrl+Shift+F`) — full text, with operators: `path:`, `file:`, `tag:`, `line:`, `-` to exclude, quotes for exact phrases.
3. **Property search** — `[status:open]` finds every note whose `status` is `open`. This is the one that pays off, because it turns a note's properties into a real query language.

The graph view (`Ctrl+G`) draws notes as nodes and links as edges. It is a map of how ideas connect, not a task list. A note with no links is an island; a vault of islands is a filing cabinet, not a thinking tool.

## Templates

The Templates core plugin inserts a note skeleton from a file in a template folder. Set the folder in `.obsidian/templates.json`.

This vault keeps two templates: `notes/templates/adr.md` and `notes/templates/learning-note.md`. To use one, run *Templates: Insert template* from the command palette (`Ctrl+P`).

## What git sees

Obsidian writes into `.obsidian/` on every window change, which would churn the diff. The split:

| Path | In git | Why |
|---|---|---|
| `.obsidian/app.json` | yes | Shared behaviour. Settings that make the vault work the same everywhere. |
| `.obsidian/appearance.json` | yes | Theme and fonts. Same look on every machine. |
| `.obsidian/core-plugins.json` | yes | Which core plugins are on. |
| `.obsidian/community-plugins.json` | yes | Which community plugins are on. |
| `.obsidian/hotkeys.json` | yes | Keyboard shortcuts worth sharing. |
| `.obsidian/graph.json` | yes | Graph layout preferences. |
| `.obsidian/templates.json` | yes | Where templates live. |
| `.obsidian/workspace.json` | **no** | Which tabs are open. Machine state, changes every session. |
| `.obsidian/workspace-mobile.json` | **no** | Same, for the phone. |
| `.obsidian/cache/` | **no** | Cache. |
| `.obsidian/plugins/*/data.json` | **no** | Per-machine plugin state. |
| `.trash/` | **no** | Deleted notes. |

The rule: commit configuration, ignore machine state.

## Excluded files

`userIgnoreFilters` in `.obsidian/app.json` keeps build output out of search, the graph and the quick switcher. This vault excludes:

```json
["node_modules/", "dist/", "build/", ".venv/", "__pycache__/", ".git/", ".github/"]
```

An entry is a path prefix, or a regular expression when wrapped in slashes. Excluded files stay on disk; they just stop being indexed. This matters once `src/` and `node_modules/` exist.

## The version on this machine

Obsidian is installed at `D:\Projects\Obsidian\Obsidian.exe`. The installer is **1.8.4**, but the app package auto-updated itself to **1.15.1** on 2026-11-20. The version that matters is the running one.

Three consequences:

- **The Obsidian CLI is still unverified.** It arrived in 1.12 and needs the 1.12.7+ installer, then `Settings → General → Command line interface`. The installer here is still 1.8.4. Until it is upgraded, an agent edits Markdown files directly, which is exactly what this repo expects anyway.
- **Bases is available now.** Bases (database views over properties, `.base` files) landed in 1.9, and the running app has `bases` enabled in `core-plugins.json`. It is the natural way to make an index of project notes. Property search `[status:open]` still works and needs no plugin.
- **The config file format moved.** Newer Obsidian writes `core-plugins.json` as an object map of booleans instead of an array of names, moves the font and title-bar settings from `appearance.json` into `app.json`, and writes the files without a trailing newline. The app rewrites these files on launch, so the committed format must match the running version. Otherwise the diff churns on every session.

The rule for the agent: read the config, do not assume it. Obsidian rewrites what it owns.

## Obsidian is not required to work on this repo

This is the important part. Notes are Markdown. Properties are YAML. Links are Markdown links. An agent can read, write, grep and script every note without Obsidian running at all. Obsidian is the human reading surface, not a dependency of the code.

## Where to go next

- [MCP protocol from the wire up](mcp-protocol.md)
- [Plain tools vs code mode](plain-tools-vs-code-mode.md)
- [Node vs Bun vs Python](runtime-node-vs-bun-vs-python.md)
- [Building for an API that changes](building-for-an-api-that-changes.md)

## Ask your teacher

If anything here is unclear, ask. That is the point of this vault.
