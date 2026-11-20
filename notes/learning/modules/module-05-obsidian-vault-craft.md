---
title: Module 05 — Obsidian vault craft
type: learning
tags:
  - obsidian
  - tooling
  - git
updated: 2026-11-20
---

# Module 05 — Obsidian vault craft

## Why this matters for rapido-mcp

This repo is a public GitHub repository that is also an Obsidian vault. Every note in it is a `.md` file tracked by git. That fact decides how you read, write and review them.

Three things follow. Anything a human must understand belongs in a note, not a commit message. A note must render on GitHub, because GitHub is the public face of this repo. And you can work here without Obsidian running, which is what an agent needs.

The gap between "the app shows it" and "the file shows it" is where notes rot.

## What you will be able to do

After this module you can:

1. Explain why the vault root is the repo root.
2. Write a note whose YAML frontmatter parses in Obsidian and in a script.
3. Write a relative Markdown link that resolves on GitHub and in Obsidian.
4. Name the three search modes and say which one pays off.
5. Say which `.obsidian/` files are committed and which are ignored.
6. Create, verify and delete a note from the terminal alone.
7. State the Obsidian version here, and mark what you did not check.

## The mental model

**The vault is a folder. Everything else is decoration.**

Obsidian's vault is a plain folder on disk. Its notes are plain `.md` files. Its only special folder is `.obsidian/`, which holds settings. There is no database, no proprietary format, no lock-in. `git clone` this repo and you have every note.

Because the vault root is the repo root, `CONTEXT.md`, `docs/adr/`, `README.md` and `AGENTS.md` are all vault notes.

- **The file is the truth.** Obsidian edits the same bytes you read with `Get-Content`.
- **Git is the memory.** A note you did not commit did not happen.
- **GitHub is the audience.** This repo is public. A note that only renders inside the app fails half the readers.

## The core content

### Properties are queryable YAML

A property is a YAML key between `---` fences at the top of a note:

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

Supported property types are Text, List, Number, Checkbox, Date, Date & time, and Tags. The type is fixed by the first note that uses that property name. Keep one meaning per name across the vault.

Rules:

- Text properties hold one line. Markdown does not render inside them.
- Internal links inside properties must be quoted.
- Nested properties are not rendered. Use source mode to read them.
- Bulk editing properties is not supported. Use a script.

This vault uses these property names:

| Property | Type | Meaning |
|---|---|---|
| `title` | Text | Human name of the note. |
| `type` | Text | `index`, `learning`, `project`, `adr`, `template`. |
| `tags` | Tags | Free-form labels. Never a second way to express `type`. |
| `status` | Text | For project notes: `open`, `settled`, `rejected`. |
| `updated` | Date | Last time a human or agent changed the meaning. |

### Links are Markdown links, not wikilinks

Obsidian supports two link formats, and they are not interchangeable.

Wikilink:

```markdown
[[How this vault works]]
```

Markdown link:

```markdown
[How this vault works](obsidian-vault.md)
```

Obsidian renders both. GitHub renders only the second. Since this repo is public, this vault sets `"useMarkdownLinks": true` and `"newLinkFormat": "relative"`. Write Markdown links.

Rules:

- Paths are relative to the current note. This vault uses folder-relative paths.
- Spaces must be percent-encoded as `%20`.
- A link to a missing note still works. Obsidian creates it when you click it. That is a feature for capture, a trap for typos. Check the path.
- Anchor links work: `note.md#Heading` and `note.md#^block-id`. Block references are Obsidian-only and break outside the app.

The only Obsidian-only feature used here is the link graph.

### Three ways to find things

Three ways to find things:

1. **Quick switcher** (`Ctrl+O`) — by title. Fastest.
2. **Global search** (`Ctrl+Shift+F`) — full text, with operators: `path:`, `file:`, `tag:`, `line:`, `-` to exclude, quotes for exact phrases.
3. **Property search** — `[status:open]` finds every note whose `status` is `open`. This one pays off, because it turns properties into a query language.

The graph view (`Ctrl+G`) draws notes as nodes and links as edges. It maps how ideas connect. A note with no links is an island, and a vault of islands is a filing cabinet.

### Templates

The Templates core plugin inserts a note skeleton from a file in a template folder. Set the folder in `.obsidian/templates.json`.

This vault keeps two templates: `notes/templates/adr.md` and `notes/templates/learning-note.md`. Insert one with *Templates: Insert template* (`Ctrl+P`).

### What git sees

Obsidian writes into `.obsidian/` on every window change, which churns the diff. The split:

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

### Excluded files

`userIgnoreFilters` in `.obsidian/app.json` keeps build output out of search, the graph and the quick switcher. This vault excludes:

```json
["node_modules/", "dist/", "build/", ".venv/", "__pycache__/", ".git/", ".github/"]
```

An entry is a path prefix, or a regular expression when wrapped in slashes. Excluded files stop being indexed.

### The version on this machine

The reference note records Obsidian **1.8.4**, installed at `D:\Projects\Obsidian\Obsidian.exe`, with **1.15.1** as the latest public release.

That note is out of date in one way, verified here. On 2026-11-20 the app auto-updated its asar package to 1.15.1. The log records the download of `obsidian-1.15.1.asar.gz` and the load of `C:\Users\ADMIN\AppData\Roaming\obsidian\obsidian-1.15.1.asar`. The executable is still the 1.8.4-era binary, but the running code is 1.15.1.

- **Bases is now available.** Bases landed in 1.9. The running package is 1.15.1, and `.obsidian/core-plugins.json` now carries `"bases": true`. Confirm it in the app before relying on it.
- **The CLI is still unverified.** The CLI arrived in 1.12 and needs the 1.12.7+ installer, plus `Settings → General → Command line interface`. The 1.15.1 package contains that setting, but no `obsidian-cli` executable was found on `PATH` or on disk. Treat it as unavailable until you install the newer installer and enable it.

### The principle

Obsidian is not required to work on this repo. Notes are Markdown. Properties are YAML. Links are Markdown links. An agent can read, write and script every note without Obsidian running.

Obsidian is the human reading surface, not a dependency of the code.

## Worked example

A note lives at `notes/learning/modules/` and links to a sibling in `notes/learning/`.

The file:

```markdown
---
title: Example note about fare decoding
type: project
status: open
tags:
  - rapido
updated: 2026-11-20
---

# Example note about fare decoding

The fare field moved from `amount` to `fare.amount` in an observed response.

See [How this vault works](../obsidian-vault.md) for the vault conventions.
```

**The frontmatter is the query surface.** `status: open` and `type: project` are what `[status:open]` searches. Without them, a note is invisible to property search.

**The link resolves relative to the note's own folder.** From `notes/learning/modules/`, `../obsidian-vault.md` walks up to `notes/learning/` and lands on `notes/learning/obsidian-vault.md`. Obsidian follows the path, and GitHub resolves it the same way. One string, two renderers, no plugin.

**The same file renders without Obsidian.** On GitHub the reader sees the YAML block as a table at the top. Then the heading, and a working blue link. No app, no plugin.

Write for the file, and the app comes free.

## Contrast cases

| Contrast | Option | What GitHub shows | What breaks | Who owns the decision |
|---|---|---|---|---|
| Link format | Wikilink `[[Note]]` | Raw bracket text, not a link | Every reader on GitHub sees broken navigation | The vault owner, for the public repo |
| Link format | Markdown link `[Note](note.md)` | A working link | A typo becomes a dead link that still resolves in the app | The note author |
| Git split | Committed `.obsidian/app.json` | The shared configuration, reviewable in a diff | Nothing, as long as it stays small and stable | The vault owner |
| Git split | Ignored `.obsidian/workspace.json` | Nothing, and that is correct | A noisy diff on every window change | The vault owner |
| Editor | Obsidian as the editor | Nothing, the app is not in the repo | Nothing, but you must learn the app's conventions | The note author |
| Editor | Plain Markdown on disk | The note, exactly as written | Nothing, but you lose the app's navigation aids | The note author |
| Layout | Vault inside the repo | Notes, code and decisions in one tree, one history | Cross-contamination between docs and build output | The repo owner |
| Layout | Separate vault repository | Two repos, two histories, two reviews | Links between them cannot be relative, and reviews split in two | The repo owner |

Every row names an owner. An unowned vault decision drifts.

## Misconception clinic

**Wrong belief:** "The vault is Obsidian's format, so I need Obsidian to read it."

**Why it is wrong:** A vault is a folder of `.md` files. `git clone` gives you every note. Obsidian reads the same bytes your editor does.

**Correct model:** The vault is a plain folder with a Markdown convention. Obsidian is one reader.

---

**Wrong belief:** "A wikilink is Obsidian's native format, so it should be the default."

**Why it is wrong:** Obsidian renders both formats, but GitHub renders only Markdown links. A wikilink in a public repo is a dead link outside the app.

**Correct model:** Markdown links are the portable format. The vault sets `"useMarkdownLinks": true`.

---

**Wrong belief:** "Committing all of `.obsidian/` keeps the vault reproducible."

**Why it is wrong:** Obsidian rewrites `workspace.json` on every window change. Committing it produces a diff every session.

**Correct model:** Commit configuration, ignore machine state. Config files make a fresh clone behave identically. Workspace files describe one person's tabs.

---

**Wrong belief:** "If a link points at a note that does not exist yet, the link is broken."

**Why it is wrong:** Obsidian creates the target note when you click the link. That is a capture feature, and it hides typos.

**Correct model:** A missing target is silent until someone reads it on GitHub. Check the path before you commit.

## Hands-on lab

Time: under 15 minutes. Windows PowerShell 5.1. Obsidian does not need to be running.

Every command is plain PowerShell 5.1 syntax. No `&&`, no heredoc.

### Step 1 — write a scratch note from the terminal

```powershell
$root = 'C:\Users\ADMIN\projects\rapido-mcp'
$note = Join-Path $root 'notes\module-05-scratch.md'
$content = @(
'---'
'title: Module 05 scratch note'
'type: learning'
'tags:'
'  - obsidian'
'updated: 2026-11-20'
'---'
''
'# Module 05 scratch note'
''
'This note exists only for the module 05 lab.'
''
'See [How this vault works](learning/obsidian-vault.md) for the conventions.'
)
Set-Content -LiteralPath $note -Value $content -Encoding UTF8
```

Two warnings first. **You must delete this scratch note at the end of the lab.** It is untracked in a public repo, so it shows up in `git status`. And **PowerShell 5.1's `Set-Content -Encoding UTF8` writes a byte order mark.** The file starts with the bytes `EF BB BF`. Obsidian and GitHub both tolerate it. A strict YAML parser may not, so prefer a BOM-free write for script consumers.

### Step 2 — check that every relative link in `notes/` resolves

Paste this block. It extracts every link target, resolves it against the note's folder, and tests it with `Test-Path`.

```powershell
$root = 'C:\Users\ADMIN\projects\rapido-mcp'
$missing = @()
$total = 0
Get-ChildItem -Path (Join-Path $root 'notes') -Recurse -Filter *.md -File | ForEach-Object {
  $file = $_
  $text = Get-Content -LiteralPath $file.FullName -Raw
  foreach ($m in [regex]::Matches($text, '\[[^\]]*\]\(([^)\s]+)\)')) {
    $target = $m.Groups[1].Value
    if ($target -match '^(https?:|mailto:|#)') { continue }
    $path = ($target -split '#')[0]
    if ([string]::IsNullOrWhiteSpace($path)) { continue }
    $total++
    $resolved = Join-Path (Split-Path -Parent $file.FullName) ([uri]::UnescapeDataString($path))
    if (-not (Test-Path -LiteralPath $resolved)) {
      $missing += [pscustomobject]@{ Note = $file.FullName.Substring($root.Length + 1); Target = $target }
    }
  }
}
Write-Output ("links checked: " + $total)
Write-Output ("missing targets: " + $missing.Count)
$missing | Format-Table -AutoSize
```

On this machine the scan reported **126** links checked and **3** missing targets. All three come from this module's own code examples, because the script does not skip code blocks.

**Those are findings, not script failures.** The script counts example link syntax as real links. Obsidian would not catch a broken link either, because it creates missing notes on click.

### Step 3 — confirm the frontmatter parses

`ConvertFrom-Yaml` does **not** exist in Windows PowerShell 5.1. That was verified here. It ships with newer PowerShell and the `powershell-yaml` module. Try it first:

```powershell
if (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue) {
  Write-Output 'ConvertFrom-Yaml is available'
} else {
  Write-Output 'ConvertFrom-Yaml is NOT available on this machine'
}
```

If it is missing, use this fallback. It parses the flat frontmatter this vault uses, enough for the four properties.

```powershell
$lines = Get-Content -LiteralPath $note
$end = -1
for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i] -eq '---') { $end = $i; break } }
$props = @{}
$key = $null
foreach ($l in $lines[1..($end - 1)]) {
  if ($l -match '^\s*-\s+(.*)$') { if ($key) { $props[$key] += ,$Matches[1] }; continue }
  if ($l -match '^([A-Za-z0-9_-]+):\s*(.*)$') {
    $key = $Matches[1]
    $props[$key] = @()
    if ($Matches[2].Trim()) { $props[$key] = @($Matches[2].Trim()) }
  }
}
foreach ($k in 'title', 'type', 'tags', 'updated') {
  Write-Output ("  {0} = {1}" -f $k, ($props[$k] -join ', '))
}
```

Expected output on this machine:

```text
  title = Module 05 scratch note
  type = learning
  tags = obsidian
  updated = 2026-11-20
```

### Step 4 — delete the scratch note and confirm the tree is clean

```powershell
Remove-Item -LiteralPath $note -Force
Test-Path -LiteralPath $note
git -C $root status --short
```

`Test-Path` must print `False`. In `git status --short` there must be no line for `notes/module-05-scratch.md`.

Be careful about what "clean" means. On this machine `git status --short` is **not** empty even with the scratch note deleted. The Obsidian app rewrote three `.obsidian` config files during the 1.15.1 auto-update. That is the machine-state rule, seen from the other side. Your check is the absence of the scratch note.

## Retrieval practice

Answer closed book. Write your answers before opening the answer key.

1. The vault root is the repo root. Give one concrete consequence for a note in `notes/learning/`.

2. A note at `notes/learning/modules/note.md` must link to `notes/project/open-questions.md`. Write the link target as it appears.

3. You add a new property named `owner` to one note. What happens to later notes that use `owner`, and why?

4. `git status` shows `.obsidian/workspace.json` as modified. Name the two files this is prevented for. Then state the rule that decides the split.

5. You need every project note whose status is `open`. Name the exact search expression. Then name the shortcut that does not work for it. Finally, name the version question.

## Answer key

1. A note in `notes/learning/` must link out of that folder, so its target starts with `../`.
   Relative resolution happens against the containing folder, so folder depth decides the number of `../` segments.

2. `../../project/open-questions.md`.
   From `notes/learning/modules/`, two levels up reaches `notes/`, where the project notes live.

3. The type is fixed by the first note that uses that name, so later notes cannot change its meaning.
   Obsidian locks a property name to the type of its first use, so one name must mean one thing.

4. The two files are `.obsidian/workspace.json` and `.obsidian/workspace-mobile.json`. The rule is to commit configuration and ignore machine state.
   Both describe which tabs are open on one machine, and both change every session.

5. The expression is `[status:open]`. The shortcut that does not work is plain-text global search on `Ctrl+Shift+F`. The version question is whether Bases is available.
   Bases landed in 1.9, and this machine's app package auto-updated to 1.15.1. Bases would answer with a database view.

## Feynman prompt

Explain this module to a non-programmer in 150 words. No jargon, no file paths, no acronyms. If you cannot, you have not owned it yet.

Your explanation must contain these three sentences, in your own wording:

1. The notes are just text files in a folder, so anyone can read them without installing anything.
2. The links between notes are written so that a website can follow them, not just the desktop app.
3. Some of the app's settings are saved for everyone to see, and the rest are saved for one computer only.

## Flashcards

| Card | Answer |
|---|---|
| What is a vault, physically? | A plain folder on disk whose notes are plain `.md` files. |
| Where is the vault root in this repo? | The repo root, so `CONTEXT.md`, `README.md` and `docs/adr/` are all vault notes. |
| Which link format does this vault use, and why? | Markdown links, because GitHub renders only those and the repo is public. |
| What are the two settings behind that choice? | `"useMarkdownLinks": true` and `"newLinkFormat": "relative"`. |
| How are relative link paths resolved? | Against the folder that holds the note containing the link. |
| Which property types does Obsidian support? | Text, List, Number, Checkbox, Date, Date & time, Tags. |
| What fixes a property's type? | The first note that uses that property name. |
| Which five property names does this vault use? | `title`, `type`, `tags`, `status`, `updated`. |
| Which two `.obsidian/` files are ignored, and what are they for? | `workspace.json` and `workspace-mobile.json`, which hold which tabs are open on one machine. |
| Which Obsidian version is running on this machine? | The app auto-updated its asar to 1.15.1 on 2026-11-20, even though the installed executable is from the 1.8.4 line. |

## Spaced repetition

| Day | What to review |
|---|---|
| Day 0 | Read "The core content" and "The worked example". Run the lab end to end. Write your five answers before opening the answer key. |
| Day 1 | Answer the five retrieval questions again, closed book. Review only the ones you got wrong. |
| Day 3 | Answer again. Add every wrong answer to your own flashcard deck, in your own words. |
| Day 7 | Redo the Step 2 link check without pasting the script. Recite the `.obsidian` split table from memory. |
| Day 14 | Do the Feynman prompt again in under 150 words. Check that all three required sentences are present. |
| Day 30 | Re-read the reference note. Then explain the version situation on this machine, including what you could not verify. |
| Day 60 | Write a new note in the vault from the terminal. Run the link check and the frontmatter parse on it. Confirm the tree is clean afterwards. |

This module interleaves with the others. Every review session mixes a vault question with a protocol question and a runtime question, because mixed practice builds discrimination.

## See also

- [How this vault works](../obsidian-vault.md) — the reference note.
- [The MCP course](../course.md) — module order and the study loop.
- [Module 01 — MCP from the wire up](module-01-mcp-protocol.md)
- [Module 02 — Plain tools vs code mode](module-02-plain-tools-vs-code-mode.md)
- [Module 03 — Node vs Bun vs Python](module-03-node-vs-bun-vs-python.md)
- [Module 04 — Building for an API that changes](module-04-building-for-an-api-that-changes.md)
- [The server we are building](../../project/rapido-mcp-server.md) — the project note.
- [CONTEXT.md](../../../CONTEXT.md) — shared vocabulary.
- [AGENTS.md](../../../AGENTS.md) — agent rules.
- [README.md](../../../README.md) — the public entry point.
- [Decision log](../../../docs/reviews/decision-log.md) — decisions.
