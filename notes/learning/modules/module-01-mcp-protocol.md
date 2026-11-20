---
title: Module 01 — MCP from the wire up
type: learning
tags:
  - mcp
  - protocol
  - json-rpc
updated: 2026-11-20
---

# Module 01 — MCP from the wire up

Before you can design an MCP server, you must be able to see one. This module ends with you reading a raw session, byte by byte.

## Why this matters for rapido-mcp

Every later decision rides on this module.

- **Tool design** depends on knowing what the model actually receives.
- **Code mode versus plain tools** depends on counting round trips.
- **The decoder boundary** depends on knowing where JSON stops and your types begin.
- **The stderr rule** decides whether the server starts at all.

A server that breaks on the first message is not a bad tool surface. It is a dead process.

## What you will be able to do

After this module you can:

1. Identify a request, a response and a notification in any JSON-RPC line.
2. Explain, in one sentence each, why stdout carries MCP messages only.
3. Say which protocol era a client speaks and what changes for the server.
4. Name the three primitives and the single question that separates them.
5. List the required fields of a tool definition and the two obligations a server has.
6. Read a raw stdio session and spot the exact line where a server breaks.

## The mental model

**MCP is a phone line with a strict grammar.**

Think of three parties:

- The **client** is the MCP host. It launches or connects to the server.
- The **server** is your program. It answers requests.
- The **model** is the reason the server exists. It reads tool descriptions and decides what to call.

The phone line carries **JSON-RPC 2.0**. Nothing else. Not REST. Not GraphQL. Not protobuf. JSON-RPC has existed since 2008 and every MCP message is one of three shapes.

The mental model to hold on to:

```text
client  --request(id=1)-->  server
client  <--response(id=1)--  server
client  --notification---->  server      (no reply, ever)
```

The `id` is the whole game. It is the difference between a question and a remark.

A second mental model, for the transport:

```text
stdio  = the client spawns your server as a child process and talks over pipes
HTTP   = the client POSTs to a URL on your server and talks over a socket
```

Same protocol inside. Different plumbing. Everything in this module applies to both.

## The core content

### Three message shapes

| Shape | Has `id`? | Meaning |
|---|---|---|
| Request | yes — string or integer, never `null`, never reused | Asks for something. Gets exactly one response. |
| Response | yes — echoes the request's `id` | Carries either `result` or `error`, never both. |
| Notification | no | Fire and forget. Gets no reply. |

The source of most MCP bugs is forgetting the `id`. Send a request without one and the client waits forever for a response that was never required.

`tools/call` is a request. `notifications/initialized` is a notification. `notifications/cancelled` is a notification.

### Transport one — stdio, the local case

The client launches your server as a child process. Your server reads JSON-RPC from `stdin` and writes it to `stdout`.

Framing is **newline-delimited JSON**: one complete JSON-RPC message per line, and messages must not contain embedded newlines. A pretty-printed JSON object spanning ten lines is not a valid frame.

The rule that bites everyone:

> **stdout carries MCP messages only. stderr is free-form UTF-8 for logging.**

A stray `console.log` in a handler corrupts the stream. The client dies with a parse error that points nowhere near the cause, because the client sees garbage where it expects a frame.

In TypeScript on Node, `console.log` writes to stdout. Use `console.error` for anything that is not a protocol message.

Shutdown is a small ritual. The client closes your stdin, waits, then sends `SIGTERM`, then `SIGKILL`. Your server should notice stdin closing and exit cleanly, because whatever it was mid-way through is lost.

### Transport two — Streamable HTTP, the remote case

One endpoint serves both POST and GET.

| Direction | Rules |
|---|---|
| POST | Carries one client→server JSON-RPC message. Send `Accept: application/json, text/event-stream`. Posting a *request* gets `application/json` with a single object, or an SSE stream. Posting a *notification or response* gets `202 Accepted` with an empty body. |
| GET | Optional. Opens a standalone SSE stream for server→client pushes. Unsupported means `405 Method Not Allowed`. |
| Sessions | Optional. The server may set `Mcp-Session-Id` on the initialize response; clients must echo it on every later request. Omit the header entirely and you get a stateless server. |

Two security rules live in the same area: validate `Origin` to stop DNS rebinding, and bind to `127.0.0.1` when the server is local. "Local" in MCP means local to the client. A server bound to `0.0.0.0` is not local.

### Two eras, and this matters

The spec changed recently and most clients have not caught up.

**Legacy era, 2025-11-25 and earlier.** A handshake.

1. Client sends `initialize` carrying its `protocolVersion`, its `capabilities` and its `clientInfo`.
2. Server replies with its own `protocolVersion`, `capabilities`, `serverInfo` and optionally `instructions`.
3. Client sends `notifications/initialized`.
4. Only then does normal operation begin.

Version negotiation: the client sends a version it supports, the server replies with that same version if it can, otherwise with a different one it does support. If the client cannot live with the server's choice, it disconnects. Over HTTP, every later request must carry `MCP-Protocol-Version: <version>`.

**Modern era, 2026-07-28, current latest.**

> "There is no negotiation handshake. Every request carries its protocol version" in `_meta`. Servers **MUST** implement `server/discover`. An unsupported version returns error code `-32022` `UnsupportedProtocolVersionError`, listing the versions the server does support, and the client retries.

Practical consequence: `initialize` and `notifications/initialized` are legacy-era only. Build for the era your actual client speaks. Most third-party clients today still speak legacy.

The `initialize` response is also the easiest place to smuggle human-facing `instructions` to the model. That field is read by the model, not by the user.

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

### Three primitives, and the real distinction

Tools, resources and prompts are usually taught as "data, data, and prompts". That is wrong. The distinction is **who controls the invocation**.

| Primitive | Who triggers it | Think of it as | Key methods |
|---|---|---|---|
| **Tool** | the *model* decides to call it | a function the model may invoke | `tools/list`, `tools/call` |
| **Resource** | the *host application* decides to attach it | a URI-addressable piece of context | `resources/list`, `resources/read`, `resources/templates/list` |
| **Prompt** | the *user* picks it | a reusable message template | `prompts/list`, `prompts/get` |

Resources are URI-identified and often read-only: a `file://` path, a `rapido://` pseudo-URI you invent, anything. The host application, not the model, decides what enters the context window. That is the single biggest reason resources exist. They let you control context without spending a tool call.

Prompts are the reverse of tools: templates the user explicitly selects. They are the right home for "explain my ride history in my style", not for something the model should do on its own.

### What a tool definition must contain

| Field | Required | What it does |
|---|---|---|
| `name` | yes | Unique identifier the model calls by. |
| `inputSchema` | yes | JSON Schema for the arguments. |
| `title` | no | Human-facing display name. |
| `description` | no | The hint the model reads to decide whether to call it. This is the whole game. |
| `outputSchema` | no | JSON Schema for a structured result. |
| `annotations` | no | Hints like `read-only` or `destructive`. Clients MUST treat these as untrusted unless the server is trusted. |

On `inputSchema`: the 2025-06-18 spec restricts it to an inline object shape — `type: "object"` with `properties` and `required`. The 2026-07-28 spec widens it to JSON Schema 2020-12, allowing composition and `$ref`, but warns that type constraints inside non-matching `oneOf` branches are not enforced.

Two obligations follow.

1. Servers **MUST** validate every tool input against the schema. A schema is a contract, not documentation.
2. If you declare `outputSchema`, you **MUST** return a conforming structured result. For backward compatibility, also return the serialised JSON in a `TextContent` block.

Why this matters for a Rapido server: `description` is not documentation. It is the model's entire evidence for whether to call your tool. A vague description means the model calls the wrong tool or ignores it.

### Two client-side features you will not use on day one

**Sampling** (`sampling/createMessage`) lets your server ask the client's model to do a sub-task. The client keeps the model choice and the permissions, so a server needs no API key. Your server may express `modelPreferences` with cost, speed and intelligence priorities, and the client may map those hints to whatever model it has.

**Roots** (`roots/list`) lets the client declare filesystem boundaries — the directories it is willing to expose. Your server asks; it does not assume.

For a ride-booking server, both are worth knowing and neither is worth building first.

### What the spec does not decide

The spec is explicit that "implementations are free to expose tools through any interface pattern". Your tools can be 3 fine-grained calls or 1 coarse call. The spec does not rank them.

What does rank them is vendor guidance, and both vendors point the same way. Anthropic's tool-use documentation says to "consolidate related operations into fewer tools… fewer, more capable tools reduce selection ambiguity", and their research on writing tools for agents says "more tools don't always lead to better outcomes", and that a tool "can consolidate functionality, handling potentially multiple discrete operations… under the hood."

That is the argument for code mode, and [Module 02](module-02-plain-tools-vs-code-mode.md) takes it apart properly.

## Worked example

A complete stdio session, one message per line. This is exactly what your server sees on stdin and must write to stdout.

**1. The client opens the session.**

```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"manual-driver","version":"0.0.1"}}}
```

**2. The server answers.** One line, one object, `result` only.

```json
{"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2025-06-18","capabilities":{"tools":{}},"serverInfo":{"name":"mini-rapido","version":"0.0.1"},"instructions":"Use rapido_search_locations before planning a ride."}}
```

**3. The client confirms.** Note there is no `id`. Nothing comes back.

```json
{"jsonrpc":"2.0","method":"notifications/initialized"}
```

**4. The client asks what exists.**

```json
{"jsonrpc":"2.0","id":2,"method":"tools/list"}
```

**5. The server lists the tools.**

```json
{"jsonrpc":"2.0","id":2,"result":{"tools":[{"name":"rapido_search_locations","description":"Search Rapido for a place by free text and return candidate place ids.","inputSchema":{"type":"object","properties":{"searchWord":{"type":"string"}},"required":["searchWord"]}}]}}
```

**6. The client calls the tool.**

```json
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"rapido_search_locations","arguments":{"searchWord":"Koramangala"}}}
```

**7. The server returns content.** Two parts: the human-visible text block and the structured result.

```json
{"jsonrpc":"2.0","id":3,"result":{"content":[{"type":"text","text":"Koramangala, Bengaluru"}],"structuredContent":{"placeIds":["ChIJ1"]}}}
```

Read that trace for the four rules it hides.

| Rule | Where the trace shows it |
|---|---|
| `id` decides the shape | `id:1,2,3` get answers, `notifications/initialized` gets none. |
| One message per line | Every block above is a single line, however long. |
| stdout is protocol only | Nothing but JSON-RPC objects appear on stdout. Logs would break this. |
| `result` or `error`, never both | Every response carries exactly one of them. |

Now watch it break. Add one line to a handler:

```js
console.log("picked", place.name);   // goes to stdout. corrupt.
```

The client is now reading this as a frame:

```text
picked Koramangala
```

That is not JSON-RPC. The client's parser fails, it reports a parse error, and the error mentions the transport rather than your handler. The fix is one character: `console.error`.

## Contrast cases

### Message shapes

| | Request | Response | Notification |
|---|---|---|---|
| Has `id` | yes | yes, echoes the request | no |
| Direction | client → server | server → client | client → server |
| Gets a reply | yes, exactly one | it is the reply | no |
| Example | `tools/call` | the tool result | `notifications/initialized` |

### Protocol eras

| | Legacy | Modern |
|---|---|---|
| Session start | `initialize` handshake | none |
| Version location | negotiation, then a header | `_meta` on every request |
| `notifications/initialized` | required | none |
| `server/discover` | not required | **MUST** |
| Unknown version | client disconnects | error `-32022`, client retries |

### Transports

| | stdio | Streamable HTTP |
|---|---|---|
| Who starts it | the client spawns the process | the client POSTs to a URL |
| Framing | newline-delimited JSON | HTTP body, JSON or SSE |
| Session id | not applicable | optional `Mcp-Session-Id` |
| Local binding | inherited from the process | `127.0.0.1` when local |
| Network exposure | none | possible, so validate `Origin` |

### Primitives

| | Tool | Resource | Prompt |
|---|---|---|---|
| Who triggers | the model | the host app | the user |
| Model decides to call it | yes | no | no |
| Costs a tool call | yes | no | no |
| URI addressed | no | yes | no |
| Rapido example | `rapido_plan_ride` | `rapido://ride/<orderId>` | "Summarise my last ride" |

## Misconception clinic

**Wrong belief:** "Declaring `outputSchema` means the client validates my output."

**Why it is wrong:** The client validates **input** against `inputSchema`. Output conformance is the server's obligation, and nothing enforces it. A non-conforming result is silently wrong.

**Correct model:** Validate input yourself. If you declare `outputSchema`, produce a conforming result and also emit the serialised JSON as a `TextContent` block for older clients.

---

**Wrong belief:** "Every MCP session starts with `initialize`."

**Why it is wrong:** Only the legacy era has a handshake. The 2026-07-28 spec has no negotiation at all, and an unsupported version is answered with `-32022` plus a retry.

**Correct model:** Read the client version. Support the legacy handshake, implement `server/discover`, and treat `initialize` as optional.

---

**Wrong belief:** "Tools, resources and prompts are three ways to send text."

**Why it is wrong:** They differ in who decides to send, not in what they carry. That difference changes the cost, the timing and who sees the result.

**Correct model:** Model triggers tools. The host triggers resources. The user triggers prompts. Pick the primitive whose trigger you want.

---

**Wrong belief:** "A tool's `description` is documentation for me."

**Why it is wrong:** The model reads it as the only evidence it has for whether to call the tool. A vague description makes your tool invisible or makes the model call the wrong one.

**Correct model:** Write the description for the model. Say what it does, when to use it, what it returns and what it must not be used for.

## Hands-on lab

Time: 15 minutes. Nothing to install. You need Node 23 on `PATH`; check with `node --version`.

The lab folder is in the separate learning repo, so your public project stays clean:

```text
C:\Users\ADMIN\projects\mcp-learning\labs\module-01\
```

### Step 1 — write a server with no SDK

Create `C:\Users\ADMIN\projects\mcp-learning\labs\module-01\server.js` with this content:

```js
const readline = require('node:readline');

const TOOLS = [
  {
    name: 'rapido_search_locations',
    description: 'Search Rapido for a place by free text and return candidate place ids.',
    inputSchema: {
      type: 'object',
      properties: { searchWord: { type: 'string' } },
      required: ['searchWord']
    }
  }
];

function handle(msg) {
  if (msg.id === undefined) return null; // notification: no reply
  if (msg.method === 'initialize') {
    return {
      jsonrpc: '2.0',
      id: msg.id,
      result: {
        protocolVersion: '2025-06-18',
        capabilities: { tools: {} },
        serverInfo: { name: 'mini-rapido', version: '0.0.1' },
        instructions: 'Use rapido_search_locations before planning a ride.'
      }
    };
  }
  if (msg.method === 'tools/list') {
    return { jsonrpc: '2.0', id: msg.id, result: { tools: TOOLS } };
  }
  if (msg.method === 'tools/call') {
    return {
      jsonrpc: '2.0',
      id: msg.id,
      result: {
        content: [{ type: 'text', text: 'Koramangala, Bengaluru' }],
        structuredContent: { placeIds: ['ChIJ1'] }
      }
    };
  }
  return { jsonrpc: '2.0', id: msg.id, error: { code: -32601, message: 'Method not found' } };
}

const rl = readline.createInterface({ input: process.stdin, crlfDelay: Infinity });
rl.on('line', (line) => {
  if (!line.trim()) return;
  let msg;
  try {
    msg = JSON.parse(line);
  } catch {
    process.stderr.write('bad json\n');
    return;
  }
  const reply = handle(msg);
  if (reply) process.stdout.write(JSON.stringify(reply) + '\n');
});
```

### Step 2 — drive it by hand

Run this in PowerShell:

```powershell
$msgs = @(
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"manual-driver","version":"0.0.1"}}}',
  '{"jsonrpc":"2.0","method":"notifications/initialized"}',
  '{"jsonrpc":"2.0","id":2,"method":"tools/list"}',
  '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"rapido_search_locations","arguments":{"searchWord":"Koramangala"}}}'
)
($msgs -join "`n") | node "C:\Users\ADMIN\projects\mcp-learning\labs\module-01\server.js"
```

Expected: three response lines and no reply for the notification. Read them and check the `id` on each.

### Step 3 — break stdout on purpose

Add this line at the top of the `tools/list` branch in `server.js`:

```js
console.log('debug: listing tools');
```

Re-run the command from Step 2.

Expected: the output now contains a line that is not JSON. Your client would fail to parse it. That is the whole lesson of the stdout rule.

### Step 4 — break the notification rule

Change the notification guard from `if (msg.id === undefined) return null;` to a branch that always replies.

Re-run.

Expected: a response to `notifications/initialized` that echoes no `id`, or an `id` the client never sent. The client either rejects the frame or waits for a response that was never required.

### Step 5 — check your own reading

Run this and read every byte:

```powershell
(Get-Content -Raw "C:\Users\ADMIN\projects\mcp-learning\labs\module-01\server.js").Length
```

Not a test of the protocol. A reminder that the whole server is text you can read.

## Retrieval practice

Close the note. Answer all five in writing.

1. You declare `outputSchema` on `rapido_plan_ride`. What must the tool return, and what does the client actually enforce?
2. A client sends `{"jsonrpc":"2.0","method":"notifications/initialized"}`. What does your server do, and why does the client not hang?
3. Your handler contains `console.log("booked", orderId)`. What breaks, where does the client notice, and why does the error point nowhere near the cause?
4. Which methods must a server implement under the 2026-07-28 spec that a legacy-era server never needed?
5. Give one resource and one prompt for a Rapido server, and say who triggers each.

## Answer key

1. It must return a structured result conforming to the declared schema, and should also return the serialised JSON in a `TextContent` block. The client enforces **input** validation only; output conformance is the server's own obligation.
2. It returns nothing, because a notification has no `id` and therefore no reply. The client does not hang because a notification is fire-and-forget by definition.
3. The stdout stream is corrupted. The client fails to parse the frame and reports a transport-level parse error, because the offending line carries no line number, no method name and no error context from your handler.
4. `server/discover`. The legacy handshake (`initialize`, `notifications/initialized`) disappears entirely in the modern era.
5. Resource: `rapido://ride/<orderId>`, triggered by the host application when it attaches ride context. Prompt: "Summarise my rides in my own style", triggered by the user picking it.

## Feynman prompt

Explain MCP to a friend who has never heard of it, in 150 words or fewer. No jargon you cannot unpack.

Three sentences that must appear in a correct explanation:

1. MCP is JSON-RPC 2.0 messages, and the `id` decides whether the message expects a reply.
2. stdout carries protocol messages only, so logs go to stderr.
3. Tools, resources and prompts differ by who triggers them: the model, the host, or the user.

If your explanation is missing any of those, you have not finished Module 01.

## Flashcards

| Card | Answer |
|---|---|
| What decides whether a JSON-RPC message expects a reply? | The presence of `id`. |
| What must never be `null`? | The `id` of a request. |
| Where do logs go in a stdio MCP server? | stderr. |
| What is the framing for stdio transport? | Newline-delimited JSON, one whole message per line. |
| What does the client send after `initialize` in the legacy era? | `notifications/initialized`. |
| What does the modern era use instead of a handshake? | `protocolVersion` in `_meta` on every request, plus `server/discover`. |
| What error code does an unsupported protocol version return? | `-32022` `UnsupportedProtocolVersionError`. |
| Who triggers a tool? | The model. |
| Who triggers a resource? | The host application. |
| Who triggers a prompt? | The user. |
| Which tool fields are required? | `name` and `inputSchema`. |
| What must a server do about tool input? | Validate it against `inputSchema`. |
| What is `Mcp-Session-Id`? | An optional HTTP session identifier the client echoes on later requests. |

## Spaced repetition

| Day | What to do |
|---|---|
| 0 | Read the module, do the lab, answer the quiz closed-book, grade it. |
| 1 | Re-answer the 5 quiz questions without notes. Mix in one question from another module. |
| 3 | Re-answer the quiz. Rewrite the three required Feynman sentences from memory. |
| 7 | Full quiz again. Re-do Step 3 of the lab, the stdout corruption. |
| 14 | Explain the module to a non-programmer in 150 words. Aim for under 3 minutes of writing. |
| 30 | Quiz plus flashcards only. If you score under 4, re-read the module. |
| 60 | Quiz plus the misconception clinic. If any misconception is not correctly explained, re-read that section. |

This module interleaves with the others. Never review MCP alone for a full session. Mix in tool-design, runtime and drift questions so you practise discrimination, not just recall.

## See also

- [MCP protocol from the wire up](../mcp-protocol.md) — the reference note
- [Module 02 — Plain tools vs code mode](module-02-plain-tools-vs-code-mode.md)
- [Module 04 — Building for an API that changes](module-04-building-for-an-api-that-changes.md)
- [The MCP course](../course.md)
- [The server we are building](../../project/rapido-mcp-server.md)
- [CONTEXT.md](../../../CONTEXT.md) for the shared vocabulary
