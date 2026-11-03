# Ship retries, logging and caching as opt-in middleware

Status: proposed.

## Context and problem

Retries, logging and caching change what is sent, how often, or what is recorded. If any of them were on by default, the package would change site behaviour for every plugin that adopts it.

Auth and host rules also change what is sent, but they act on each request rather than around the transport, and host rules must hold on every redirect hop, which middleware never sees.

## Options considered

### Built-in features with defaults on

Plugins get protection without asking. Sites see extra requests, logs and cache entries they never configured.

### Everything as opt-in middleware

Each feature is attached explicitly per client. Auth would then also apply to PSR-7 requests an SDK sends, which own their auth, and host rules would be checked in middleware for the first URL and again in the transport for redirect hops.

### Opt-in middleware for what wraps the transport, request options for the rest

Retry, logging and caching are middleware, off by default. Auth is applied by the client to the requests it builds. Host rules and safe mode travel as call options and are enforced by the transport on the first URL and every hop.

## Decision

Ship retry, logging and caching as opt-in middleware operating on batches, with a single request treated as a batch of one. Apply auth in the client and host rules in the transport, as call options. Everything stays off unless a plugin attaches it, which is the only option consistent with deferring to WordPress, and each rule has one owner.

There is no retry unless a `RetryPolicy` is attached. By default the policy retries safe methods only, honours `Retry-After`, uses exponential backoff with jitter, and re-sends only the failed members of a batch.

There is no logging unless a PSR-3 logger is attached. When it is attached, redaction of `Authorization`, `Cookie`, `Set-Cookie` and configurable body patterns is on and can only be relaxed explicitly per client.

There is no caching unless the cache middleware is attached. It stores data in transients or the object cache, so the site's cache backend decides where data lives.

Host allow and deny lists are opt-in and add to `block_request()`; they never replace it.

## Consequences

Plugin authors attach what they need per client and can test each middleware in isolation. Caching can ship in a later minor release without API changes. The `Middleware` interface stays internal until then.

## Confirmation

Unit tests cover each middleware with the in-memory transport, including batch-aware retries and redaction defaults. A test checks that a client without middleware sends exactly one attempt per request. The transport contract tests check host rules on the first URL and on redirect hops.

## More information

- [Architecture](../design/architecture.md)
- [Developer pain points](../research/developer-pain-points.md)
