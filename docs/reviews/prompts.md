# Prompt record

Every prompt that shaped this work, verbatim, in order.

---

## P-001 — "use matt pocock skills"

**Context:** Session start. No repo, no task yet.
**Effect:** Loaded `mattpocock-skills:ask-matt` (the router over the Matt Pocock skill set) to pick a flow, then `caveman` for the session voice.

---

## P-002 — Situation questionnaire

> Q: What situation are you in? This picks the flow.
> A: Build a feature (grill → spec → tickets → implement)

> Q: Where should the new repo live? Current directory is C:\Users\ADMIN, which is not a git repo.
> A: Others: lets create a new repo

**Effect:** Selected the main build flow and ruled out the home directory as the working repo.

---

## P-003 — Project shape questionnaire

> Q: What do you want to build? One line is enough; the grill interview digs into it after the repo exists.
> A: Start blank — interview me from scratch

> Q: What kind of project is this? The repo gets scaffolded around it.
> A: Automation or agent tooling

> Q: Where should the new repo live, and should it go to GitHub?
> A: C:\Users\ADMIN\projects\<name>, public GitHub repo

**Effect:** No pre-decided scope. Repo kind is automation/agent tooling. Public GitHub remote under `aswathas`.

---

## P-004 — Setup questionnaire

> Q: Where do issues live for this repo? to-spec, to-tickets and triage read from it.
> A: GitHub Issues in the repo

> Q: Keep the default triage labels?
> A: Yes, keep defaults

> Q: No CLAUDE.md or AGENTS.md exists in the new repo. Which should be created?
> A: AGENTS.md

**Effect:** Wrote `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`, and `AGENTS.md`.

---

## P-005 — Project shape, after research

> Q: What do you want to build? One line is enough; the grill interview digs into it after the repo exists.
> A: Start blank — interview me from scratch

> Q: What kind of project is this? The repo gets scaffolded around it.
> A: Automation or agent tooling

> Q: Where should the new repo live, and should it go to GitHub?
> A: C:\Users\ADMIN\projects\<name>, public GitHub repo

> Q: Where do issues live for this repo? to-spec, to-tickets and triage read from it.
> A: GitHub Issues in the repo

> Q: Keep the default triage labels?
> A: Yes, keep defaults

> Q: No CLAUDE.md or AGENTS.md exists in the new repo. Which should be created?
> A: AGENTS.md

**Effect:** Set the project to automation/agent tooling, and configured the tracker, labels and agent file. The product itself was still unspecified.

---

## P-006 — The idea, once the research was in

> Q: What problem does this tool exist to remove? Pick the closest shape; you can describe your own in the Other field.
> A: Others: i want to build a mcp for rapido

> Q: Who runs this tool? This decides whether it can assume one machine, one user, and local credentials.
> A: Others: for now lets build and let me test

> Q: Does it reach outside this machine? This decides whether it needs credentials, retries, and failure handling.
> A: Both local files and external services

> Q: What should the finished thing be? This decides the shape of the code and the tests.
> A: Others: like an mcp or code mode

**Effect:** Named the product: an MCP server for Rapido. Also set the audience to "just me, testing it now".

---

## P-007 — Scope and shape, plus a request to be taught first

> Q: Which Rapido products should the first version cover?
> A: Rides only: bike, auto, cab

> Q: How should the agent use it? This decides the whole interface design.
> A: Others: first lets analyse mcp vs code mode

> Q: Which runtime should the server be written in?
> A: Others: first teach me what is a mcp technically from basics then terach me about each runtime so taht i can get all learn and decide so taht nextime it will be easy for me

> Q: Which Rapido account will it authenticate as?
> A: Support both, personal first

**Effect:** Stopped the build to teach MCP foundations, the plain-tools-versus-code-mode question, and the runtime trade-offs before choosing. Lessons 0001–0003 were written in `C:\Users\ADMIN\projects\mcp-learning`. Scope fixed at rides only. Account support fixed at both, personal first.

---

## P-008 — Decisions after the teaching

> Q: Repo is currently `aswathas/agent-toolkit`. Rename?
> A: Rename to rapido-mcp

> Q: How should the agent use it? This decides the whole interface design.
> A: Plain tools now, code mode later

> Q: Which runtime should the server be written in?
> A: TypeScript on Node or Bun

> Q: Given free plus all features means the consumer API, where should the code that calls it live?
> A: Others: tell me or give me the context i cant understadnt i cant pay for any service or anything but i need to dothis with all features no limit in features

> Q: Given free plus all features means the consumer API, where should the code that calls it live?
> A: Others: lets test it lodcally first

> Q: Does "all features" include food and parcel, or rides only?
> A: Rides only for now: bike, auto, cab

> Q: Node or Bun? Both run the same TypeScript MCP SDK.
> A: Node 23

**Effect:** Repo renamed to `rapido-mcp`. Interface set to plain tools first with code mode deferred. Runtime set to Node 23 with TypeScript. Scope confirmed as rides only. The publication split deferred: build and test locally, keep the live client out of the public repo until the user has seen it work.

---

## P-009 — Obsidian as the working surface

> use obsidian firwst eam until i say doen teach me create a obsidian vault in same repop of ours let em learnfirstg teach me about this from first then we can brainstrom then you can grill

**Context:** Lesson 0004 had been written and committed, but the brainstorm had not happened. The user interrupted with a new instruction: use Obsidian, and build a vault in the same repo.

**Effect:** Switched the workflow. Before doing anything else, taught the vault mechanics (lesson note `notes/learning/obsidian-vault.md`) and built the vault. The brainstorm is still pending; it runs after this.

---

## P-010 — Vault location, contents and lesson handling

> Q: Where should the Obsidian vault live?
> A: rapido-mcp repo (public on GitHub)

> Q: What should the vault actually hold?
> A: Both, in separate folders

> Q: Keep the four HTML lessons, or replace them with vault notes?
> A: Keep HTML lessons, add vault alongside

**Effect:** D-011, D-012, D-015. The vault root is the repo root. `notes/project/` and `notes/learning/` are the two content folders. The HTML lessons are untouched.

---

## P-011 — Earlier brainstorm round, deferred

> Q: Where should the live client live: a separate private repo, an unpublished branch in rapido-mcp, or published in rapido-mcp?
> Q: Should quotes live server-side with an expiry, or travel as a signed blob the model carries?
> Q: Should the server expose a session/auth-status tool, or keep auth state outside the tool surface?
> Q: Should the server track order state locally, or stay stateless against Rapido?

**Context:** Asked, then interrupted by the Obsidian instruction before the user answered.

**Effect:** Recorded in `notes/project/open-questions.md` as round 1 of the design frontier, each with a recommended answer. Still open. These become D-numbers once the interview settles them.

---

## P-012 — Environment facts gathered for the vault

> (Not a user prompt. Facts established by inspection, recorded here so the decisions above can be audited.)

**Effect:** Obsidian 1.8.4 is installed at `D:\Projects\Obsidian\Obsidian.exe`; latest public release is 1.15.1. The Obsidian CLI needs the 1.12.7+ installer and is unavailable here. Bases needs 1.9 and is unavailable here. `.obsidian/app.json` keys confirmed against Obsidian's own help docs and the app bundle: `alwaysUpdateLinks`, `newLinkFormat`, `useMarkdownLinks`, `attachmentFolderPath`, `newFileLocation`, `newFileFolderPath`, `userIgnoreFilters`. Git guidance for `.obsidian/` confirmed against Obsidian's data-storage help page.

