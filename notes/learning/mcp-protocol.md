---
title: MCP from the wire up
type: learning
tags:
  - mcp
  - protocol
  - tooling
updated: 2026-11-20
---

# MCP from the wire up

MCP is JSON-RPC 2.0 messages, sent over one of two transports, that let a host application expose tools, resources and prompts to an AI model. That is all. There is no magic, no semantic layer, no standard tool catalogue. The entire protocol is a request/response envelope plus a naming convention for methods.

Everything the spec does not pin down is freedom you get to spend. So the silences below matter as much as the rules.

## 1. The wire format

Every MCP message is a JSON-RPC 2.0 object. Three shapes exist, and the difference is whether there is an `id`.

| Shape | Has `id`? | Meaning |
|---|---|---|
| Request | yes — string or integer, never `null`, never reused | Asks for something. Gets exactly one response. |
| Response | yes — echoes the request's `id` | Carries either `result` or `error`, never both. |
| Notification | no | Fire and forget. Gets no reply. |

So `tools/call` is a request, and `notifications/initialized` is a notification. That single distinction is the source of most MCP bugs: forget the `id` and the client waits forever for a response that was never required.

Sources: [Base protocol](https://modelcontextprotocol.io/specification/2025-06-18/basic/index.md) and the normative [`schema.ts`](https://github.com/modelcontextprotocol/specification/blob/main/schema/2025-06-18/schema.ts) in the spec repo.

## 2. Transport one: stdio, the local case

The client launches your server as a child process. Your server reads JSON-RPC from `stdin` and writes it to `stdout`. Framing is **newline-delimited JSON**: one complete JSON-RPC message per line, and messages must not contain embedded newlines.

The rule that bites everyone: `stdout` carries MCP messages **only**. `stderr` is free-form UTF-8 for logging. A stray `console.log` in your handler corrupts the stream, and the client dies with a parse error that points nowhere near the cause.

Shutdown is a small ritual worth knowing. The client closes your stdin, waits, then `SIGTERM`, then `SIGKILL`. Your server should notice stdin closing and exit cleanly, because anything you were mid-way through is lost.

## 3. Transport two: Streamable HTTP, the remote case

One endpoint serves both POST and GET.

| Direction | Rules |
|---|---|
| POST | Carries one client→server JSON-RPC message. Send `Accept: application/json, text/event-stream`. Posting a *request* gets `application/json` with a single object, or an SSE stream. Posting a *notification or response* gets `202 Accepted` with an empty body. |
| GET | Optional. Opens a standalone SSE stream for server→client pushes. Unsupported means `405 Method Not Allowed`. |
| Sessions | Optional. The server may set `Mcp-Session-Id` on the initialize response; clients must echo it on every later request. Omit the header entirely and you get a stateless server. |

Two security rules live in the same area: validate `Origin` to stop DNS rebinding, and bind to `127.0.0.1` when the server is local. "Local" in MCP means local to the client, and a server bound to `0.0.0.0` is not local.

Source: [Transports](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports.md).

## 4. Starting a session: two eras, and this matters

The spec changed recently and most clients have not caught up. Getting this wrong produces an error that will not tell you why.

### Legacy era — 2025-11-25 and earlier

A handshake. The client sends `initialize` carrying its `protocolVersion`, its `capabilities` and its `clientInfo`. The server replies with its own `protocolVersion`, `capabilities`, `serverInfo` and optionally `instructions`. The client then sends `notifications/initialized`, and only then do normal operations begin.

Version negotiation: the client sends a version it supports, the server replies with that same version if it can, otherwise with a different one it does support. If the client cannot live with the server's choice, it disconnects. Over HTTP, every later request must carry `MCP-Protocol-Version: <version>`.

### Modern era — 2026-07-28, current latest

> "There is no negotiation handshake. Every request carries its protocol version" in `_meta`. Servers **MUST** implement `server/discover`. An unsupported version returns error code `-32022` `UnsupportedProtocolVersionError`, listing the versions the server does support, and the client retries.

Practical consequence: `initialize` and `notifications/initialized` are legacy-era only. Build for the era your actual client speaks. Most third-party clients today still speak legacy. Read the `initialize` response carefully — it is also the easiest place to smuggle human-facing `instructions` to the model.

### Method names by era

| Method | Legacy (2025-11-25 and earlier) | Modern (2026-07-28) |
|---|---|---|
| `initialize` | required handshake | none — no handshake |
| `notifications/initialized` | required, after the handshake | none |
| `server/discover` | — | **MUST** be implemented |
| `tools/list`, `tools/call` | yes | yes |
| `resources/list`, `resources/read`, `resources/templates/list` | yes | yes |
| `prompts/list`, `prompts/get` | yes | yes |
| `sampling/createMessage` | yes | yes |
| `roots/list` | yes | yes |
| `resources/subscribe` | yes | replaced by `subscriptions/listen` |
| HTTP GET SSE stream | on the endpoint | moved by the 2026-07-28 spec |

## 5. Three primitives, and the real distinction between them

Tools, resources and prompts are often taught as "data, data, and prompts". That is wrong. The distinction is **who controls the invocation**.

| Primitive | Who triggers it | Think of it as | Key methods |
|---|---|---|---|
| **Tool** | The *model* decides to call it | A function the model may invoke | `tools/list`, `tools/call` |
| **Resource** | The *host application* decides to attach it | A URI-addressable piece of context | `resources/list`, `resources/read`, `resources/templates/list` |
| **Prompt** | The *user* picks it | A reusable message template | `prompts/list`, `prompts/get` |

Resources are URI-identified and often read-only: a `file://` path, a `rapido://` pseudo-URI you invent, anything. The host application, not the model, decides what enters the context window. That is the single biggest reason resources exist — they let you control context without spending a tool call.

Prompts are the reverse of tools: templates the user explicitly selects, so they are the right home for "explain my ride history in my style" rather than anything the model should do on its own.

## 6. What a tool definition must contain

| Field | Required | What it does |
|---|---|---|
| `name` | yes | Unique identifier the model calls by. |
| `inputSchema` | yes | JSON Schema for the arguments. |
| `title` | no | Human-facing display name. |
| `description` | no | The hint the model reads to decide whether to call it. This is the whole game. |
| `outputSchema` | no | JSON Schema for a structured result. |
| `annotations` | no | Hints like "read-only" or "destructive". Clients MUST treat these as untrusted unless the server is trusted. |

On `inputSchema`: the 2025-06-18 spec restricts it to an inline object shape — `type: "object"` with `properties` and `required`. The 2026-07-28 spec widens it to JSON Schema 2020-12, allowing composition and `$ref`, but warns that type constraints inside non-matching `oneOf` branches are not enforced.

Two obligations follow. Servers **MUST** validate every tool input against the schema — a schema is a contract, not documentation. And if you declare an `outputSchema`, you **MUST** return a conforming structured result; for backward compatibility you should also return the serialised JSON in a `TextContent` block.

Why this matters for a Rapido server: `description` is not documentation. It is the model's entire evidence for whether to call your tool. A vague description means the model calls the wrong tool or ignores it. This is the field to spend the most time on, and the one most teams write last. See also the [tools page](https://modelcontextprotocol.io/specification/2025-06-18/server/tools.md).

## 7. Two client-side features you will not use on day one

**Sampling** (`sampling/createMessage`) lets your server ask the client's model to do a sub-task. The client keeps the model choice and the permissions, which is why a server needs no API key. Your server may express `modelPreferences` with cost, speed and intelligence priorities, and the client may map those hints to whatever model it has.

**Roots** (`roots/list`) lets the client declare filesystem boundaries — the directories it is willing to expose. Your server asks; it does not assume.

For a ride-booking server, both are worth knowing and neither is worth building first.

## 8. What the spec does not decide

Read this before you design your interface, because it is the freedom you are about to spend. The spec is explicit that "implementations are free to expose tools through any interface pattern". Your tools can be 3 fine-grained calls or 1 coarse call. The spec does not rank them.

What does rank them is vendor guidance, and both vendors point the same way. Anthropic's tool-use documentation says to "consolidate related operations into fewer tools… fewer, more capable tools reduce selection ambiguity", and their research on writing tools for agents says "more tools don't always lead to better outcomes" and that a tool "can consolidate functionality, handling potentially multiple discrete operations… under the hood".

That is the whole argument for code mode, and [Plain tools vs code mode](plain-tools-vs-code-mode.md) takes it apart properly.

## See also

- [Plain tools vs code mode](plain-tools-vs-code-mode.md)
- [Node vs Bun vs Python for an MCP server](runtime-node-vs-bun-vs-python.md)
- [Building for an API that changes without notice](building-for-an-api-that-changes.md)
- [Home](../Home.md)
- [CONTEXT.md](../../CONTEXT.md) for the shared vocabulary.
