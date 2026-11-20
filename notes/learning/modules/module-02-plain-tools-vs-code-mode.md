---
title: Module 02 — Plain tools vs code mode
type: learning
tags:
  - mcp
  - code-mode
  - tool-design
updated: 2026-11-20
---

# Module 02 — Plain tools vs code mode

## Why this matters for rapido-mcp

`rapido-mcp` plans to expose about seven plain tools. Each extra tool costs context on every turn. Each tool call costs one model round trip.

Code mode promises fewer round trips. It also makes you operate a sandbox that runs model-written code. That code can book and pay for a real ride.

You can get the round-trip saving without the sandbox. Consolidate the sequence inside one tool instead of outside it.

## What you will be able to do

- Explain Cloudflare's three-part argument for code mode.
- Choose between `codeMcpServer()` and `openApiMcpServer()`.
- Name the four costs the token chart does not show.
- State why code mode is not in the MCP specification.
- Separate code mode from Anthropic's Programmatic Tool Calling.
- Design a booking surface that cuts round trips without a sandbox.

## The mental model

Three ways exist to expose an API to a model.

**Plain tools** give the model N schemas. The client validates arguments against each `inputSchema`. Every call costs one model round trip. You run only the server.

**Code mode** gives the model one tool whose description embeds a typed API surface. The model writes code against that surface, and a sandbox runs it. Only what it returns comes back. You run the server and the sandbox.

**Consolidation** keeps plain tools but hides a sequence behind one schema. The model makes one decision. The server executes the steps internally. You run only the server.

Consolidation borrows code mode's round-trip saving and leaves its sandbox, validation loss and debugging cost behind.

## The core content

### Where the pattern came from

The term and pattern come from Cloudflare. Kenton Varda and Sunil Pai wrote ["Code Mode: The better way to use MCP"](https://blog.cloudflare.com/code-mode/) on 26 September 2025. The thesis in one line:

> "LLMs are better at writing code to call MCP, than at calling MCP directly."

The argument has three parts.

1. **Tool schemas are context tax.** Every tool's name, description and schema sits in the model's context on every turn. It pays that cost whether or not the tool is used.
2. **Every tool call is a model round trip.** The model has to be re-invoked, see the result, and decide the next step.
3. **Intermediate results round-trip through the network and back into context.** Fetch 2,000 records, and 200 KB lands in the context window, whether or not the model needs it.

### The two implementations

Cloudflare ships two server builders in `@cloudflare/codemode/mcp`.

| Function | Model-facing tools | Use when |
|---|---|---|
| `codeMcpServer({ server, executor })` | One tool, `code`, whose description embeds generated TypeScript definitions for every upstream tool. Each upstream tool becomes a typed `codemode.*` method. | You already have an MCP server with a manageable set of tools. |
| `openApiMcpServer({ spec, executor, request })` | Two tools, `search` and `execute`. `search` runs model-written code against the OpenAPI document (`codemode.spec()`); `execute` adds the host-provided `codemode.request(options)` function. | You have a large API whose complete schema should stay out of context. |

`openApiMcpServer()` keeps the OpenAPI document outside the model context unless search code returns part of it. It resolves local `$ref` values inside the sandbox. Authentication stays in the host Worker. The `request` callback receives `method`, `path` and optional `query`, `body`, `contentType` and `rawBody`. Credentials never enter the sandbox.

### The sandbox model

Cloudflare's answer is a **V8 isolate per snippet**. There are no containers. The sandbox has no filesystem, and outbound fetch is disabled by default. In Code Mode the global `fetch()` and `connect()` throw errors.

Its only access to the outside world is the typed API surface. That surface uses **RPC invocation** into the agent loop. There the SDK dispatches to the appropriate MCP server.

Two properties matter. First, **no API keys to leak**. The binding is an already-authorised interface. Every call goes to the agent supervisor, which holds the tokens. Second, **results come back as `console.log()` output** when the script finishes.

### The four costs of code mode

These are the four costs the token chart does not show.

**1. You now operate a sandbox.** Someone is executing model-written code. On a laptop that is nontrivial work, and it attaches a security review to a small utility.

**2. The model must learn a new API surface.** It must write correct code against a typed API, handle errors, and know the API exists. A tool's `description` teaches what exists. In code mode that job moves to a TypeScript surface, a different mechanism rather than a better one.

**3. Structured validation gets weaker.** The client validates arguments against `inputSchema`, and a declared `outputSchema` binds the server. In Cloudflare's sandbox, results are `console.log` output. You lose a safety net exactly where your code is least trustworthy.

**4. Debugging gets harder.** A bad tool result means you read the JSON. A misbehaving snippet leaves a model, a sandbox and a log to reconstruct intent from.

### The numbers, and what they are worth

Both headline figures are vendor-reported, with no independent benchmark. Treat them as direction, not as a measurement you can quote.

| Claim | Source | What it actually measured |
|---|---|---|
| 81% token reduction when converting an MCP server to a TypeScript API | Cloudflare | Their own API surface, exposed as code instead of tools. |
| Entire Cloudflare API as ~2 tools in ~1,000 tokens | Cloudflare | A fixed footprint regardless of how big the API gets. |
| 43,588 → 27,297 tokens (37%) on complex research tasks | Anthropic, Programmatic Tool Calling | Anthropic's API feature, not MCP. Beta. |
| >2,000 line items processed outside context, ~200 KB → ~1 KB visible | Anthropic, travel example | One agentic API, not a server. |

### It is not in the specification

Code mode is **not** part of the MCP specification. No code-mode method exists in any schema version — `2024-11-05`, `2025-03-26`, `2025-06-18`, `2025-11-25`, `2026-07-28`, or draft. It is an ecosystem pattern layered on top of MCP. Cloudflare's wraps an MCP server; Anthropic's is a Claude API feature. Adopting code mode is betting on a pattern, not a protocol.

### Programmatic Tool Calling is a different mechanism

Anthropic's Programmatic Tool Calling sounds like code mode but is a separate thing. It is an API feature of Claude. The model writes Python in a managed sandbox, and tool results feed back into the script. They do not feed back into the model's context. It ships as a beta behind the `advanced-tool-use-2025-11-20` beta header. See [Anthropic on advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use).

Two constraints matter. Anthropic states that **MCP connector tools cannot currently be called programmatically**. The execution containers are not zero-data-retention eligible, and they retain artifacts for up to 30 days.

So "code mode" spans two independent mechanisms — an MCP-layer pattern (Cloudflare) and a model-provider feature (Anthropic). They do not compose freely. If our server wants code-mode behaviour, we implement the Cloudflare-style pattern ourselves.

### The vendor guidance points at consolidation, not code mode

Anthropic's tool-use documentation says to "Consolidate related operations into fewer tools… Fewer, more capable tools reduce selection ambiguity". Their research paper on writing tools for agents says "More tools don't always lead to better outcomes". It adds that a tool "can consolidate functionality, handling potentially multiple discrete operations… under the hood."

Both say the same thing. Put the consolidation *inside* the tool, not outside it in a sandbox. A `book_ride` tool that searches, estimates, picks a service and books internally is code mode in practice. The model makes one decision, and the server executes the sequence.

| Shape for booking a ride | Model round trips | Context cost |
|---|---|---|
| Fine-grained: `search_locations` → `geocode` → `estimate_fare` → `book_ride` | 4 | every intermediate result in context, 4 schema descriptions in context forever |
| Consolidated: `plan_ride` → `book_ride` | 2 | one schema description for the whole planning step |

Two round trips, not four, and no sandbox to operate. The model still chooses between services and confirms payment. That is a human decision, and a sandbox would not help it make.

## Worked example

One ride request, two server shapes. Both shapes find the pickup, price it, and book it.

### Fine-grained, four tools, four model round trips

The model holds four schemas: `search_locations`, `geocode`, `estimate_fare` and `book_ride`.

**Turn 1.** The model calls `search_locations` with a free-text pickup. The context gains matching place ids and names. The model must read that list and pick one.

**Turn 2.** The model calls `geocode` with the chosen place id. The context gains pickup and drop coordinates. The earlier search result still sits in the context.

**Turn 3.** The model calls `estimate_fare` with both coordinates. The context gains the quotes. Each quote carries a service, a fare, an estimated distance and duration, and a request id. The model must choose a service and hold a fare in mind.

**Turn 4.** The model calls `book_ride` with the quote id and a payment method. The context gains the order id and its status.

Four full model invocations, and four network round trips. By turn 4 the context holds four schema descriptions, the search results, the coordinates, and every quote returned.

### Consolidated, two tools, two model round trips

The model holds two schemas: `plan_ride` and `book_ride`.

**Turn 1.** The model calls `plan_ride` with a pickup and a drop. The server searches, geocodes, checks service availability and estimates the fare internally. The context gains only the quotes. The search results, the intermediate coordinates and the availability check never leave the server.

**Turn 2.** The model calls `book_ride` with a quote id the user has already seen. The context gains the order id and its status.

Two full model invocations. The context holds two schema descriptions, the quotes, and the order. The four intermediate results never existed in the model's window.

### What the trace does not change

The safety rule survives consolidation. `plan_ride` returns quotes, and the user sees the fare. `book_ride` takes a quote id the user has already seen. The model cannot invent a fare and book it. A quote also expires, so a stale quote must fail loudly rather than book a different price.

The savings come from moving work, not from skipping it. The server still searches, still geocodes, still estimates. Only the number of times the model wakes up changes.

## Contrast cases

| Dimension | Plain tools | Code mode | Programmatic Tool Calling |
|---|---|---|---|
| Where validation happens | Protocol level, against `inputSchema` at the client | Whatever the sandbox enforces; results arrive as `console.log` output | Inside Anthropic's managed Python sandbox |
| Round-trip cost | One model round trip per tool call | One round trip for a whole sequence | One round trip for a whole sequence |
| Who holds credentials | The MCP server process | The host Worker; `request` keeps keys out of the sandbox | Anthropic's execution containers |
| What the model sees | N tool schemas, plus every tool result | One `code` tool, plus what the snippet returns | The script, plus the script's final output |
| Operational burden | You run the server only | You run the server and a code sandbox | You run the server and depend on a beta API feature |
| Status in the protocol | Part of the MCP specification | An ecosystem pattern, not in any schema version | An Anthropic API beta, not MCP |

## Misconception clinic

**Wrong belief:** Code mode is a new MCP protocol feature, so any MCP client supports it today.
**Why it is wrong:** No code-mode method exists in any MCP schema version. Cloudflare's implementation is a wrapper you choose to adopt.
**Correct model:** MCP gives you tools. Code mode is one optional way to wrap them.

**Wrong belief:** The 81% token reduction proves code mode is right for `rapido-mcp`.
**Why it is wrong:** Both headline numbers are vendor-reported with no independent benchmark. They measure a large API surface, not seven Rapido operations.
**Correct model:** Treat the figures as direction. Rapido's surface is small, so schema tax is minor.

**Wrong belief:** Programmatic Tool Calling is code mode, so we can switch it on for our MCP tools.
**Why it is wrong:** It is a separate mechanism. Anthropic states that MCP connector tools cannot currently be called programmatically.
**Correct model:** Two independent mechanisms exist. If our server wants code-mode behaviour, we implement the Cloudflare-style pattern ourselves.

**Wrong belief:** Moving the booking sequence into a sandbox makes the server safer.
**Why it is wrong:** A sandbox that can call `book_ride` is a sandbox that can accidentally book three rides. Its code still reaches the live API.
**Correct model:** Consolidate the sequence inside a plain tool. Keep protocol-level validation. Keep booking behind a quote id the user has seen.

## Hands-on lab

Windows PowerShell 5.1. Node 23 is on your PATH. Three steps, about ten minutes. Run all commands from the repo root.

### Step 1 — Count the schema bytes

```powershell
node -e "const s=(n,d,p)=>({name:n,description:d,inputSchema:{type:'object',properties:p,required:[]}});const fine=[s('search_locations','Free-text place search to a place id',{text:{type:'string'}}),s('geocode','Resolve a place id to coordinates',{place_id:{type:'string'}}),s('estimate_fare','Estimate fares for a pickup and drop pair',{pickup:{type:'string'},drop:{type:'string'}}),s('book_ride','Book a ride for a quote',{quote_id:{type:'string'},payment:{type:'string'}}),s('track_ride','Track an active ride',{order_id:{type:'string'}}),s('cancel_ride','Cancel an active ride',{order_id:{type:'string'}}),s('wallet_balance','Return the wallet balance',{})];const cons=[s('plan_ride','Search, geocode and estimate quotes for a pickup and drop pair',{pickup:{type:'string'},drop:{type:'string'}}),s('book_ride','Book a ride for a quote',{quote_id:{type:'string'},payment:{type:'string'}})];const f=JSON.stringify({jsonrpc:'2.0',id:1,result:{tools:fine}});const c=JSON.stringify({jsonrpc:'2.0',id:1,result:{tools:cons}});console.log('fine tools='+fine.length+' bytes='+Buffer.byteLength(f));console.log('consolidated tools='+cons.length+' bytes='+Buffer.byteLength(c));console.log('saved='+(Buffer.byteLength(f)-Buffer.byteLength(c))+' bytes');"
```

Expected output:

```
fine tools=7 bytes=1176
consolidated tools=2 bytes=437
saved=739 bytes
```

What the number means: this payload is the `tools/list` response the client carries in the model's context. The context pays that cost every turn. This is Cloudflare's "schema tax" made visible. These counts describe a toy schema, so do not quote them.

### Step 2 — Print the round-trip trace

```powershell
node -e "const plans={'fine-grained':['search_locations','geocode','estimate_fare','book_ride'],consolidated:['plan_ride','book_ride']};for(const k of Object.keys(plans)){const p=plans[k];console.log(k+' -> '+p.length+' model round trips');p.forEach(function(t,i){console.log('  turn '+(i+1)+': model calls '+t);});}"
```

Expected output:

```
fine-grained -> 4 model round trips
  turn 1: model calls search_locations
  turn 2: model calls geocode
  turn 3: model calls estimate_fare
  turn 4: model calls book_ride
consolidated -> 2 model round trips
  turn 1: model calls plan_ride
  turn 2: model calls book_ride
```

What the number means: each turn is one complete model invocation. Four turns cost four inference passes and four network round trips. Two turns cost two of each.

### Step 3 — Compare with the real proposed surface

```powershell
Get-Content 'notes\project\rapido-mcp-server.md' -Encoding UTF8 | Select-String 'rapido_' | Select-Object -ExpandProperty Line
```

Expected output lists seven rows, one per tool, including `rapido_plan_ride`. The note says it consolidates search, geocode, service availability and fare estimate into one round trip. The toy schema in Step 1 now has a real counterpart. The `-Encoding UTF8` flag keeps the em dash readable on PowerShell 5.1.

## Retrieval practice

Answer these without looking back at the module.

1. Name the three parts of Cloudflare's argument for code mode. Say which part applies to a server with seven tools.
2. `codeMcpServer()` and `openApiMcpServer()` expose different tool sets. Name both sets and the condition that separates them.
3. Give one reason the 81% token reduction figure cannot be quoted as a benchmark.
4. Your booking flow must never create a ride the user has not seen the fare for. Which tool shape satisfies that, and which would you reject?
5. Anthropic's documentation and research paper both advise fewer, more capable tools. Where do they place the consolidation, and what does that imply for `rapido-mcp`?

## Answer key

1. Schema tax, one model round trip per call, and intermediate results round-tripping into context. Schema tax applies most directly to a seven-tool server.
2. `codeMcpServer()` exposes one tool named `code`; `openApiMcpServer()` exposes `search` and `execute`. Use the first with an existing server and a manageable tool set. Use the second when a large schema must stay out of context.
3. Cloudflare reported it about their own API surface, with no independent benchmark behind it. Treat it as direction, not a measurement.
4. `plan_ride` then `book_ride` satisfies it, because booking requires a quote id the user has already seen. A sandbox that can call `book_ride` risks booking rides nobody approved.
5. Inside the tool, not outside it in a sandbox. It implies consolidating Rapido's sequence into `plan_ride` and keeping plain tools.

## Feynman prompt

Explain this module back to a non-programmer in 150 words. Use no tool names, no schema words, and no acronyms. Speak as if advising a colleague about how to build a ride-booking service.

Your explanation must contain these three sentences in substance:

1. Giving a helper many small instructions makes it read and re-read them every request, and pause for each answer.
2. Letting the helper run written code removes those pauses, but the code can do real damage when it is wrong.
3. The safe answer for a small service like ride booking is to put many steps inside one trusted instruction.

## Flashcards

| Card | Answer |
|---|---|
| What are the three parts of Cloudflare's thesis? | Schemas are context tax, each call is a model round trip, intermediate results round-trip into context. |
| What does `codeMcpServer()` expose? | One tool named `code`, whose description embeds generated TypeScript definitions for every upstream tool. |
| What does `openApiMcpServer()` expose? | Two tools, `search` and `execute`. |
| Where does `openApiMcpServer()` keep credentials? | In the host Worker. The `request` callback never lets them enter the sandbox. |
| What is Cloudflare's sandbox unit? | A V8 isolate per snippet. No containers, no filesystem, and `fetch()` and `connect()` throw. |
| How do code mode results reach the agent? | As `console.log()` output passed back when the script finishes. |
| What is the first of the four costs of code mode? | You now operate a sandbox that executes model-written code. |
| What is the third cost? | Structured validation gets weaker, because results are log output, not schema-validated objects. |
| Is code mode in the MCP specification? | No. No code-mode method exists in any schema version, including draft. |
| What does Anthropic's guidance say to do? | Consolidate related operations into fewer tools, with the consolidation inside the tool. |

## Spaced repetition

| Day | What to review |
|---|---|
| Day 0 | Read the module and complete the three lab steps. |
| Day 1 | Recall the three-part thesis and the four costs, without notes. |
| Day 3 | Redraw the four-round-trip versus two-round-trip booking trace from memory. |
| Day 7 | Re-run the lab and compare your byte counts to yesterday's. |
| Day 14 | Answer the five retrieval questions in writing, then check the answer key. |
| Day 30 | Write the contrast table from memory and defend plain tools for `rapido-mcp`. |
| Day 60 | Teach the Feynman explanation to someone, and correct any missing sentence. |

This module interleaves with the others, so space these reviews against protocol, runtime and robustness material.

## See also

- [Plain tools vs code mode](../plain-tools-vs-code-mode.md) — the source note for this module.
- [MCP from the wire up](../mcp-protocol.md) — the protocol that code mode does not extend.
- [Node vs Bun vs Python](../runtime-node-vs-bun-vs-python.md) — the runtime for the server.
- [Building for an API that changes](../building-for-an-api-that-changes.md) — the robustness design behind the tool surface.
- [The server we are building](../../project/rapido-mcp-server.md) — the proposed seven-tool surface and the booking safety rule.
- [What is verified about Rapido's API](../../project/rapido-api-uncertainty.md) — which endpoints a tool can rely on.
- [Open questions](../../project/open-questions.md) — the decisions this module does not settle.
- [CONTEXT.md](../../../CONTEXT.md) — the shared vocabulary, including Quote and Order.
- [Decision log](../../../docs/reviews/decision-log.md) — where a tool-surface decision gets recorded.
