---
status: proposed
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Migrated from D7 in docs/decisions.md.
---

# Decode responses by content type

## Context and problem

WordPress returns the response body as a string and offers no decoding. The common bug is calling `json_decode` on an HTML error page, getting `null` and passing it on. `application/problem+json` bodies, which carry the useful error detail, are treated as opaque strings.

## Options considered

### Leave decoding to the caller

Every plugin keeps writing the same decode and check code, with the same bugs.

### Decode by the response Content-Type with typed exceptions

Registered decoders are selected by media type, and failures become exceptions carrying the response.

## Decision

Select a registered decoder by the response `Content-Type`, ignoring parameters such as `charset`. An unregistered type returns the raw string. A decoder failure throws `DecodingException` with the response attached.

HTTP 4xx and 5xx responses throw `ResponseException`. `application/problem+json` throws `ProblemException` with `type`, `title`, `status` and `detail` populated. Transport failures throw `TransportException`.

Every package exception implements `toWpError()`, so `WP_Error`-based plugin code stays idiomatic. This removes the most common bug class while letting plugins keep their existing error handling.

## Consequences

Callers choose at the edge whether they want exceptions or `WP_Error`. The `Accept` header can be derived from the registered decoders.

## Confirmation

Unit tests cover each decoder, unregistered types, malformed bodies, problem details and the `toWpError()` mapping.

## More information

- [Developer pain points](../research/developer-pain-points.md)
- [Trac #8620: WP_Error handling](https://core.trac.wordpress.org/ticket/8620)
