# Context

Shared vocabulary for the `rapido-mcp` project. Use these words exactly. Do not invent synonyms.

## The product

An MCP server that lets an AI agent search locations, estimate fares, book a ride, track it and cancel it, on Rapido.

## Ride domain

| Term | Meaning |
|---|---|
| **Ride** | One booked journey from a pickup point to a drop point. The unit of work this server sells. |
| **Service** | A class of vehicle: bike taxi, auto, or cab. Rapido calls these "services"; the vehicle arriving is the *Captain*. |
| **Quote** | One priced option for a ride: a service, a fare, an estimated distance and duration, and a request id. A quote is not a booking. It expires. |
| **Order** | A booked ride. Created by booking a quote. Has an order id and a status. |
| **Captain** | The driver who fulfils an order. Not a Rapido employee; the term is Rapido's own. |
| **Pickup** | The origin of a ride, given as a resolved place plus coordinates. |
| **Drop** | The destination of a ride, same shape as a pickup. |
| **Place id** | Rapido's opaque identifier for a named location, as returned by a location search. Not a coordinate, not an address. |
| **ETA** | Estimated time until the Captain reaches the pickup point, in minutes. |

## Access domain

| Term | Meaning |
|---|---|
| **Consumer web API** | Rapido's undocumented internal API at `https://m.rapido.bike/pwa/api`, used by its own web app. Not a published developer API. |
| **Corporate API** | Rapido's business-facing booking API, sold to companies. Relationship-gated, no public signup, no public spec. |
| **OTA endpoint** | The `api/ota/*` family Rapido documents for travel-agency partners: SSO token validation and event ingestion. Documented, but not ride booking. |
| **Verified endpoint** | An endpoint whose request and response shape was confirmed by a live call against Rapido during development. |
| **Third-party claim** | A request or response shape taken from prior art — a third-party skill, a capture, a forum post — not confirmed by our own call. |
| **Drift** | A change in Rapido's backend that breaks a decoder written against an earlier shape. |
| **Fixture** | A recorded response body stored for regression tests. Proves we still parse what we parsed. Says nothing about what Rapido serves today. |
| **Probe** | A live call against Rapido that checks the backend still behaves as assumed. The only thing that detects drift. |

## Server domain

| Term | Meaning |
|---|---|
| **Tool** | An MCP operation the model can invoke. Named, described, with a JSON Schema for its input. |
| **Backend** | Rapido's API, as this server sees it. Swappable behind an interface so the server can be tested without it. |
| **Decoder** | The code that turns a Rapido response body into the server's own types. Keyed on a response fingerprint, not a version number. |
| **Typed error** | A failure with a stable machine-readable code and a next action, not a stack trace. |
| **Session** | The server's authenticated state for one Rapido account. |
| **Live client** | The implementation of the backend interface that talks to Rapido over the network. |

## Words to avoid

| Do not say | Say |
|---|---|
| driver | Captain |
| vehicle type | Service |
| fare estimate, price quote | Quote |
| trip, journey | Ride |
| ride booking API | Consumer web API, or Corporate API |
| endpoint documentation | OTA endpoint (the only documented surface) |
