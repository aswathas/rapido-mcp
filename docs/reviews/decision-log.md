# Decision log

Every decision with real alternatives gets an entry here, oldest first. The prompt that produced the decision is part of the entry.

---

## D-001 — Start a new repo instead of using an existing working directory

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** Create a fresh git repository at `C:\Users\ADMIN\projects\agent-toolkit` for this work, rather than working in `C:\Users\ADMIN` (the session's default working directory).

**Alternatives considered:**
- Use `C:\Users\ADMIN` directly — it is not a git repo and holds unrelated scratch files (`.ps1` probes, skill scans, spreadsheet exports). Tracking it would mean committing unrelated noise.
- Use an existing project repo — none was named, and the idea itself is not yet settled.

**Why:** A greenfield project needs a clean history and a remote from the first commit, and the scope is still open, so nothing needs to be preserved from a prior directory.

**Prompt that produced this decision:**
> Q: Where should the new repo live, and should it go to GitHub?
> A: Others: lets create a new repo

---

## D-002 — Public GitHub remote

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The repo will be published as a **public** GitHub repository under the `aswathas` account, and issues will live in that repo's GitHub Issues.

**Alternatives considered:**
- Private repo — rejected by the user in favour of public.
- Local markdown issues under `.scratch/` — available, but `gh` was already authenticated and GitHub Issues gives native blocking dependencies that `/to-tickets` and `/wayfinder` rely on.

**Why:** `gh` was already logged in as `aswathas` with `repo` and `workflow` scopes, so the tracker choice carries no extra setup cost. Public keeps the repo open for reuse.

**Prompt that produced this decision:**
> Q: Where should the new repo live, and should it go to GitHub?
> A: C:\Users\ADMIN\projects\<name>, public GitHub repo

> Q: Where do issues live for this repo? to-spec, to-tickets and triage read from it.
> A: GitHub Issues in the repo

---

## D-003 — Default triage label vocabulary

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** Keep the five canonical triage labels unchanged: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`.

**Alternatives considered:**
- Override the label strings — only worth doing if the tracker already uses a different vocabulary. This repo is new, so the defaults are free.

**Why:** A brand-new tracker has no existing vocabulary to match; the defaults are the documented canonical set.

**Prompt that produced this decision:**
> Q: Keep the default triage labels?
> A: Yes, keep defaults

---

## D-004 — `AGENTS.md` as the agent instructions file

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** Create `AGENTS.md` at the repo root as the file carrying the `## Agent skills` block.

**Alternatives considered:**
- `CLAUDE.md` — rejected by the user. Neither file existed, so the setup skill required an explicit choice rather than defaulting.

**Why:** The setup skill edits `CLAUDE.md` if present and `AGENTS.md` otherwise, and never creates one when the other exists. With neither present, the user chose.

**Prompt that produced this decision:**
> Q: No CLAUDE.md or AGENTS.md exists in the new repo. Which should be created?
> A: AGENTS.md

---

## D-005 — Project kind: automation or agent tooling

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The project is automation or agent tooling. The specific scope is undefined and will be pinned down by the `/grill-with-docs` interview.

**Alternatives considered:**
- Web app or site, command-line tool, library or API service — all rejected by the user.

**Why:** Drives the scaffolding shape (runtime, test framework, entry points) chosen during implementation.

**Prompt that produced this decision:**
> Q: What kind of project is this? The repo gets scaffolded around it.
> A: Automation or agent tooling

> Q: What do you want to build? One line is enough; the grill interview digs into it after the repo exists.
> A: Start blank — interview me from scratch

---

## D-006 — Repo renamed to `rapido-mcp`

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The repository was renamed from `agent-toolkit` to `rapido-mcp` on GitHub, and the local directory, README and `AGENTS.md` were renamed to match.

**Alternatives considered:**
- Keep `agent-toolkit` — rejected. The name described a category, not an artefact, and the project turned out to be one specific server.
- Keep a broader umbrella repo and add Rapido inside it — rejected. One repo, one product, one issue tracker.

**Why:** The name should say what the thing is. GitHub keeps the old name as a redirect, so the rename is not destructive.

**Prompt that produced this decision:**
> Q: Repo is currently `aswathas/agent-toolkit`. Rename?
> A: Rename to rapido-mcp

---

## D-007 — Interface: plain tools first, code mode later

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The server exposes plain MCP tools. A code-mode layer is a later step, added on top once the tool surface is proven, not a first-version requirement.

**Alternatives considered:**
- Plain tools only, no code mode ever — rejected. It loses the option without deciding against it.
- Code mode from the start — rejected on the evidence. Code mode is an ecosystem pattern, not part of any MCP schema version. Its advantage is cutting round trips, and consolidation *inside* a tool (`plan_ride` doing search + geocode + estimate) gets that without operating a code-execution sandbox. For a seven-operation ride API, the sandbox cost is at its worst, because a sandbox running model-written code can trigger a real paid ride.

**Why:** The user asked to be taught the difference first, then chose the conservative sequencing. Plain tools work in every MCP client; code mode needs a sandbox and is still vendor-reported territory.

**Prompt that produced this decision:**
> Q: How should the agent use it? This decides the whole interface design.
> A: Plain tools now, code mode later

---

## D-008 — Runtime: TypeScript

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** TypeScript. Node or Bun to be settled between two candidates in the same language.

**Alternatives considered:**
- Python — viable. `mcp` 2.3.0 is Tier 1 and stable, `httpx` is the best HTTP client of the three options, `pytest` is the most mature test runner. Rejected because there is no compile-time type gate to keep a tool's `inputSchema` from drifting away from the code implementing it.
- Go — now a Tier 1 SDK maintained with Google (v1.8.0). Not chosen; the type-gate argument does not apply, but the ecosystem is thinner and no Go toolchain is installed here.

**Why:** The MCP SDK is Tier 1 in TypeScript, and the type-checking gate matters more for an MCP server than for most other programs, because the tool schema is a contract with the model.

**Prompt that produced this decision:**
> Q: Which runtime should the server be written in?
> A: TypeScript on Node or Bun

---

## D-009 — Node 23, not Bun

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** Node 23 with TypeScript, using the v2 TypeScript MCP SDK (`@modelcontextprotocol/server`).

**Alternatives considered:**
- Bun 1.4.4 — same language, same SDK, arguably better single-binary output via `bun build --compile`. Rejected because Bun executes TypeScript without checking types, so type checking becomes a separate CI step that has to be owned deliberately. For an MCP server, where the tool `inputSchema` is a contract with the model, an always-on `tsc` gate is worth more than the nicer binary. Bun is also the runtime the SDK's own issue tracker has repeatedly been bitten by.

**Why:** Node 23 is already installed, `node:test` is stable and ships with the runtime so the test toolchain adds zero dependencies, and global `fetch` covers the HTTP client need adequately.

**Prompt that produced this decision:**
> Q: Node or Bun? Both run the same TypeScript MCP SDK.
> A: Node 23

---

## D-010 — Build and test locally first; the live client stays out of the public repo

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The whole server is built and exercised locally first. The public repo receives the server core — tool surface, schemas, the ride lifecycle, the backend interface, fixtures and tests. The live client that talks to Rapido's undocumented consumer API is written and run locally, and is **not** pushed to GitHub until the user has seen it work and has decided what to publish. The publication split is revisited as a separate decision after testing, not assumed now.

**Alternatives considered:**
- Everything public from the start — rejected for now. Publishing reverse-engineered endpoint and auth details under the user's own identity is the one irreversible part of this project, and it is cheap to defer until there is something proven to publish.
- Fixtures only, never build the live client — rejected. The user explicitly wants to test it for real.
- Wait for a Rapido Corporate account before building anything — rejected. It needs a company, so it is not on the critical path.

**Why:** The user set two constraints — no budget, and all features — which leave exactly one route (the consumer API), and then asked to test locally first. Building the whole thing locally and deferring publication keeps every option open: the split can be made later, but the code has to exist first.

**Scope note:** rides only (bike taxi, auto, cab) for the first version. Food (Ownly) and parcel are excluded until the rides lifecycle works, because their endpoint detail is entirely unverified while the rides surface at least has live-verified unauthenticated endpoints and third-party prior art.

**Prompt that produced this decision:**
> Q: Given free plus all features means the consumer API, where should the code that calls it live?
> A: Others: lets test it lodcally first

> Q: Does "all features" include food and parcel, or rides only?
> A: Rides only for now: bike, auto, cab

---

## D-011 — The repo root is the Obsidian vault

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The `rapido-mcp` repo root is an Obsidian vault. Every `.md` file tracked by git is a vault note. There is no separate notes repo and no second copy of anything. `CONTEXT.md`, `docs/adr/`, `README.md` and `AGENTS.md` are all notes.

**Alternatives considered:**
- A separate vault repo, with the project repo linking into it — rejected. Two repos means two histories, two remotes and a sync problem. A vault is just a folder of Markdown; a git repo already is one.
- A `notes/` subfolder as the vault root, with the project outside it — rejected. Then `CONTEXT.md` and `docs/adr/` sit outside the link graph, and the notes cannot link to the records that justify them.
- Keep the learning workspace at `C:\Users\ADMIN\projects\mcp-learning` and mirror notes into the repo — rejected. Mirroring means two sources of truth that drift.

**Why:** Obsidian's vault is a plain folder. Its notes are plain `.md` files. Git already versions folders of Markdown. Making the repo root the vault means there is exactly one copy of every note, it renders on GitHub, and an agent can read and write it without Obsidian running at all.

**Prompt that produced this decision:**
> Q: Where should the Obsidian vault live?
> A: rapido-mcp repo (public on GitHub)

---

## D-012 — The vault holds both project notes and learning notes, in separate folders

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The vault carries two kinds of note in two folders: `notes/project/` for design notes that belong to this project, and `notes/learning/` for reference material that outlives it. `notes/Home.md` is the index.

**Alternatives considered:**
- Project notes only — rejected. The learning material is what makes the next design decision fast, and it was already written; it belongs somewhere durable.
- Learning notes only — rejected. The project notes are the working surface for the design interview.
- One flat `notes/` folder — rejected. Project decisions and general reference have different lifetimes and different readers; separating them makes both findable.

**Why:** The learning material was written in a separate workspace at `C:\Users\ADMIN\projects\mcp-learning` as HTML lessons. Those lessons stay, because they are a teaching artefact with quizzes and styled typography. The vault gets the condensed, versioned reference form of the same material. That is the difference between a lesson and a reference, and the reference is what a future reader — human or agent — needs.

**Prompt that produced this decision:**
> Q: What should the vault actually hold?
> A: Both, in separate folders

---

## D-013 — Markdown links, not wikilinks

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** Notes use Markdown links, not `[[wikilinks]]`. Obsidian is configured with `"useMarkdownLinks": true` and `"newLinkFormat": "relative"`.

**Alternatives considered:**
- Wikilinks — rejected. Obsidian renders them; GitHub does not. This repo is public and read on GitHub, so wikilinks would show as broken text to every reader without the app. The link graph still works, because Obsidian reads Markdown links.
- Absolute vault-root paths — rejected. Relative paths survive a note being moved, and they are what GitHub resolves.

**Why:** The vault must work in two readers: the Obsidian app and GitHub. Markdown links are the only format both render. The cost is that spaces must be percent-encoded as `%20` and the paths must be correct by hand, which is a real cost but a visible one.

**Prompt that produced this decision:**
> (Derived from the vault-location decision. The user chose a public GitHub vault; a public vault that renders as broken link text on GitHub would not be a working public vault.)

---

## D-014 — Commit Obsidian configuration, ignore Obsidian machine state

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** `.obsidian/app.json`, `appearance.json`, `core-plugins.json`, `community-plugins.json`, `hotkeys.json`, `graph.json` and `templates.json` are committed. `.obsidian/workspace.json`, `workspace-mobile.json`, `workspace-*.json`, `cache/`, `plugins/*/data.json` and `.trash/` are ignored.

**Alternatives considered:**
- Ignore the whole `.obsidian/` folder — rejected. Then a fresh clone has no settings: no excluded-files list, no template folder, no core plugin set. The vault would behave differently on every machine.
- Commit everything, including `workspace.json` — rejected. Obsidian rewrites `workspace.json` on every window change. It would churn the diff on every single session and conflict constantly.
- Commit plugin `data.json` files — rejected. Per-machine plugin state, same churn problem, and a plugin's data file can hold arbitrary local state.

**Why:** The split is configuration versus machine state. Configuration describes the vault and is identical everywhere. Machine state describes the current window and is not.

**Prompt that produced this decision:**
> (Derived from the vault-location decision and the git-hygiene requirement. Committing a vault to a public repo means the diff must stay readable.)

---

## D-015 — The HTML lessons stay; the vault is the working surface

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The four HTML lessons in `C:\Users\ADMIN\projects\mcp-learning\lessons/` are kept unchanged. The vault is added alongside them. The lessons teach; the vault notes are the reference.

**Alternatives considered:**
- Replace the lessons with vault notes — rejected by the user. The lessons carry a teaching purpose the notes do not: styled typography, diagrams, quizzes with immediate feedback, and a spaced path through the material. Converting them to plain Markdown would throw that away.
- Delete the learning workspace entirely once the vault exists — rejected. The lessons are the artefact that proved the material was understood, and the quiz answers become evidence for the learning records.

**Why:** A lesson and a reference have different shapes. The lesson is paced and interactive. The reference is dense and complete. Keeping both costs one duplicated idea per topic and buys two different uses.

**Prompt that produced this decision:**
> Q: Keep the four HTML lessons, or replace them with vault notes?
> A: Keep HTML lessons, add vault alongside

---

## D-016 — The live client ships in the public repo, and no mock backend ships

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** `rapido-mcp` holds the server and the live Rapido client in one public repo. No mock backend is shipped.

**Alternatives considered:**
- Sibling private repo for the live client, public repo shipping the server core plus a mock backend — recommended by the assistant, rejected by the user.
- Live client inside the public repo behind a build flag — rejected by the user.
- Public repo with the live client included and no mock backend — chosen.

**Why:** The user chose one repository and full disclosure over a staged split. The repo is the product, so it carries the whole product.

**Known tension, recorded not resolved:** Rapido's terms forbid automated programs that make multiple server requests per second, and there is no public developer API. See [What is verified about Rapido's API](../../notes/project/rapido-api-uncertainty.md). This decision reverses the publication half of D-010 and leaves the legal question open. It is an engineering choice, not a legal clearance. Without a mock backend, offline tests run against recorded fixtures, and the live probe stays the only component that can detect backend drift.

**Prompt that produced this decision:**
> Q: Where does the live Rapido client live, and does the public repo ship a mock backend?
> A: One public repo, live client included, no mock

---

## D-017 — Auth state is visible to the model through one tool

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The server exposes `rapido_session_status`. It returns whether the session is live and when it expires. It returns no user id, no phone number and no token material.

**Alternatives considered:**
- No session tool, with auth state outside the tool surface and errors carrying `AUTH_EXPIRED` — rejected. The model then discovers it is logged out by failing a call, which wastes a round trip and reads as a backend fault.
- Full session details including the phone number — rejected. It would put personal data into the model's context.

**Why:** The model needs to know whether to suggest logging in, and nothing more. A boolean plus an expiry answers that and leaks nothing.

**Prompt that produced this decision:**
> Q: Should auth state be visible to the model?
> A: do that

---

## D-018 — The server holds no order state

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** Every call queries Rapido. `orderId` is the only handle the server keeps. There is no local order store.

**Alternatives considered:**
- A local order cache — rejected. It adds a database, a migration story and a second source of truth that can disagree with Rapido.
- Hybrid, cache plus refresh on read — rejected. The cache adds complexity and buys nothing.

**Why:** Rapido is the source of truth for order state. A stateless server has no migrations, no state to lose on restart and no reconciliation logic.

**Prompt that produced this decision:**
> Q: Does the server track order state locally?
> A: do that

---

## D-019 — The learning material is a module course inside the vault

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The five reference notes stay. A new `notes/learning/course.md` map plus `notes/learning/modules/module-01` to `module-06` carry the taught version. Every module has the same shape: why it matters, objectives, mental model, core content, worked example, contrast cases, misconception clinic, hands-on lab, retrieval practice, answer key, Feynman prompt, flashcards, spaced repetition, see also.

**Alternatives considered:**
- Keep only the reference notes and teach in chat — rejected. The teaching would not survive the session, and the vault would hold reference material only.
- Keep the HTML lessons as the only teaching surface — rejected. An agent cannot shape them as easily as Markdown, and they are not queryable vault notes.

**Why:** The user asked for detailed material taught with strong methods. A method is only reproducible if its shape is written down and every module obeys it.

**Prompt that produced this decision:**
> i want detailed learning material i want a you to teach me with worlds gretest teaching mehtids

---

## D-020 — The Obsidian config follows the running app version

**Date:** 2026-11-20
**Decided by:** Aswath, via MiniMax Code

**Decision:** The committed `.obsidian/` files use the format the running app writes. The app auto-updated its package from 1.8.4 to 1.15.1, so `core-plugins.json` is now an object map of plugin booleans, the font and title-bar settings live in `app.json` instead of `appearance.json`, and `bases` is enabled. Downloaded themes under `.obsidian/themes/` are ignored, both in git and in the vault's excluded-file list.

**Alternatives considered:**
- Keep the 1.8.4 format and let the app rewrite it on every launch — rejected. The app owns these files, and a format that disagrees with the app churns the diff every session.
- Commit the downloaded theme CSS — rejected. It is about one megabyte of third-party assets that the app fetches for itself.

**Why:** Configuration must match the tool that owns it, or the diff lies about what the vault actually runs.

**Prompt that produced this decision:**
> (Derived from the Obsidian upgrade observed while opening the vault. See P-015.)
