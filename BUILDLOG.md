# Build log

Chronological log of build steps for this repo.

---

## 2026-11-20 — Repo created, Matt Pocock skills configured

**Step 1 — Repo skeleton.**
Created `C:\Users\ADMIN\projects\agent-toolkit`, ran `git init -b main`. Initialised under user `aswathas <aswathas20@gmail.com>`. No commits yet at this point.

**Step 2 — Tooling check.**
`git 2.47.1.windows.2`, `gh 2.103.3`, `node v23.6.1`, `python 3.13.1` all on PATH. `gh auth status` confirms an active login for `aswathas` with scopes `gist, read:org, repo, workflow` over HTTPS. Consequence: the GitHub Issues tracker and the GitHub remote both work without extra setup.

**Step 3 — `/setup-matt-pocock-skills`.**
Explored the empty repo: no `git remote`, no `CLAUDE.md`/`AGENTS.md`, no `CONTEXT.md`, no `docs/adr/`, no `.scratch/`. The `triage` skill is installed, so the triage-label section applies. No monorepo signals (`pnpm-workspace.yaml`, `package.json` workspaces, populated `packages/*`), so single-context domain docs were chosen without asking.

User answers: tracker = GitHub Issues, triage labels = defaults, agent instructions file = `AGENTS.md`.

Wrote:
- `docs/agents/issue-tracker.md`
- `docs/agents/triage-labels.md`
- `docs/agents/domain.md`
- `AGENTS.md` with the `## Agent skills` block

**Step 4 — Repo hygiene files.**
`README.md`, `.gitignore`.

**Step 5 — Commit discipline records.**
`docs/reviews/decision-log.md` (D-001 to D-005), `docs/reviews/change-inventory.md`, `docs/reviews/prompts.md`, and this `BUILDLOG.md`.

**Step 6 — GitHub remote.**
Pending: repo published under `aswathas/agent-toolkit`, public.

**Next:** `/grill-with-docs` interview to pin the project scope and settle the final repo name.

---

## 2026-11-20 — Repo renamed, design decisions settled

Renamed `agent-toolkit` to `rapido-mcp` on GitHub and on disk. Rewrote `README.md` and `AGENTS.md` for the new name and product. Added D-006 to D-010 to the decision log: plain tools first, TypeScript, Node over Bun, rides-only scope, build locally first with the live client held out of the public repo.

Pushed `2e43ab3..77e5e4f  main -> main`.

---

## 2026-11-20 — Obsidian vault built into the repo

**Step 1 — Environment inspection.**
Obsidian **1.8.4** is installed at `D:\Projects\Obsidian\Obsidian.exe` (February 2025 install, never updated). Latest public release is **1.15.1**. `winget` reports 1.15.1 as available. No vaults were registered: `%APPDATA%\obsidian\obsidian.json` is empty, and there is no `.obsidian` folder anywhere under the user profile.

Two consequences recorded in `notes/learning/obsidian-vault.md`: the Obsidian CLI needs the 1.12.7+ installer and is unavailable here, and Bases needs 1.9 and is unavailable here.

**Step 2 — Source verification.**
Fetched Obsidian's own help pages for data storage, internal links and properties. Confirmed the `.obsidian/` git guidance, the `userIgnoreFilters` key name for excluded files, the supported property types, and the link formats. Cross-checked the CLI and Bases version requirements against the Obsidian changelog and roadmap.

**Step 3 — Decision.**
The user chose: vault in the `rapido-mcp` repo, holding both project notes and learning notes in separate folders, with the four HTML lessons kept alongside. Recorded as D-011, D-012, D-013, D-014, D-015.

**Step 4 — Vault configuration.**
Created `.obsidian/app.json`, `appearance.json`, `core-plugins.json`, `community-plugins.json`, `hotkeys.json`, `graph.json`, `templates.json`.

Key settings: `useMarkdownLinks: true` so links render on GitHub as well as in Obsidian; `newLinkFormat: relative`; `alwaysUpdateLinks: true`; `userIgnoreFilters` covering build output; `newFileLocation: folder` with `newFileFolderPath: notes`.

**Step 5 — Content.**
- `CONTEXT.md` — the domain glossary, plus a words-to-avoid table.
- `docs/adr/README.md` — the ADR format, so an agent following `docs/agents/domain.md` finds a contract instead of an empty directory.
- `notes/Home.md` — the index.
- `notes/learning/obsidian-vault.md` — the Obsidian mechanics reference, written from first principles as the user asked.
- `notes/learning/*.md` — four references converted from the HTML lessons by a worker, against an explicit acceptance checklist.
- `notes/project/*.md` — what we are building, the Rapido API trust boundary, and the design-interview frontier.
- `notes/templates/adr.md`, `notes/templates/learning-note.md` — note skeletons.

**Step 6 — Repo hygiene.**
Extended `.gitignore` with the Obsidian machine-state rules. Rewrote `README.md` and `AGENTS.md` to point at `notes/Home.md`.

**Step 7 — Records.**
D-011 to D-015 in the decision log, P-009 to P-012 in the prompt record, one inventory row per changed file.

**Next:** the brainstorm, then the grill. The frontier with a recommendation per question is in `notes/project/open-questions.md`.
