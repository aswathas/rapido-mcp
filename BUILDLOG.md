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

---

## 2026-11-20 — The MCP course added to the vault

**Step 1 — The design interview, round 1.**
Four questions asked as one questionnaire. Answers: one public repo with the live client and no mock backend; `rapido_session_status` exposed; order state stateless. The quote-storage question was deferred by the user until the learning phase is done. Recorded as D-016, D-017, D-018.

**Step 2 — The vault opened.**
Obsidian had no registered vault, so `%APPDATA%\obsidian\obsidian.json` was written with the `rapido-mcp` path and the app was launched against it. Obsidian created `.obsidian/workspace.json`, which proves the vault loaded. The app auto-updated its asar from 1.8.4 to 1.15.1 during the session, so Bases is likely available now. The CLI still needs the 1.12.7+ installer and stays unverified.

**Step 3 — The course.**
`notes/learning/course.md` holds the module map, the ten teaching methods and why each one is used, the five-step study loop, the mastery criteria and the progress table. The five reference notes stay as the "what"; the modules are the "how to learn it". Recorded as D-019.

**Step 4 — Module 01.**
Written by hand: the mental model, a full raw stdio session with real bytes, four contrast tables, four misconceptions with the reason each wrong belief fails, a five-step lab that writes a working no-SDK MCP server, five retrieval questions with an answer key, a Feynman check with three required sentences, twelve flashcards and a seven-point review schedule.

**Step 5 — Modules 02 to 05.**
Four worker agents wrote one module each against a fixed fifteen-section spec, with the source note as the only source of truth. Each worker was told not to invent facts, to mark unknowns as unverified, and not to touch git. Their outputs were checked for section completeness, link resolution and sentence length.

**Step 6 — Records.**
D-016 to D-019 in the decision log, P-013 to P-015 in the prompt record, one inventory row per changed file.

**Step 7 — The vault checker.**
`scripts/check-vault.ps1` was written so the vault contract is machine-checked: relative links resolve, notes carry frontmatter, no wikilinks. Code blocks and inline code are stripped first, because those show syntax on purpose.

Its first run found five broken relative links in module 02, caused by the spec handed to the worker. They were fixed to `../../project/...` and `../../../CONTEXT.md`. The second run reported 28 notes, 134 links, clean.

**Step 8 — Obsidian rewrote its own config.**
Opening the vault upgraded the running app to 1.15.1, which rewrote `app.json`, `appearance.json` and `core-plugins.json` in the new format, with `bases` enabled. The rewritten files are committed, because the app owns them and a mismatched format churns the diff every session. The downloaded themes are ignored. The version section of `notes/learning/obsidian-vault.md` was corrected, because it still described 1.8.4.

**Next:** Module 01 quiz, then Modules 02 to 05 the same way. Then the quote-storage question, then grill round 2.
