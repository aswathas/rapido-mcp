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
