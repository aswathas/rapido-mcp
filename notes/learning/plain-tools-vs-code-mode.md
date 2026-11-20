---
title: Plain tools vs code mode
type: learning
tags:
  - mcp
  - code-mode
  - tooling
updated: 2026-11-20
---

# Plain tools vs code mode

For `rapido-mcp`, plain tools win. Code mode's real benefit is fewer model round trips; its real cost is a sandbox that executes model-written code that can book and pay for a real ride. You can get the benefit without the cost by consolidating the sequence *inside* one tool instead of *outside* it in a sandbox.

Plain tools give the model N schemas, cost one model round trip per tool call, and get protocol-level schema validation against `inputSchema` — and you run only the server. Code mode gives the model one tool (`code`) whose description embeds a typed API surface, costs one round trip for a whole sequence, and gets whatever validation the sandbox enforces — and you must also run that sandbox.

## Where code mode came from

The term and pattern come from Cloudflare — Kenton Varda and Sunil Pai, ["Code Mode: The better way to use MCP"](https://blog.cloudflare.com/code-mode/), 26 September 2025. The thesis in one line:

> "LLMs are better at writing code to call MCP, than at calling MCP directly."

The argument has three parts:

1. **Tool schemas are context tax.** Every tool's name, description and schema sits in the model's context window on every turn, whether or not that tool is used.
2. **Every tool call is a model round trip.** The model has to be re-invoked, see the result, and decide the next step.
3. **Intermediate results round-trip through the network and back into context.** Fetch 2,000 records, and 200 KB of records land in the context window whether the model needs them all or not.

Code mode's answer: convert the tools into a **typed API surface** (TypeScript, in Cloudflare's implementation), expose a single `code` tool, and let the model write a snippet against that surface. The snippet runs in a sandbox; only what it returns comes back.

## The two implementations

Cloudflare ships two server builders in `@cloudflare/codemode/mcp`.

| Function | Model-facing tools | Use when |
|---|---|---|
| `codeMcpServer({ server, executor })` | One tool, `code`, whose description embeds generated TypeScript definitions for every upstream tool. Each upstream tool becomes a typed `codemode.*` method. | You already have an MCP server with a manageable set of tools. |
| `openApiMcpServer({ spec, executor, request })` | Two tools, `search` and `execute`. `search` runs model-written code against the OpenAPI document (`codemode.spec()`); `execute` adds the host-provided `codemode.request(options)` function. | You have a large API whose complete schema should stay out of context. |

`openApiMcpServer()` keeps the OpenAPI document outside the model context unless search code returns part of it, and resolves local `$ref` values inside the sandbox. Authentication stays in the host Worker: the `request` callback receives `method`, `path`, optional `query`, optional `body`, optional `contentType` and optional `rawBody`, so credentials never enter the sandbox.

## The sandbox model

Cloudflare's answer is a **V8 isolate per snippet**. There are no containers. The sandbox has no filesystem, and outbound fetch is disabled by default — in Code Mode the global `fetch()` and `connect()` throw errors. Its only access to the outside world is through the typed API surface, backed by **RPC invocation** that calls back into the agent loop, where the SDK dispatches to the appropriate MCP server.

Two properties matter: **no API keys to leak** (the binding is an already-authorised client interface; all calls go to the agent supervisor first, which holds the access tokens, so the model cannot write code that leaks a key), and **results come back as `console.log()` output** (when the script finishes, all the output logs are passed back to the agent).

## The numbers, and what they are worth

Both headline figures are vendor-reported, with no independent benchmark. Treat them as direction, not as a measurement you can quote.

| Claim | Source | What it actually measured |
|---|---|---|
| 81% token reduction when converting an MCP server to a TypeScript API | Cloudflare | Their own API surface, exposed as code instead of tools. |
| Entire Cloudflare API as ~2 tools in ~1,000 tokens | Cloudflare | A fixed footprint regardless of how big the API gets. |
| 43,588 → 27,297 tokens (37%) on complex research tasks | Anthropic, Programmatic Tool Calling | Anthropic's API feature, not MCP. Beta. |
| >2,000 line items processed outside context, ~200 KB → ~1 KB visible | Anthropic, travel example | One agentic API, not a server. |

## What code mode actually costs

These are the four costs the token chart does not show.

**1. You now operate a sandbox.** Someone is executing model-written code. On a laptop that is nontrivial work — the kind that quietly turns a small utility into a project with a security review attached.

**2. The model must learn a new API surface.** With plain tools, the model already knows how to call a tool. With code mode it must write correct code against a typed API, including handling errors, and it must know the API exists at all. A tool's `description` is doing the job of teaching the model what exists; in code mode that job moves to a TypeScript surface — a different teaching mechanism, not a better one.

**3. Structured validation gets weaker.** Plain tools have protocol-level guarantees: the client validates arguments against `inputSchema`, and if you declare `outputSchema` the server must conform. In Cloudflare's sandbox, what comes back is `console.log` output, not schema-validated objects. You lose a real safety net exactly where your code is least trustworthy.

**4. Debugging gets harder.** When a plain tool returns a bad result, you read the JSON and you know what happened. When a model-written snippet misbehaves, you have a model that wrote code, a sandbox that ran it, and a log to reconstruct intent from.

## It is not in the specification

Code mode is **not** part of the MCP specification. No code-mode method exists in any schema version — `2024-11-05`, `2025-03-26`, `2025-06-18`, `2025-11-25`, `2026-07-28`, or draft. It is an ecosystem pattern layered on top of MCP: Cloudflare's implementation wraps an MCP server, while Anthropic's is an API feature of Claude. Adopting code mode is betting on a pattern, not a protocol.

## Programmatic Tool Calling is a different mechanism

Anthropic's Programmatic Tool Calling sounds like code mode but is a separate thing: an API feature of Claude where the model writes Python in a managed sandbox and tool results are fed back into the script rather than into the model's context. It ships as a beta behind the `advanced-tool-use-2025-11-20` beta header — see [Anthropic on advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use). Two constraints matter: Anthropic states that **MCP connector tools cannot currently be called programmatically**, and the execution containers are not zero-data-retention eligible and retain artifacts for up to 30 days.

So "code mode" spans two independent mechanisms — an MCP-layer pattern (Cloudflare) and a model-provider feature (Anthropic) — and they do not compose freely. If our server wants code-mode behaviour, we implement the Cloudflare-style pattern ourselves.

## The vendor guidance points at consolidation, not code mode

Anthropic's tool-use documentation says to "Consolidate related operations into fewer tools… Fewer, more capable tools reduce selection ambiguity". Their research paper on writing tools for agents says "More tools don't always lead to better outcomes", and that a tool "can consolidate functionality, handling potentially multiple discrete operations… under the hood."

Both say: put the consolidation *inside* the tool, not outside it in a sandbox. A `book_ride` tool that internally searches, estimates, picks a service and books is already "code mode" in the sense that matters — the model makes one decision, the server executes the sequence.

| Shape for booking a ride | Model round trips | Context cost |
|---|---|---|
| Fine-grained: `search_locations` → `geocode` → `estimate_fare` → `book_ride` | 4 | every intermediate result in context, 4 schema descriptions in context forever |
| Consolidated: `plan_ride` → `book_ride` | 2 | one schema description for the whole planning step |

Two round trips, not four, and no sandbox to operate. The model still needs to choose between services and confirm payment — which it genuinely should decide, and which a sandbox would not help it decide.

## When code mode wins and loses here

Code mode wins when the API surface is genuinely large and the operations are genuinely mechanical: tens to hundreds of endpoints where the schema tax alone exceeds the model's attention budget; multi-step sequences over large data where only a summary should reach the context window; or an API that already has a good typed SDK.

It loses when the tool count is small enough that the model picks reliably anyway; when operations have irreversible side effects, because a sandbox that can call `book_ride` is a sandbox that can accidentally book three rides; when you want structured, validated outputs; or when you do not want to own a code-execution sandbox in a public repo.

Applied to Rapido: the surface is small and well-bounded — search, geocode, estimate, book, track, cancel, wallet. That is seven-ish operations, and the interesting decisions are the ones a human should make: which pickup point, which service, whether to cancel. Code mode's advantages are minimal here and its costs are maximal. Plain tools, consolidated so that `plan_ride` does search + geocode + estimate internally, is the shape that fits.

## See also

- [MCP from the wire up](mcp-protocol.md)
- [Node vs Bun vs Python for an MCP server](runtime-node-vs-bun-vs-python.md)
- [Building for an API that changes without notice](building-for-an-api-that-changes.md)
- [Home](../Home.md)
- [CONTEXT.md](../../CONTEXT.md) for the shared vocabulary.
