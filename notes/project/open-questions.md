---
title: Open questions
type: project
status: open
tags:
  - rapido
  - decisions
updated: 2026-11-20
---

# Open questions

Decisions the design interview has not settled yet. Each one has a recommended answer, so none of them is a blank.

The full frontier is worked in rounds. Each round asks every question whose prerequisites are already settled.

## Round 1 — the brainstorm questions

| # | Question | Recommended |
|---|---|---|
| 1 | Does the live client live in `rapido-mcp` or a sibling repo, and does the public repo ship a mock backend anyone can run? | Sibling repo for the live client; public repo ships the server core plus a mock backend. |
| 2 | Should quotes be cached server-side with an expiry, or should the quote be a signed blob the model carries? | Server-side cache with expiry. The server owns the quote-to-service mapping and revalidates before booking. |
| 3 | Should the server expose a `session_status` tool, or should auth state live outside the tool surface entirely? | Expose `rapido_session_status`, returning a boolean and an expiry — no user id, no phone, no token material. |
| 4 | Does the server track order state locally, or is every call stateless against Rapido? | Stateless. Every call queries Rapido. `orderId` is the only handle. |

## Round 2 — still open

| # | Question | Recommended |
|---|---|---|
| 5 | How does the user authenticate? | A CLI: `rapido-mcp login --mobile <number>`, prompts for the OTP, caches the token on disk with restrictive permissions. An env var is a CI override, not the main path. |
| 6 | Which breakage-handling layers ship in v1? | All five. Health probe, decoder registry, invariant assertions, typed errors, live probe script. |
| 7 | What is the tool surface and how are tools named? | Seven tools with a `rapido_` prefix, versus a smaller set of fewer, more capable tools. |
| 8 | Is ride history in v1? | No. No verified endpoint exists for it. |

## Settled

These are decided and recorded in [`docs/reviews/decision-log.md`](../../docs/reviews/decision-log.md).

| Decision | Summary |
|---|---|
| D-006 | Repo named `rapido-mcp`. |
| D-007 | Plain MCP tools first, code mode later. |
| D-008 | TypeScript. |
| D-009 | Node 23, not Bun. |
| D-010 | Build and test locally first; the live client stays out of the public repo for now. |

## Why the questions are shaped this way

The four round-one questions are not arbitrary. They all answer one underlying question: **how much state does the server hold?**

- Where the live client lives decides whether the repo is a product or a proof of concept.
- Where the quote lives decides whether the model can be trusted to carry a price.
- Whether auth is a tool decides whether the model can waste a round trip discovering it is logged out.
- Whether order state is local decides whether the server has a database, and therefore whether it has a migration story.

A server that answers "stateless, server-side quote cache" has no database, no migrations and no state to lose on restart. That is a real property, not a default.

## After the interview

Once the answers are settled, they become ADRs under [`docs/adr/`](../../docs/adr/), and the spec comes out of `/to-spec`.
