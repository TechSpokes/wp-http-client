# Key batch results by submission order

Status: proposed.

## Context and problem

Requests returns batch responses keyed by the submitted ids and offers `multiple.request.complete` for processing in completion order. WordPress has no opinion. Callers need to match each result to its request, and some need to act on results as they arrive.

## Options considered

### Return results in completion order

Callers see the fastest results first but must match keys themselves.

### Return results keyed and ordered by submission, with a completion callback

Callers get results under the keys they submitted, and an optional callback reports each result as it finishes.

### Offer both orderings as modes

Two iteration modes add API surface without covering any case the callback does not.

## Decision

Return a result set keyed exactly as submitted, keeping string and integer keys, and iterable in submission order. An optional `onComplete(callable $fn)` receives `(key, Result)` as each member finishes. This matches the underlying library and covers progress reporting and streaming consumers without a second ordering mode.

## Consequences

Partial failure is normal: each key holds either a success or a failure. Progress UIs and streaming consumers hook into `onComplete`.

## Confirmation

Unit tests with the in-memory transport check key preservation, submission order and callback order.

## More information

- [0002 Run batches through the WordPress request pipeline](0002-run-batches-through-the-wordpress-request-pipeline.md)
