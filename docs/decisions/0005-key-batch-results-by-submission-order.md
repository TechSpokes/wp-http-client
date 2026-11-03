# Key batch results by submission order

Status: proposed.

## Context and problem

Requests returns batch responses keyed by the submitted ids and offers `multiple.request.complete` for processing in completion order. WordPress has no opinion. Callers need to match each result to its request, and some need to act on results as they arrive.

## Options considered

### Return results in completion order

Callers see the fastest results first but must match keys themselves.

### Return results keyed and ordered by submission

Callers get results under the keys they submitted, once the whole batch is done.

### Offer both orderings as modes, or a completion callback

More API surface for a case no actor has asked for: a batch is bounded by its slowest member, so acting on results as they arrive saves little inside one PHP request.

## Decision

Return a result set keyed exactly as submitted, keeping string and integer keys, and iterable in submission order. No completion callback ships in 1.0; one can be added in 1.x without breaking anything if a real consumer needs it.

## Consequences

Partial failure is normal: each key holds either a success or a failure.

## Confirmation

Unit tests with the in-memory transport check key preservation and submission order.

## More information

- [0002 Run batches through the WordPress request pipeline](0002-run-batches-through-the-wordpress-request-pipeline.md)
