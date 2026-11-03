---
status: proposed
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Migrated from D9 in docs/decisions.md.
---

# Ship retries, logging, caching and host rules as opt-in middleware

## Context and problem

Retries, logging, caching and host allow or deny lists change what is sent, how often, or what is recorded. If any of them were on by default, the package would change site behaviour for every plugin that adopts it.

## Options considered

### Built-in features with defaults on

Plugins get protection without asking. Sites see extra requests, logs and cache entries they never configured.

### Opt-in middleware, all off by default

Each feature is attached explicitly per client. Plugins that attach nothing behave exactly like `wp_remote_request()`.

## Decision

Ship each feature as opt-in middleware operating on batches, with a single request treated as a batch of one. This is the only option consistent with deferring to WordPress.

There is no retry unless a `RetryPolicy` is attached. By default the policy retries safe methods only, honours `Retry-After`, uses exponential backoff with jitter, and re-sends only the failed members of a batch.

There is no logging unless a PSR-3 logger is attached. When it is attached, redaction of `Authorization`, `Cookie`, `Set-Cookie` and configurable body patterns is on and can only be relaxed explicitly per client.

There is no caching unless the cache middleware is attached. It stores data in transients or the object cache, so the site's cache backend decides where data lives.

Host allow and deny lists are opt-in and add to `block_request()`; they never replace it.

## Consequences

Plugin authors attach what they need per client and can test each middleware in isolation. Caching can ship in a later minor release without API changes.

## Confirmation

Unit tests cover each middleware with the in-memory transport, including batch-aware retries and redaction defaults. A test checks that a client without middleware sends exactly one attempt per request.

## More information

- [Developer pain points](../research/developer-pain-points.md)
