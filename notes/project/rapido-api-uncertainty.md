---
title: What is verified about Rapido's API
type: project
status: open
tags:
  - rapido
  - api
updated: 2026-11-20
---

# What is verified about Rapido's API

This note is the trust boundary of the whole project. One table, two columns: what we confirmed ourselves, and what we inherited from someone else.

## Verified — we called it live and got HTTP 200

| Endpoint | Request | Response |
|---|---|---|
| `POST /unup/autocomplete/location` | `{"searchWord":"Koramangala"}` | `data[]` of `{placeId, description, name}` |
| `POST /unup/location/geocode/placeId` | `{"placeId":"ChIJ…"}` | `data` of `{lat, lng, address}` |
| `POST /unup/event` | telemetry body | `{"info":{"status":"success"}}` |

Base URL: `https://m.rapido.bike/pwa/api`.

These three are the only operations we have confirmed by ourselves. Everything else in this project is inference.

## Verified — these return 401 with an empty body

`/pricing/getFareEstimate`, `/location/riderEta`, `/wallet/balance`, `/location/services`, `/unup/scc/fareEstimate`, `/user/customer/status`, `GET /appconfig`, `GET /captain/rating/{captainId}`.

One correction worth keeping: a third-party skill claims `GET /appconfig` is unauthenticated. Our live probe returned 401. The live probe wins.

## Deliberately never called

| Endpoint | Why not |
|---|---|
| `POST /auth/generateOtp` | Sends a real SMS to a real phone. |
| `POST /auth/verifyOtp` | Consumes a real OTP. |
| `POST /order/book` | Books and pays for a real ride. |
| `POST /order/cancel` | Cancels a real ride. |

These stay uncalled until there is a deliberate instruction to call them.

## Third-party claims — plausible, unconfirmed

Source: the `ankitjh4/indic-ai-skills` Rapido skill, mirrored on skillsdirectory.com. Its own status note (March 2026) says fare estimates and booking return encoded binary after a protobuf schema change, and that a new HAR capture is needed.

Auth flow per that source:

- `POST /auth/generateOtp` with `{mobile, hash, recaptchaToken}`, where `hash = "<timestamp>:<sha256(timestamp:mobile:secret)>"` and the secret is the literal placeholder `"rapido_secret_key"`, commented *"may need reverse engineering"*.
- `POST /auth/verifyOtp` with `{mobileNumber, otp}` returns `data.token` (a JWT) and `data.userId`.
- Authenticated calls send `Authorization: Bearer <token>` **and** `x-consumer-username: "<userId>:"` — note the trailing colon — plus `Content-Type: application/json` and browser-like `User-Agent`, `Origin: https://m.rapido.bike` and `Referer`.

We probed with only `x-consumer-username` and still got 401. So the exact header set is unverified.

Ride lifecycle field names, third-party only:

| Operation | Body | Response |
|---|---|---|
| Estimate | `{pickupLocation, dropLocation}` each `{lat, lng, displayName, address}` | `data.quotes[]` of `{serviceId, serviceName, fare, distance, duration}`, plus `data.requestId`, `data.timeInMts` |
| `order/book` | `{pickupLocation, dropLocation, serviceDetailId, paymentMethod, userId}` | `data.orderId`, `data.status`, `data.nudgeConfig` |
| `location/riderEta` | `{locations:[{lat,lng}], orderId, serviceDetailId, userId, riderId}` | `data.etaInMinutes`, `data.polyline`, `data.captain{status, location}` |
| `order/cancel` | `{userId, cancelReason, otherReason, orderId, locationDetails}` | — |

`paymentMethod` values: `cod`, `rapido_wallet`, `upi`, `card`.

## Still unknown

The exact auth header set. The `generateOtp` hash secret, and whether recaptcha is enforced server-side. Whether fare and booking still return protobuf. The OTA host URLs. The `serviceDetailId` catalogue. The `paymentMethod` enum. The `cancelReason` values. The order-status values. Where `riderId` comes from. Consumer rate limits. Whether Rapido would accept an OSS MCP server as a corporate integrator.

## The documented surface is not the ride API

`rapido-labs/ota-docs` is Rapido's only docs repo. It documents exactly two endpoints: `POST <host>/api/ota/fetch-user-details` and `POST <host>/api/ota/event`. Those are SSO token validation and event ingestion. Not booking. The base URLs in that repo are placeholders.

## Terms of service

From `rapido.bike/CustomerTerms`:

- §VIII.8.4 forbids reverse engineering, or accessing the platform to launch an automated program or script — web crawlers, bots, "any program which may make multiple server requests per second".
- §IV.4.7–4.9 no impairing the platform, no unreasonable load.
- §IV.4.10 and §VIII.8.1–8.3 no copying, commercially exploiting, mirroring or linking.
- §VIII.5 the licence is one copy of the app on a single device for personal use.
- §III.2 and §IV.4.2 the account is non-transferable.

A plain reading is that automating the consumer API conflicts on its face. The terms are silent on agent-mediated access to a user's own account, and silent on MCP specifically. Nothing found authorises consumer-API automation. Nothing found forbids it outright either.

Sanctioned routes — Rapido Corporate, the OTA partner program, delivery partners — are all relationship-gated.

## What this means for the build

Every field name above marked third-party is a guess. The server must therefore not trust the shape of a response it has never seen. That is the argument for the five layers in [Building for an API that changes](../learning/building-for-an-api-that-changes.md): a decoder registry keyed on response fingerprints, meaning-level assertions, typed errors, and a live probe.

It is also the argument for keeping the live client out of the public repo until the user has decided what to publish.
