---
title: Node vs Bun vs Python for an MCP server
type: learning
tags:
  - runtime
  - tooling
  - mcp
updated: 2026-11-20
---

# Node vs Bun vs Python for an MCP server

Use Node + TypeScript with SDK v2, `@modelcontextprotocol/server` 2.4.0. It is the only option with both a Tier-1 conformance claim and a real type-checking gate, and `node:test` is stable and ships with the runtime, so the test toolchain adds zero dependencies.

The Node-versus-Bun question is not an SDK question. It is a runtime-quality question.

## First, what is the SDK situation

MCP has **ten official SDKs**, and they are tiered by conformance. This matters more than raw language preference, because a Tier-1 SDK is one that passes 100% of the conformance suite and is required to have stable releases.

| Tier | SDKs | What the tier means |
|---|---|---|
| **Tier 1** | TypeScript, Python, C#, Go | 100% conformance pass, stable release required |
| **Tier 2** | Java, Rust | Conformance work in progress |
| **Tier 3** | Swift, Ruby, PHP, Kotlin | Early |

Current versions, checked against the release feeds (verified 2026-11-20):

| SDK | Current version | Notes |
|---|---|---|
| TypeScript (v2 line) | `@modelcontextprotocol/server` **2.4.0** and `@modelcontextprotocol/client` **2.4.0** | The v2 line is stable, split into two packages, implementing the 2026-07-28 spec. |
| TypeScript (legacy) | `@modelcontextprotocol/sdk` **1.32.2** | Stays on `v1.x`, with fixes for at least six months after v2 ships. |
| Python | `mcp` **2.3.0** | On PyPI, stable, needs Python 3.10+. Version 1.30.0 is also maintained. |
| Go | **v1.8.0** | Tier 1, stable, maintained in collaboration with Google. |

One decision is already made for us: whichever of Node or Bun we pick, it is the same SDK and the same spec version. The TypeScript SDK's v2 documentation states it runs on "Node.js, **Bun**, and Deno".

## The comparison

| Dimension | Node + TS | Bun + TS | Python |
|---|---|---|---|
| **Type safety** | `tsc` type-checks. A real compile gate. | Bun runs TypeScript *without* checking types. You need `bun check` or `tsc` in CI. | Type hints are static in the checker but not enforced at runtime. No compile step. |
| **Test runner** | `node:test` — stable since Node 20, ships with the runtime. | `bun test` — Jest-compatible, snapshots built in. | `pytest` — mature, huge plugin ecosystem. |
| **HTTP client** | Global `fetch` / undici. Solid, standards-based. | `Bun.fetch`. Fast, and the API differs in places from the standard. | `httpx` — sync and async, HTTP/1.1 and HTTP/2. Best of the three. |
| **Single binary** | Node SEA (`--build-sea`). Workable, still maturing. | `bun build --compile`. The cleanest one-shot binary of the three. | PyInstaller. Works, bulky, and needs its own update story. |
| **Packaging** | npm. Simple. | `bun install`. Compatible with npm. | pip plus a venv. More ceremony, more ways to break a user's install. |
| **Startup time** | No primary-source measurement found for any of the three. Any startup claim you see is unsourced. Do not design around it. | | |

## Bun and the MCP SDK: what the history says

The TypeScript SDK docs say Bun is supported. But the SDK's issue tracker has a recurring pattern of Bun-specific breakage:

| Issue | Link |
|---|---|
| #1269 | [typescript-sdk#1269](https://github.com/modelcontextprotocol/typescript-sdk/issues/1269) |
| #709 | [typescript-sdk#709](https://github.com/modelcontextprotocol/typescript-sdk/issues/709) |
| #91 | [typescript-sdk#91](https://github.com/modelcontextprotocol/typescript-sdk/issues/91) |
| #201 | [typescript-sdk#201](https://github.com/modelcontextprotocol/typescript-sdk/issues/201) |
| #211 | [typescript-sdk#211](https://github.com/modelcontextprotocol/typescript-sdk/issues/211) |

All five were Bun incompatibilities, and all are closed.

Read that as a statement about the ecosystem, not as a strike against Bun: the SDK's own authors hit Bun edges repeatedly, which means the edge exists and the fix usually arrives. If we pick Bun, we expect to be the person who finds the next one.

## The recommendation, and the reasoning that would flip it

**Node + TypeScript, SDK v2 (`@modelcontextprotocol/server` 2.4.0).**

The reasoning that would flip it:

- **To Bun** if startup latency dominates our workload and we add `bun check` to CI so types are still enforced. Bun's `bun build --compile` is genuinely better than Node SEA for distribution.
- **To Python** if our team's working language is Python and we would rather not fight the toolchain. `mcp` 2.3.0 is Tier 1 and stable, `httpx` is the best HTTP client of the three, and `pytest` is the most mature test runner here. The costs are packaging friction and no compile-time schema safety.

Note that **Go** is now a Tier-1 SDK maintained with Google, at v1.8.0. It is a serious option for a server we want to ship as a single binary with zero runtime dependency. It was not in the original shortlist, and it is worth knowing it exists.

## What the runtime decision does not change

The runtime choice is independent of the interface-shape choice and of the protocol mechanics. Whichever runtime we pick, the server speaks the same JSON-RPC over the same stdio framing, exposes the same tool schemas, and needs the same decoder boundary against an undocumented backend. A runtime with a cheap type gate also makes the `inputSchema` contract cheap to keep honest, because the same TypeScript types feed both the schema and the handler that satisfies it.

## What this means for this server

The specific requirements narrow the choice further:

1. **stdio transport, one process.** The server is spawned by the MCP host. It reads stdin, writes stdout, and logs to stderr. Nothing here is exotic — all three runtimes handle it. (See [MCP from the wire up](mcp-protocol.md) for the framing rules that apply.)
2. **One third-party REST API.** A handful of endpoints. `httpx` is objectively the best client here, and Node's `fetch` is entirely adequate.
3. **Types for a JSON Schema.** Our tool `inputSchema` must match our TypeScript types, and a compile gate catches the drift. This is the strongest argument for Node over Bun, and a real argument for TypeScript over Python.
4. **Tests against fixtures.** Because the backend is pluggable, most of our tests never touch the network. That makes the test-runner quality matter more than HTTP performance. (See [Building for an API that changes without notice](building-for-an-api-that-changes.md).)
5. **Public repo, one maintainer.** The lowest-friction stack for a solo maintainer wins.

```text
Node + TS    Tier-1 SDK · tsc gate · node:test · fetch · SEA
Bun + TS     Tier-1 SDK · needs bun check in CI · bun test · best binary
Python       Tier-1 SDK · no compile gate · pytest · httpx · PyInstaller

All three work. Node wins on the type gate and zero-dependency test runner.
```

## See also

- [MCP from the wire up](mcp-protocol.md)
- [Plain tools vs code mode](plain-tools-vs-code-mode.md)
- [Building for an API that changes without notice](building-for-an-api-that-changes.md)
- [Home](../Home.md)
- [CONTEXT.md](../../CONTEXT.md) for the shared vocabulary.
