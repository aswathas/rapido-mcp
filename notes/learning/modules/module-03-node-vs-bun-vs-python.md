---
title: Module 03 — Node vs Bun vs Python
type: learning
tags:
  - runtime
  - typescript
  - node
updated: 2026-11-20
---

# Module 03 — Node vs Bun vs Python

The runtime is already chosen. This module teaches you to defend that choice from requirements, not from taste.

## Why this matters for rapido-mcp

A tool `inputSchema` is a contract with the model. The runtime you pick decides who catches you when that contract breaks.

- **Node 23 with TypeScript** is the decision of record, logged as D-008 and D-009.
- **The type gate** is the strongest single reason, because the schema and the handler must agree.
- **One maintainer** on a public repo means every extra moving part is paid for by one person.
- **The decoder boundary** still has to sit somewhere, whatever runtime you pick.

If you cannot justify the runtime from requirements, you cannot review a PR that changes it.

## What you will be able to do

After this module you can:

1. Explain what an SDK conformance tier does and does not promise.
2. Name the ten official MCP SDKs and their three tiers.
3. Read the version table and say which line a new server should use.
4. Explain why the Node-versus-Bun question is a runtime-quality question.
5. Read the five closed Bun-specific SDK issues as a signal, not a verdict.
6. State the reasoning that would flip the choice to Bun, to Python, or to Go.

## The mental model

Hold three separate decisions apart. They are usually collapsed into one argument.

```text
SDK tier      -> does the SDK speak the protocol correctly?
Runtime       -> does your language run well here, and does it check your work?
Type gate     -> does the compiler stop you when the schema and the handler disagree?
```

A Tier-1 SDK tells you the library is conformant and stable. It says nothing about whether your own code stays honest.

The runtime is the layer that decides whether a mistake becomes a compile error or a customer-visible bug.

The type gate is the part people forget to separate. It is not a language feature you get for free. It is a property of the toolchain you run on every save.

> **The mental model:** the SDK decides protocol correctness. The runtime decides whether you find out early.

For this server the early finding is the whole game. The model reads a schema and calls a tool. If the schema and the handler disagree, the failure lands on a user's ride.

## The core content

### What a conformance tier means

MCP has **ten official SDKs**, and they are tiered by conformance. This matters more than raw language preference. A Tier-1 SDK passes 100% of the conformance suite and is required to have stable releases.

| Tier | SDKs | What the tier means |
|---|---|---|
| **Tier 1** | TypeScript, Python, C#, Go | 100% conformance pass, stable release required |
| **Tier 2** | Java, Rust | Conformance work in progress |
| **Tier 3** | Swift, Ruby, PHP, Kotlin | Early |

The tier describes the SDK, not your application built on it. A conformant SDK can still ship a tool whose schema lies.

Current versions, checked against the release feeds (verified 2026-11-20):

| SDK | Current version | Notes |
|---|---|---|
| TypeScript (v2 line) | `@modelcontextprotocol/server` **2.4.0** and `@modelcontextprotocol/client` **2.4.0** | The v2 line is stable, split into two packages, implementing the 2026-07-28 spec. |
| TypeScript (legacy) | `@modelcontextprotocol/sdk` **1.32.2** | Stays on `v1.x`, with fixes for at least six months after v2 ships. |
| Python | `mcp` **2.3.0** | On PyPI, stable, needs Python 3.10+. Version 1.30.0 is also maintained. |
| Go | **v1.8.0** | Tier 1, stable, maintained in collaboration with Google. |

One decision is already made for us. Whichever of Node or Bun we pick, it is the same SDK and the same spec version. The TypeScript SDK's v2 documentation states it runs on "Node.js, **Bun**, and Deno".

### The runtime comparison

| Dimension | Node + TS | Bun + TS | Python |
|---|---|---|---|
| **Type safety** | `tsc` type-checks. A real compile gate. | Bun runs TypeScript *without* checking types. You need `bun check` or `tsc` in CI. | Type hints are static in the checker but not enforced at runtime. No compile step. |
| **Test runner** | `node:test` — stable since Node 20, ships with the runtime. | `bun test` — Jest-compatible, snapshots built in. | `pytest` — mature, huge plugin ecosystem. |
| **HTTP client** | Global `fetch` / undici. Solid, standards-based. | `Bun.fetch`. Fast, and the API differs in places from the standard. | `httpx` — sync and async, HTTP/1.1 and HTTP/2. Best of the three. |
| **Single binary** | Node SEA (`--build-sea`). Workable, still maturing. | `bun build --compile`. The cleanest one-shot binary of the three. | PyInstaller. Works, bulky, and needs its own update story. |
| **Packaging** | npm. Simple. | `bun install`. Compatible with npm. | pip plus a venv. More ceremony, more ways to break a user's install. |
| **Startup time** | No primary-source measurement found for any of the three. Any startup claim you see is unsourced. Do not design around it. | | |

Read the startup row as written. No primary-source measurement exists for any runtime. Every startup claim seen so far was unsourced.

### Why Bun is not an SDK question

The SDK tier table is identical for Node and Bun. Both use `@modelcontextprotocol/server` 2.4.0 against the same spec version.

So the Bun question is not "which SDK do I get". It is "how good is the runtime I run it on".

That reduces to a short list. Does the runtime check my types? Does its test runner cost me dependencies? Does its HTTP client match the standard? Can it ship a clean binary?

### The five Bun-specific SDK issues

The TypeScript SDK docs say Bun is supported. But the SDK's issue tracker has a recurring pattern of Bun-specific breakage:

| Issue | Link |
|---|---|
| #1269 | [typescript-sdk#1269](https://github.com/modelcontextprotocol/typescript-sdk/issues/1269) |
| #709 | [typescript-sdk#709](https://github.com/modelcontextprotocol/typescript-sdk/issues/709) |
| #91 | [typescript-sdk#91](https://github.com/modelcontextprotocol/typescript-sdk/issues/91) |
| #201 | [typescript-sdk#201](https://github.com/modelcontextprotocol/typescript-sdk/issues/201) |
| #211 | [typescript-sdk#211](https://github.com/modelcontextprotocol/typescript-sdk/issues/211) |

All five were Bun incompatibilities, and all are closed.

Read that as a statement about the ecosystem, not as a strike against Bun. The SDK's own authors hit Bun edges repeatedly, which means the edge exists and the fix usually arrives. If we pick Bun, we expect to be the person who finds the next one.

### The recommendation, and the reasoning that would flip it

**Node + TypeScript, SDK v2 (`@modelcontextprotocol/server` 2.4.0).**

The reasoning that would flip it:

- **To Bun** if startup latency dominates our workload and we add `bun check` to CI so types are still enforced. Bun's `bun build --compile` is genuinely better than Node SEA for distribution.
- **To Python** if our team's working language is Python and we would rather not fight the toolchain. `mcp` 2.3.0 is Tier 1 and stable. `httpx` is the best HTTP client of the three, and `pytest` is the most mature test runner here. The costs are packaging friction and no compile-time schema safety.

Note that **Go** is now a Tier-1 SDK maintained with Google, at v1.8.0. It is a serious option for a server we want to ship as a single binary with zero runtime dependency. It was not in the original shortlist, and it is worth knowing it exists.

### The five project requirements that narrow the choice

The specific requirements narrow the choice further:

1. **stdio transport, one process.** The server is spawned by the MCP host. It reads stdin, writes stdout, and logs to stderr. Nothing here is exotic — all three runtimes handle it. (See [MCP from the wire up](../mcp-protocol.md) for the framing rules that apply.)
2. **One third-party REST API.** A handful of endpoints. `httpx` is objectively the best client here, and Node's `fetch` is entirely adequate.
3. **Types for a JSON Schema.** Our tool `inputSchema` must match our TypeScript types, and a compile gate catches the drift. This is the strongest argument for Node over Bun, and a real argument for TypeScript over Python.
4. **Tests against fixtures.** Because the backend is pluggable, most of our tests never touch the network. That makes the test-runner quality matter more than HTTP performance. (See [Building for an API that changes](../building-for-an-api-that-changes.md).)
5. **Public repo, one maintainer.** The lowest-friction stack for a solo maintainer wins.

```text
Node + TS    Tier-1 SDK · tsc gate · node:test · fetch · SEA
Bun + TS     Tier-1 SDK · needs bun check in CI · bun test · best binary
Python       Tier-1 SDK · no compile gate · pytest · httpx · PyInstaller

All three work. Node wins on the type gate and zero-dependency test runner.
```

## Worked example

One tool, one deliberate bug: the handler reads a field the schema never declares.

The schema and handler, written so the compiler can connect them:

```ts
type JsonSchema = {
  type: "object";
  properties: Record<string, { type: string }>;
  required: string[];
};

type ArgsOf<S extends JsonSchema> = {
  [K in keyof S["properties"]]: string;
};

function tool<S extends JsonSchema>(schema: S, handler: (args: ArgsOf<S>) => Promise<string>) {
  return { schema, handler };
}
```

The tool itself declares only two fields, then reads a third:

```ts
const planRide = tool(
  {
    type: "object",
    properties: { pickup: { type: "string" }, drop: { type: "string" } },
    required: ["pickup", "drop"],
  },
  async (args) => "plan " + args.pickup + " -> " + args.drop + " (" + args.service + ")",
);
```

**On Node with `tsc`**, the compile gate stops it before it runs:

```text
tool.ts(21,76): error TS2339: Property 'service' does not exist on type 'ArgsOf<{ type: "object"; properties: { pickup: { type: string; }; drop: { type: string; }; }; required: string[]; }>'.
```

The handler's argument type is derived from the schema. The compiler proves `service` can never arrive. Exit code is 1.

**On Bun**, `bun run tool.ts` prints nothing and exits 0. The file ran. The types were never checked. `bun check tool.ts` reports the identical TS2339 error. So Bun can hold the same gate, but only as a step you deliberately run.

**In Python**, the same mistake is a runtime event, not a compile event:

```python
class PlanRideInput(TypedDict):
    pickup: str
    drop: str

def handler(args: PlanRideInput) -> str:
    return "plan " + args["pickup"] + " -> " + args["drop"] + " (" + args["service"] + ")"
```

```text
KeyError: 'service'
```

The error appears when that line executes. Nothing checks it earlier, unless a separate checker runs.

Same bug, three detection points. That is the entire runtime argument.

## Contrast cases

| Dimension | Node + TS | Bun + TS | Python |
|---|---|---|---|
| **Type gate** | `tsc` runs as part of the build. Always on. | `bun check` or `tsc` in CI. Opt-in by default. | A separate checker, if you run one. Never part of the runtime. |
| **Test runner** | `node:test`, ships with the runtime. Zero extra dependencies. | `bun test`, Jest-compatible, snapshots built in. | `pytest`, mature, huge plugin ecosystem. Extra dependency. |
| **HTTP client** | Global `fetch` on undici. Standard-shaped. | `Bun.fetch`. Faster, diverges from the standard in places. | `httpx`. Sync and async, HTTP/1.1 and HTTP/2. Best of the three. |
| **Packaging** | npm. Simple and familiar. | `bun install`. Compatible with npm. | pip plus a venv. More ceremony, more ways to break an install. |
| **Single binary** | Node SEA (`--build-sea`). Workable, still maturing. | `bun build --compile`. Cleanest one-shot binary of the three. | PyInstaller. Bulky, and it needs its own update story. |
| **What breaks silently** | Schema drift and backend drift. The compiler catches the first, not the second. | Schema drift and backend drift. Both are silent without a deliberate check step. | Schema drift, a missing key at runtime, and backend drift. Three silent paths. |

Read that last row carefully. Backend drift is silent in all three runtimes. The type gate only covers schema drift.

## Misconception clinic

**Wrong belief:** "A Tier-1 SDK is equally safe for my server, so the language is a preference."

**Why it is wrong:** Tier 1 describes the SDK, not your code on top of it. TypeScript, Python, C# and Go all pass conformance, yet only one of them gives this project a compile gate.

**Correct model:** Tier 1 buys you a conformant, stable library. The runtime buys you the moment you find out about your own mistakes.

---

**Wrong belief:** "Bun runs TypeScript, so Bun gives me the same type safety as Node."

**Why it is wrong:** Bun executes TypeScript without checking types. The gate exists only if you add `bun check` or `tsc` to CI. CI is not the same as a gate on every save.

**Correct model:** Bun and Node share a language and an SDK. They differ in whether the compiler runs by default.

---

**Wrong belief:** "Bun starts faster, so Bun wins on performance."

**Why it is wrong:** No primary-source measurement exists for any of the three runtimes. Every startup claim seen so far was unsourced, so there is nothing here to weigh against the type gate.

**Correct model:** Do not design around startup time. Weigh the type gate, the test runner and packaging instead.

---

**Wrong belief:** "Node versus Bun is an SDK question, because Bun needs a different MCP SDK."

**Why it is wrong:** Both runtimes use `@modelcontextprotocol/server` 2.4.0 against the same spec version. The v2 docs list Node.js, Bun and Deno alike. The SDK never changes.

**Correct model:** It is a runtime-quality question. Compare the type gate, the test runner, the HTTP client and the binary.

## Hands-on lab

Time: 15 minutes. Nothing to install. You need Node on `PATH`.

### Step 0 — see what you have

```powershell
node --version
tsc --version
bun --version
python --version
```

On the machine this module was written on, these reported node v23.6.1, tsc 7.0.2, bun 1.4.4 and Python 3.13.1. If `tsc` is missing, jump to Step 5.

### Step 1 — make the lab folder

```powershell
New-Item -ItemType Directory -Force -Path "C:\Users\ADMIN\projects\mcp-learning\labs\module-03"
Set-Location "C:\Users\ADMIN\projects\mcp-learning\labs\module-03"
```

### Step 2 — write the tool

Create `tool.ts` in that folder, in your editor, with this content:

```ts
type JsonSchema = {
  type: "object";
  properties: Record<string, { type: string }>;
  required: string[];
};

type ArgsOf<S extends JsonSchema> = {
  [K in keyof S["properties"]]: string;
};

function tool<S extends JsonSchema>(schema: S, handler: (args: ArgsOf<S>) => Promise<string>) {
  return { schema, handler };
}

const planRide = tool(
  {
    type: "object",
    properties: { pickup: { type: "string" }, drop: { type: "string" } },
    required: ["pickup", "drop"],
  },
  async (args) => "plan " + args.pickup + " -> " + args.drop + " (" + args.service + ")",
);

export { planRide };
```

### Step 3 — run the compile gate

```powershell
tsc --noEmit --strict tool.ts
$LASTEXITCODE
```

Expected: one error, then `1`.

```text
tool.ts(21,76): error TS2339: Property 'service' does not exist on type 'ArgsOf<{ type: "object"; properties: { pickup: { type: string; }; drop: { type: string; }; }; required: string[]; }>'.
```

The wording of the type in the message varies by `tsc` version. The error code `TS2339` and the file position are the stable parts.

What it means: the handler's argument type is derived from the schema. The compiler proves the model can never send `service`. Fix it by adding `service` to `properties`, or by removing it from the handler. Nothing ran.

### Step 4 — run the same file on Bun

```powershell
bun check tool.ts
bun run tool.ts
$LASTEXITCODE
```

Expected: `bun check` prints the same TS2339 error and exits 1. `bun run tool.ts` prints nothing and exits 0.

That pair is the Bun story in two commands. The file runs. The types are only checked when you ask.

### Step 5 — the weaker fallback when `tsc` is missing

If Step 0 showed no `tsc`, skip Step 3. Create `runtime-check.mjs` in the same folder:

```js
const schema = {
  type: "object",
  properties: { pickup: { type: "string" }, drop: { type: "string" } },
  required: ["pickup", "drop"],
};

const handler = async (args) => "plan " + args.pickup + " -> " + args.drop + " (" + args.service + ")";

const seen = new Set();
const args = new Proxy({ pickup: "Koramangala", drop: "Indiranagar" }, {
  get(target, prop) { seen.add(prop); return target[prop]; },
});

const out = await handler(args);
console.log("handler output:", out);

const unknown = [...seen].filter((k) => !(k in schema.properties));
if (unknown.length > 0) {
  console.error("MISMATCH: handler reads keys absent from inputSchema: " + unknown.join(", "));
  process.exit(1);
}
console.log("OK: handler reads only keys declared in inputSchema");
```

Run it:

```powershell
node runtime-check.mjs
$LASTEXITCODE
```

Expected, then exit code `1`:

```text
handler output: plan Koramangala -> Indiranagar (undefined)
MISMATCH: handler reads keys absent from inputSchema: service
```

This is a **weaker check**, and you should treat it as such. It only fires when the handler runs, and only for keys the handler actually reads. The compile gate fires always, on every code path, before anything executes.

Also worth knowing: Node 23.6 strips TypeScript types natively. So `node tool.ts` runs the same file with an experimental warning and exits 0. Node without `tsc` behaves like Bun here.

### Step 6 — the same bug in Python

Create `tool.py`:

```python
from typing import TypedDict

class PlanRideInput(TypedDict):
    pickup: str
    drop: str

def handler(args: PlanRideInput) -> str:
    return "plan " + args["pickup"] + " -> " + args["drop"] + " (" + args["service"] + ")"

print(handler({"pickup": "Koramangala", "drop": "Indiranagar"}))
```

Run it:

```powershell
python tool.py
```

Expected: a traceback ending in `KeyError: 'service'`, exit code 1. The mismatch surfaced only when that line ran.

## Retrieval practice

Close the note. Answer all five in writing.

1. What does a Tier-1 conformance claim promise, and what does it leave unpromised?
2. You need a tool whose `inputSchema` and handler cannot drift apart. Name the runtime you would pick and the exact command that enforces it.
3. Name the two tiers that are not Tier 1 and the SDKs in each.
4. Your colleague says startup time settles the Node-versus-Bun question. Write the sentence from the reference that stops that argument.
5. We might need a single binary with no runtime dependency on the user's machine. Which SDK is Tier 1 for that, and at what version?

## Answer key

1. It promises the SDK passes 100% of the conformance suite and ships stable releases. It leaves your own schema-to-handler agreement unpromised.
2. Node + TypeScript, enforced by `tsc --noEmit --strict`, because the compile gate runs on every build.
3. Tier 2 is Java and Rust, with conformance work in progress. Tier 3 is Swift, Ruby, PHP and Kotlin, which are early.
4. "No primary-source measurement found for any of the three. Any startup claim you see is unsourced. Do not design around it."
5. Go, at v1.8.0, maintained in collaboration with Google, because Go compiles to a self-contained binary with no runtime dependency.

## Feynman prompt

Explain the runtime choice to a non-programmer in 150 words or fewer. No jargon you cannot unpack.

Three sentences that must appear in a correct explanation:

1. All three runtimes use the same MCP SDK, so the choice is about runtime quality rather than the protocol.
2. The TypeScript SDK passes the conformance suite in every candidate language, so the tier does not choose for you.
3. Node runs the compiler on every build. A schema that disagrees with its handler fails before it reaches a user's ride.

If your explanation is missing any of those, you have not finished Module 03.

## Flashcards

| Card | Answer |
|---|---|
| What does a Tier-1 SDK promise? | 100% conformance pass and a stable release. |
| Which four SDKs are Tier 1? | TypeScript, Python, C#, Go. |
| Which SDKs are Tier 2? | Java and Rust. |
| Which SDKs are Tier 3? | Swift, Ruby, PHP and Kotlin. |
| What is the current v2 TypeScript server package and version? | `@modelcontextprotocol/server` 2.4.0. |
| What does the legacy TypeScript SDK stay on? | `@modelcontextprotocol/sdk` 1.32.2, on `v1.x`. |
| What is the current Python SDK and version? | `mcp` 2.3.0 on PyPI. |
| What does Bun do with TypeScript types by default? | It runs them without checking them. |
| Which command enforces the type gate on Node? | `tsc --noEmit --strict`. |
| How many Bun-specific SDK issues were closed, and what do they show? | Five, all closed. They show the edge is real and the fix usually arrives. |

## Spaced repetition

| Day | What to do |
|---|---|
| 0 | Read the module, do the lab, answer the quiz closed-book, grade it. |
| 1 | Re-answer the 5 quiz questions without notes. Mix in one schema question from Module 01. |
| 3 | Re-answer the quiz. Rewrite the three required Feynman sentences from memory. |
| 7 | Full quiz again. Re-do Step 3 of the lab, the compile gate. |
| 14 | Explain the runtime choice to a non-programmer in 150 words. Aim for under 3 minutes of writing. |
| 30 | Quiz plus flashcards only. If you score under 4, re-read "The core content". |
| 60 | Quiz plus the misconception clinic. If any misconception is not correctly explained, re-read that section. |

This module interleaves with the other modules. Never review the runtime alone for a full session. Mix in wire-format, tool-design and drift questions so you practise discrimination, not just recall.

## See also

- [Node vs Bun vs Python for an MCP server](../runtime-node-vs-bun-vs-python.md) — the reference note
- [Module 01 — MCP from the wire up](module-01-mcp-protocol.md)
- [Module 02 — Plain tools vs code mode](module-02-plain-tools-vs-code-mode.md)
- [Module 04 — Building for an API that changes](module-04-building-for-an-api-that-changes.md)
- [The MCP course](../course.md)
- [The server we are building](../../project/rapido-mcp-server.md)
- [Decision log](../../../docs/reviews/decision-log.md) for D-008 and D-009
- [CONTEXT.md](../../../CONTEXT.md) for the shared vocabulary
