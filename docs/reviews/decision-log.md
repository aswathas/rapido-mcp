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
