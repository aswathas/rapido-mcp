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
