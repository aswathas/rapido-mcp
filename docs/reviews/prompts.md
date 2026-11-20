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

