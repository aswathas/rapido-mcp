---
title: The server we are building
type: project
status: open
tags:
  - rapido
  - mcp
updated: 2026-11-20
---

# The server we are building

`rapido-mcp` is an MCP server for Rapido rides. An AI agent asks it to search locations, estimate fares, book a ride, track it and cancel it.

## Scope

Rides only: bike taxi, auto, cab. Food (owned by Rapido as Ownly) and parcel are out until the ride lifecycle works, because their endpoint detail is entirely unverified while the ride surface at least has live-verified endpoints.

## Interface

Plain MCP tools. Code mode is a later layer, not a first-version requirement — see [Plain tools vs code mode](../learning/plain-tools-vs-code-mode.md) for why.

## Tool surface (proposed, not yet settled)

| Tool | Does | Notes |
|---|---|---|
| `rapido_search_locations` | Free-text place search to a place id | The only fully verified operation. |
| `rapido_plan_ride` | Quotes for a pickup/drop pair | Consolidates search, geocode, service availability and fare estimate into one round trip. |
| `rapido_book_ride` | Books a quote | Requires a quote id the user has already seen. |
| `rapido_track_ride` | Captain ETA, location, polyline for an order | |
| `rapido_cancel_ride` | Cancels an order | |
| `rapido_wallet_balance` | Wallet balance | |
| `rapido_session_status` | Whether the session is live | Not yet decided — see [Open questions](open-questions.md). |

Naming and granularity are still open. Two candidate shapes: seven prefixed tools, or a smaller set of fewer, more capable tools.

## Booking safety

Two steps, never one.

1. `plan_ride` returns quotes. The user sees the fare.
2. `book_ride` takes a quote id the user has already seen.

The model cannot invent a fare and book it. A quote also expires, so a stale quote must fail loudly rather than book a different price.

## Payment

`cod`, `rapido_wallet`, `upi`. The card and UPI field names come from third-party prior art and are unverified.

## Runtime

TypeScript on Node 23, with the v2 TypeScript MCP SDK (`@modelcontextprotocol/server`). Node over Bun because Bun runs TypeScript without checking types, and the tool `inputSchema` is a contract with the model, so an always-on `tsc` gate is worth more than a nicer single binary.

## Robustness

Five layers, because Rapido has no published API and no version numbers. See [Building for an API that changes](../learning/building-for-an-api-that-changes.md).

## Access route

Rapido has **no public developer API**. The consumer web API is undocumented and Rapido's terms forbid automated programs that make multiple server requests per second. The Corporate API exists but needs a company and a referral.

So: build locally, test locally, and decide separately what to publish. That decision is not yet made. See [What is verified about Rapido's API](rapido-api-uncertainty.md).

## Records

| What | Where |
|---|---|
| Every decision, with its prompt | [`docs/reviews/decision-log.md`](../../docs/reviews/decision-log.md) |
| Architecture decisions | [`docs/adr/`](../../docs/adr/) |
| Changed files | [`docs/reviews/change-inventory.md`](../../docs/reviews/change-inventory.md) |
| Shared vocabulary | [`CONTEXT.md`](../../CONTEXT.md) |
