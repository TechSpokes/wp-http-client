# Cap the time retries may add to a call

Status: proposed.

## Context and problem

A retry policy waits between attempts and honours `Retry-After`. A service may answer `Retry-After: 120`. Without a limit, a page waits two minutes for one call, and the PHP worker is held the whole time. WordPress has no setting for this, because it never retries.

The default WordPress timeout is five seconds per request, so a call that is retried twice already costs up to fifteen seconds of transfer time before any waiting is added.

## Options considered

### Cap attempts only

Simple, but `Retry-After` makes one attempt cost any amount of waiting.

### Cap attempts and the total waiting time

The policy stops retrying when the next wait would pass the budget. A long `Retry-After` is then a failure with the response attached, not a wait.

### Cap wall-clock time including transfers

Most precise, but the package cannot interrupt a transfer WordPress is making, so the cap cannot be enforced and would mislead.

## Decision

Cap attempts and total waiting time. `RetryPolicy` carries a maximum number of attempts, three by default, and a maximum total wait, five seconds by default, the same as the WordPress default timeout. A `Retry-After` or backoff wait that would exceed the remaining budget ends the retries, and the caller gets the last response or failure.

Both limits are set per client and overridable per call, as the retry policy already is.

## Consequences

Retries can at most double what a plugin would wait without them, under default settings. A plugin running in cron or WP-CLI, where waiting is cheap, raises the budget explicitly.

## Confirmation

Unit tests with the in-memory transport check that a `Retry-After` beyond the budget produces no further attempt, that backoff stops at the budget, and that per-call overrides apply.

## More information

- [0009 Ship retries, logging and caching as opt-in middleware](0009-ship-retries-logging-and-caching-as-opt-in-middleware.md)
- [Developer pain points](../research/developer-pain-points.md)
