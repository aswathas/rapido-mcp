---
title: Building for an API that changes without notice
type: learning
tags:
  - api-robustness
  - rapido
  - mcp
updated: 2026-11-20
---

# Building for an API that changes without notice

Rapido ships no public API. We code against a backend with no contract, no changelog and no promise to tell us when it moves. The contract is **implicit**: it is whatever the server happens to return today.

So the design has two jobs: **notice** that the contract moved, and **survive** that it moved. Fixtures handle the second. Only a live probe handles the first.

The evidence: the one public Rapido skill on GitHub carries this note from March 2026.

> "Fare estimates and booking return encoded binary due to a protobuf schema change — a new HAR capture is needed."

Booking — the part that spends money — broke for third-party clients, silently, on an ordinary working day.

## Fixtures are for regression; probes are for detection

Reaching for a test fixture and assuming you are done is the one mistake that makes all of this moot. A fixture is a recording of what Rapido returned on one day, and the test runs your code against that recording. Rapido changes the API, your recording is unchanged, and your test still passes. The test never talks to Rapido, so it cannot detect Rapido changing. A fixture test answers *"did I break something?"*; it cannot answer *"did the world change?"*.

> **Fixtures are for regression. Probes are for detection.** A fixture suite is green forever by construction. Only something that actually contacts the live API can tell you the API moved.

Fixtures are how we develop offline and prove a change did not break the old behaviour. Probes are how we find out about *their* changes.

## The five kinds of break

| Break | How it appears | How you notice |
|---|---|---|
| **Body format changes** — JSON becomes protobuf binary | Parse error, or nonsense bytes | The parser itself fails |
| **Field renamed** — `data.quotes` → `data.fareOptions` | **Nothing.** It parses fine and hands back empty data | Only an assertion can catch this |
| **Endpoint moved** | 404, or 200 with an error body | A health probe on a known-good endpoint |
| **Auth changed** — new header, new token format | 401 on every call, including ones that used to work | Auth check, kept distinct from drift |
| **New required field** | 400, or the field is silently ignored | Response-side invariant catches the silent case |

Row two is the dangerous one. A renamed field is *invisible* to every ordinary check: the request succeeds, the response parses, the status is 200, and the tool returns "no rides available" when there are twelve. For an agent that is worse than a crash — a silent empty result reads as a fact about the world.

## Layer 1 — The health probe

Before anything else, ask a cheap question: *is the API still there?*

Rapido's cheapest check is `POST /unup/autocomplete/location` — no auth, no side effects, and live-verified returning HTTP 200 with a real body. If that call fails, the API has moved wholesale and every other call will fail too. Fail fast with `BACKEND_UNREACHABLE` rather than letting each tool produce its own confusing error. One clear error beats five different ones.

## Layer 2 — The decoder registry

The layer that turns "the API changed" from a catastrophe into a small addition. Record responses and give each one a **fingerprint** — which keys are present, what the top-level shape is. Decoders are registered against fingerprints, not version numbers.

```text
{ data: { quotes: [...] } }      → json.v1     → FareEstimateResponse
{ data: { fareOptions: [...] } } → json.v2     → FareEstimateResponse
<binary>                         → protobuf.v1 → FareEstimateResponse
```

All three decoders return the *same* internal type, so the tool layer never knows which one fired. The March 2026 break stops being a rewrite: one new decoder entry — `protobuf.v1` — plus a fingerprint matcher that recognises the binary body, while `json.v1` keeps working for anyone still on the old format.

**Why fingerprint rather than version?** Because Rapido does not version. Keying decoders on "v1, v2, v3" would be guessing which number they are on, and two different changes could produce the same number. A fingerprint is observed truth.

## Layer 3 — Invariants asserted on meaning

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

Because the invariant names the requirement, a rename produces a message a human can act on — *"a quote must have a fare"*, not *"expected property 'fare' at data.quotes[0]"*.

## Layer 4 — Typed errors, with hints

The model is the consumer of our error messages. A stack trace is not an error message for a model; it is noise it may hallucinate meaning from. A bare "500 Internal Server Error" is worse — it says nothing about whether to retry, and a blind retry loop is how we burn money.

| Code | Means | What the model should do |
|---|---|---|
| `BACKEND_UNREACHABLE` | Even the health probe failed | Stop. Tell the user Rapido's API is not responding. |
| `BACKEND_DRIFT` | A response arrived but broke an invariant | Stop. Tell the user the API shape changed. Do not retry. |
| `AUTH_EXPIRED` | 401, or a missing session | Tell the user to run `rapido-mcp login`. Retry after they do. |
| `QUOTE_EXPIRED` | The quote id is older than its validity window | Re-plan, then present new quotes to the user. |
| `NO_SERVICE_AVAILABLE` | No service type runs at that pickup point | Tell the user, and suggest a different pickup. |
| `RIDE_NOT_CANCELLABLE` | The order cannot be cancelled in its current state | Tell the user why. Do not retry. |

Note the split: three of those say *stop*, and three say *here is the next action*. A model that knows which is which behaves sanely. A model that only sees failures will retry everything.

## Layer 5 — The live probe

The only component that can answer "did Rapido change?"

`npm run probe:live` makes real calls with real credentials and runs the same invariant checks the offline tests use. When it fails, Rapido moved, and we know before a user does.

```text
CI     fixtures only, offline, every commit
probe  live calls, same invariants, on a schedule

Same assertions. Two triggers. One implementation of the rules.
```

The invariant rules are written **once** and used in both places: a fixture test and the live probe run the same assertion code against different sources, so the probe is the same rules pointed at a different input, not a script that drifts out of sync. Run it on a schedule, not on demand: the value of a probe is noticing the change on Tuesday, not on the Saturday when someone tries to book a ride.

## Two design consequences that fall out of this

**Quotes expire, and the server has to know.** We chose two-step booking: `plan_ride` returns quotes, `book_ride` takes a quote id. Between those two calls a human may be choosing between a bike and an auto. The quote has a validity window, and Rapido's side will reject a stale one. So the server stores quotes with a timestamp and refuses a stale one with `QUOTE_EXPIRED` and a clear hint: re-plan. Sending a stale id wastes a round trip and returns an error nobody can interpret.

**Service availability is discovered, never assumed.** Bike taxi, auto and cab do not run in the same places. "Rapido has autos" is true of Bengaluru and false of Chennai, and it changes over time. So availability is a discovery step, not a constant: `plan_ride` returns only the services actually available for that pickup point, each with its own fare. The agent is structurally prevented from offering an auto where there are none, because it never sees one — a better guarantee than a hardcoded list that quietly goes stale.

## What this does and does not buy us

This design does **not** make Rapido's API stable. It makes *us* able to absorb a change in an afternoon instead of a week, with a failing test naming the broken requirement instead of a stack trace. When a shape genuinely cannot be decoded, the server says so plainly and stops — much better than guessing.

It also does not remove the ToS question. A robust client for a forbidden API is still a client for a forbidden API. The engineering and the legal question are separate, and the legal one is decided by D-010: build and test locally first, keep the live client out of the public repo until we have chosen what to publish.

## See also

- [MCP from the wire up](mcp-protocol.md)
- [Plain tools vs code mode](plain-tools-vs-code-mode.md)
- [Node vs Bun vs Python for an MCP server](runtime-node-vs-bun-vs-python.md)
- [Home](../Home.md)
- [CONTEXT.md](../../CONTEXT.md) for the shared vocabulary.
