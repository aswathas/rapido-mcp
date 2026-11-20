---
title: Module 04 — Building for an API that changes
type: learning
tags:
  - api-robustness
  - drift
  - rapido
updated: 2026-11-20
---

# Module 04 — Building for an API that changes

Rapido ships no public API. You code against a backend with no contract, no changelog and no promise to tell you when it moves. This module teaches you to notice that move and to survive it.

## Why this matters for rapido-mcp

Every tool in this server reads a response nobody wrote a spec for. That single fact decides how you build.

- `rapido_search_locations` is the only fully verified operation today.
- `rapido_plan_ride` depends on field names from third-party prior art.
- `rapido_book_ride` spends money, so a silent wrong answer is expensive.

A backend can change under a green build. A field rename leaves every parse succeeding and every test passing. The tool then reports "no rides available" when twelve rides exist. That reads as a fact about the world.

## What you will be able to do

After this module you can:

1. Explain why a fixture test cannot detect drift.
2. Name the five kinds of break and how each one appears.
3. Describe the job of each of the five robustness layers.
4. Write a fingerprint function that reads a response's key shape.
5. Say which layer catches a renamed field, and which misses it.
6. Explain the typed error codes to a model in one sentence each.

## The mental model

**The contract is implicit.** Rapido publishes no API, so no document tells you what changed. The contract is whatever the server returns today.

That gives your server two jobs, and they are different jobs.

**Notice** that the contract moved. Only a live call can do this.

**Survive** that it moved. A recorded response and a registry of decoders can do this.

Hold the two apart and the whole design follows. Fixtures handle survival. Only a live probe handles notice.

```text
fixture  →  "did I break something?"     →  offline, every commit
probe    →  "did the world change?"      →  live, on a schedule
```

The evidence that this is real is on the public record. The one public Rapido skill on GitHub carries this note from March 2026.

> "Fare estimates and booking return encoded binary due to a protobuf schema change — a new HAR capture is needed."

Booking broke for third-party clients, silently, on an ordinary working day.

## The core content

### Fixtures are for regression. Probes are for detection.

A fixture is a recording of what Rapido returned on one day. The test runs your code against that recording.

Rapido changes the API. Your recording is unchanged. Your test still passes. The test never talks to Rapido, so it cannot detect the change.

> **Fixtures are for regression. Probes are for detection.** A fixture suite is green forever by construction. Only something that actually contacts the live API can tell you the API moved.

Fixtures are how we develop offline and prove a change did not break the old behaviour. Probes are how we find out about *their* changes.

### The five kinds of break

| Break | How it appears | How you notice |
|---|---|---|
| **Body format changes** — JSON becomes protobuf binary | Parse error, or nonsense bytes | The parser itself fails |
| **Field renamed** — `data.quotes` → `data.fareOptions` | **Nothing.** It parses fine and hands back empty data | Only an assertion can catch this |
| **Endpoint moved** | 404, or 200 with an error body | A health probe on a known-good endpoint |
| **Auth changed** — new header, new token format | 401 on every call, including ones that used to work | Auth check, kept distinct from drift |
| **New required field** | 400, or the field is silently ignored | Response-side invariant catches the silent case |

The renamed field is the dangerous one. The request succeeds, the response parses, the status is 200. The tool returns "no rides available" when there are twelve.

### Layer 1 — The health probe

Before anything else, ask a cheap question: *is the API still there?*

Rapido's cheapest check is `POST /unup/autocomplete/location`. It needs no auth and causes no side effects. It is live-verified, returning HTTP 200 with a real body. If that call fails, every other call will fail too.

Fail fast with `BACKEND_UNREACHABLE` rather than letting each tool produce its own confusing error. One clear error beats five.

### Layer 2 — The decoder registry

This layer turns "the API changed" from a catastrophe into a small addition. Record responses and give each one a **fingerprint** — which keys are present, what the top-level shape is. Decoders register against fingerprints, not versions.

```text
{ data: { quotes: [...] } }      → json.v1     → FareEstimateResponse
{ data: { fareOptions: [...] } } → json.v2     → FareEstimateResponse
<binary>                         → protobuf.v1 → FareEstimateResponse
```

All three decoders return the *same* internal type, so the tool layer never knows which one fired. The March 2026 break stops being a rewrite. You add one new decoder entry — `protobuf.v1` — plus a fingerprint matcher for the binary body. `json.v1` keeps working for anyone still on the old format.

**Why fingerprint rather than version?** Because Rapido does not version. Keying decoders on "v1, v2, v3" would be guessing their number. Two different changes could produce the same number. A fingerprint is observed truth.

### Layer 3 — Invariants asserted on meaning

This is the layer that catches the invisible break. An invariant is a statement about what the response must *mean*, not about which key holds it.

```text
path     data.quotes[0].fare must exist
meaning  a quote must carry a fare
```

The path version tells you a field moved. The meaning version tells you what broke. The invariants for a quote list:

- the response contains a list of quotes;
- each quote carries a service, a fare, a distance and a duration;
- the fare parses as a number;
- the service is one of the known service types.

Because the invariant names the requirement, a rename produces a message a human can act on. It reads *"a quote must have a fare"*, not *"expected property 'fare' at data.quotes[0]"*.

### Layer 4 — Typed errors, with hints

The model is the consumer of our error messages. A stack trace is not an error message for a model. It is noise it may hallucinate meaning from. A bare "500 Internal Server Error" is worse. It says nothing about whether to retry, and a blind retry loop is how we burn money.

| Code | Means | What the model should do |
|---|---|---|
| `BACKEND_UNREACHABLE` | Even the health probe failed | Stop. Tell the user Rapido's API is not responding. |
| `BACKEND_DRIFT` | A response arrived but broke an invariant | Stop. Tell the user the API shape changed. Do not retry. |
| `AUTH_EXPIRED` | 401, or a missing session | Tell the user to run `rapido-mcp login`. Retry after they do. |
| `QUOTE_EXPIRED` | The quote id is older than its validity window | Re-plan, then present new quotes to the user. |
| `NO_SERVICE_AVAILABLE` | No service type runs at that pickup point | Tell the user, and suggest a different pickup. |
| `RIDE_NOT_CANCELLABLE` | The order cannot be cancelled in its current state | Tell the user why. Do not retry. |

Three of those say *stop*, and three say *here is the next action*. A model that knows which is which behaves sanely. A model that only sees failures will retry everything.

### Layer 5 — The live probe

The only component that can answer "did Rapido change?"

`npm run probe:live` makes real calls with real credentials and runs the same invariant checks the offline tests use. When it fails, Rapido moved, and we know before a user does.

```text
CI     fixtures only, offline, every commit
probe  live calls, same invariants, on a schedule

Same assertions. Two triggers. One implementation of the rules.
```

The invariant rules are written **once** and used in both places. A fixture test and the live probe run the same assertion code. The probe is the same rules pointed at a different input.

Run it on a schedule, not on demand. The value of a probe is noticing the change on Tuesday. It is not noticing it on the Saturday when someone tries to book a ride.

### Two consequences that fall out of this

**Quotes expire, and the server has to know.** We chose two-step booking. `plan_ride` returns quotes, `book_ride` takes a quote id. The quote has a validity window, and Rapido's side will reject a stale one. So the server stores quotes with a timestamp and refuses a stale one with `QUOTE_EXPIRED` and a clear hint: re-plan.

**Service availability is discovered, never assumed.** Bike taxi, auto and cab do not run in the same places. "Rapido has autos" is true of Bengaluru and false of Chennai. So availability is a discovery step, not a constant. `plan_ride` returns only the services actually available there, each with its own fare.

### What this does and does not buy us

This design does **not** make Rapido's API stable. It makes *us* able to absorb a change in an afternoon instead of a week. A failing test names the broken requirement instead of a stack trace.

It also does not remove the ToS question. A robust client for a forbidden API is still a client for a forbidden API. The engineering and the legal question are separate. The legal one is decided by D-010: build and test locally first. Keep the live client out of the public repo until we have chosen what to publish.

## Worked example

Take the response this module's lab fetches live. The endpoint is `POST /unup/autocomplete/location`. The body is `{"searchWord":"Koramangala"}`. The base URL is `https://m.rapido.bike/pwa/api`.

The live response has two top-level keys, `info` and `data`. `info` carries `status`. `data` is a list. Each entry carries `placeId`, `description` and `name`.

**Layer 1 passes.** The endpoint answers 200 with a real body. Nothing here suggests trouble.

**Layer 2 reads the fingerprint.** The key shape is `data:[{description,name,placeId}],info:{status}`. The registry looks up that fingerprint, finds a decoder, and hands the tool layer the server's own place type.

**Layer 3 checks meaning.** The invariants ask for a list of places. Each place must carry an identifier and a name. Both hold. The response is accepted.

Now suppose Rapido renames `placeId` to `id`. Nothing in the response breaks. The JSON still parses, the status is still 200, and the tool still returns a list.

The layers respond differently:

| Layer | Reaction to the rename |
|---|---|
| Health probe | **Misses it.** The endpoint still answers 200. |
| Decoder registry | **Detects an unknown shape.** The fingerprint no longer matches any registered decoder. |
| Meaning invariant | **Names the broken requirement.** "A place must carry an identifier" fails. |
| Typed error | Reports `BACKEND_DRIFT` and tells the model to stop. |

The registry on its own only knows the shape changed. The invariant is the layer that says what broke, in words a human can act on.

The same logic applies if `data.quotes` becomes `data.fareOptions`, the exact rename in the source table. The parser succeeds, so only an assertion catches it. That assertion asks whether a quote still carries a fare.

## Contrast cases

| Pair | Aspect | Fixture test | Live probe |
|---|---|---|---|
| Fixture test vs live probe | What it can detect | That your code still parses what it parsed. | That Rapido still serves the shape your code expects. |
| Fixture test vs live probe | What it costs | Free, offline, deterministic. | Network calls, rate limits, occasional flakiness. |
| Fixture test vs live probe | When it runs | On every commit, in CI. | On a schedule, whether or not anyone committed. |
| Fixture test vs live probe | What it proves | Our change is safe. | The world is unchanged. It proves nothing about our change. |
| Meaning invariant vs path assertion | What it can detect | A renamed field, and which requirement broke. | A renamed field, and which key moved. |
| Meaning invariant vs path assertion | What it costs | One rule per requirement. Cheap and reusable across shapes. | One rule per key path. Every rename needs a new rule. |
| Meaning invariant vs path assertion | When it runs | After decoding, on every response. | After decoding, on every response. |
| Meaning invariant vs path assertion | What it proves | The response still means what it must mean. | The response still has the keys it had. |

## Misconception clinic

**Wrong belief: a green fixture suite means the integration works.**
It does not. A fixture suite is green forever by construction, because it never contacts Rapido. It proves your code still handles an old recording. It cannot tell you Rapido changed.

**Wrong belief: a 200 response means the response is correct.**
A 200 only means the endpoint answered. A renamed field returns 200 with a valid JSON body and no data. The parse succeeds and the payload is empty. Only an invariant catches that case.

**Wrong belief: versioning the decoders would be simpler.**
Rapido does not version. A "v2" decoder would be a guess about a number they never assigned. Two different changes could land on the same guessed number. A fingerprint is observed truth.

**Wrong belief: if the server is robust, the legal question goes away.**
It does not. A robust client for a forbidden API is still a client for a forbidden API. The engineering and the legal questions are separate. D-010 decides the legal one.

## Hands-on lab

You will fetch one live response, derive its fingerprint, then rename a key and watch the fingerprint change. Budget about ten minutes. Everything below runs in Windows PowerShell 5.1 with Node 23.

Both endpoints used here are no-auth and side-effect free. Never call an endpoint that sends an OTP, books a ride or cancels a ride.
### Step 1 — set up a folder

```powershell
$lab = "C:\Users\ADMIN\projects\mcp-learning\labs\module-04"
New-Item -ItemType Directory -Force -Path $lab | Out-Null
```

### Step 2 — fetch the live response and save it

```powershell
$r = Invoke-RestMethod -Uri "https://m.rapido.bike/pwa/api/unup/autocomplete/location" -Method Post -Body '{"searchWord":"Koramangala"}' -ContentType "application/json" -TimeoutSec 30
$r | ConvertTo-Json -Depth 10 | Set-Content -Path "$lab\rapido-autocomplete.json" -Encoding utf8
```

You should see a body with `info` and `data` keys. `data` holds a list of place objects.
### Step 3 — print the top-level keys

```powershell
(Get-Content "$lab\rapido-autocomplete.json" -Raw | ConvertFrom-Json).PSObject.Properties.Name
```

Expected output:

```text
info
data
```

### Step 4 — derive a fingerprint from the key shape

This one-liner walks the object and prints the shape of every key it finds. It is the layer 2 matcher in miniature.

```powershell
node -e "const fs=require('fs');const fp=v=>{if(Array.isArray(v))return '['+(v.length?fp(v[0]):'')+']';if(v===null)return 'null';if(typeof v!=='object')return typeof v;return '{'+Object.keys(v).sort().map(k=>k+':'+fp(v[k])).join(',')+'}';};console.log(fp(JSON.parse(fs.readFileSync(process.argv[1],'utf8').replace(/^\uFEFF/,''))));" "$lab\rapido-autocomplete.json"
```

Expected output:

```text
{data:[{description:string,name:string,placeId:string}],info:{status:string}}
```

The `replace(/^\uFEFF/,'')` strips the byte order mark that `Set-Content -Encoding utf8` writes in PowerShell 5.1. Without it, `JSON.parse` fails on the first character.

### Step 5 — rename a key and watch the fingerprint change

This reads the saved file, renames `placeId` to `id` in every entry, writes a second file, and prints both fingerprints.

```powershell
node -e "const fs=require('fs');const fp=v=>{if(Array.isArray(v))return '['+(v.length?fp(v[0]):'')+']';if(v===null)return 'null';if(typeof v!=='object')return typeof v;return '{'+Object.keys(v).sort().map(k=>k+':'+fp(v[k])).join(',')+'}';};const o=JSON.parse(fs.readFileSync(process.argv[1],'utf8').replace(/^\uFEFF/,''));const r=JSON.parse(JSON.stringify(o));r.data.forEach(d=>{d.id=d.placeId;delete d.placeId;});fs.writeFileSync(process.argv[2],JSON.stringify(r,null,2));console.log('before: '+fp(o));console.log('after : '+fp(r));" "$lab\rapido-autocomplete.json" "$lab\rapido-renamed.json"
```

Expected output:

```text
before: {data:[{description:string,name:string,placeId:string}],info:{status:string}}
after : {data:[{description:string,id:string,name:string}],info:{status:string}}
```

The response is still valid JSON. The status was 200. Nothing crashed. Only the fingerprint moved, and a meaning-level invariant would now fail on the missing identifier.

### If a step fails

Network errors, TLS interception and corporate proxies all break step 2 outside your control. Read the error, report it, and continue with a saved copy. Do not substitute a made-up response.

## Retrieval practice

Close the note. Answer all five in writing.

1. A fixture test passes after Rapido renames a response field. Why does it still pass, and what would have to run to catch the rename?
2. Name the five kinds of break and say which one produces no error at all.
3. Why does the decoder registry key on a fingerprint rather than a version number?
4. Your quote list returns twelve entries and every entry has a fare. What invariant still might fail, and what error code would the server return?
5. The live probe fails with `BACKEND_DRIFT` on a Tuesday. What has changed, what has not changed, and what must the tool not do?

## Answer key

1. The fixture is an old recording, so it still holds the old field name. The test proves nothing about today. A live probe, or the invariant rules pointed at a live response, would catch it.
2. Body format change, field renamed, endpoint moved, auth changed, new required field. The renamed field produces no error at all.
3. Rapido does not version its API, so a version number would be a guess about a number they never assigned. Two changes could share one guessed number. A fingerprint is observed truth.
4. The fare might not parse as a number, or the service might not be one of the known service types. The server returns `BACKEND_DRIFT` and tells the model to stop rather than retry.
5. Rapido's response shape changed, so the invariants no longer hold. Our own code and our fixtures are unchanged. The tool must not retry, because the same shape will come back.

## Feynman prompt

Explain this module to a non-programmer in 150 words. No jargon you cannot unpack.

Three sentences that must appear in a correct explanation:

1. Rapido publishes no API, so the code must discover the contract and notice when it changes.
2. A recorded test proves your code still handles an old recording. Only a live call can tell you the server changed.
3. When a field is renamed the response still arrives valid. A check on what the data must mean is what catches it.

If your explanation is missing any of those, you have not finished Module 04.

## Flashcards

| Card | Answer |
|---|---|
| What does Rapido's API give you to code against? | Nothing published. No contract, no changelog, no versions. |
| What does a fixture test answer? | "Did I break something?" |
| What does a live probe answer? | "Did the world change?" |
| Which layer catches a renamed field? | The meaning-level invariant, the one that names the requirement. |
| What is the cheapest health check? | `POST /unup/autocomplete/location`, no auth and no side effects. |
| What does a fingerprint record? | Which keys are present and what the top-level shape is. |
| Why key decoders on fingerprints? | Rapido does not version, so a version number would be a guess. |
| What do all decoders return? | The same internal type, so the tool layer never knows which fired. |
| What does `BACKEND_DRIFT` mean? | A response arrived but broke an invariant. Stop, do not retry. |
| What does `npm run probe:live` run? | The same invariant checks as the fixture tests, against live calls, on a schedule. |

## Spaced repetition

| Day | What to review |
|---|---|
| 0 | Read the module, do the lab, answer the quiz closed-book, grade it. |
| 1 | Re-answer the five questions without notes. Mix in one question from Module 03. |
| 3 | Re-answer the quiz. Write the three required Feynman sentences from memory. |
| 7 | Full quiz again. Re-do Step 5 of the lab, the renamed key. |
| 14 | Explain the module to a non-programmer in 150 words. Aim for under three minutes of writing. |
| 30 | Quiz plus flashcards only. If you score under five, re-read the core content. |
| 60 | Quiz plus the misconception clinic. Re-read any entry you explained wrongly. |

This module interleaves with the other modules. Never review drift detection alone for a full session. Mix in tool-design and runtime questions so you practise discrimination, not just recall.

## See also

- [Building for an API that changes](../building-for-an-api-that-changes.md) — the reference note
- [Module 01 — MCP from the wire up](module-01-mcp-protocol.md)
- [Module 02 — Plain tools vs code mode](module-02-plain-tools-vs-code-mode.md)
- [Module 03 — Node vs Bun vs Python](module-03-node-vs-bun-vs-python.md)
- [Module 05 — Obsidian vault craft](module-05-obsidian-vault-craft.md)
- [The MCP course](../course.md)
- [The server we are building](../../project/rapido-mcp-server.md)
- [What is verified about Rapido's API](../../project/rapido-api-uncertainty.md)
- [CONTEXT.md](../../../CONTEXT.md) for the shared vocabulary
- [Decision log](../../../docs/reviews/decision-log.md) for D-010 and the rest
