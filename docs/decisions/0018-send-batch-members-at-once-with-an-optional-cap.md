# Send batch members at once with an optional cap

Status: proposed.

## Context and problem

`Requests::request_multiple()` adds every member to one cURL multi handle, so a batch of fifty opens fifty connections at once. A remote service may answer that with 429 responses or drop connections, and a shared host may limit open sockets. WordPress has no setting for this, because it never sends more than one request at a time.

Visitors are not affected either way: a capped batch takes longer, an uncapped one puts more load on the remote end.

## Options considered

### No cap

Behaves exactly like the underlying library. A plugin that batches a hundred calls hits the remote service with a hundred connections.

### A fixed default cap

Protects remote services without configuration, but picks a number for every plugin and every service, and makes a batch of a hundred take several rounds by default.

### No cap by default, with an optional cap per client or per batch

Behaves like the library unless the plugin asks otherwise. A plugin that knows its service's limits sets the cap; the transport sends the members in rounds of that size, keeping keys and submission order.

## Decision

Send all members at once by default and offer an optional cap, set per client and overridable per batch. This follows the rule that the package adds nothing the platform does not do unless a plugin asks, and it gives the plugin the one control it needs for a strict service.

A capped batch is sent in rounds. Retry middleware re-sends only failed members and respects the same cap.

## Consequences

A batch of fifty with a cap of ten takes five rounds; the documentation says so. Rate limiting per host, planned for 1.x, builds on the same rounds.

## Confirmation

Unit tests with the in-memory transport check that a cap of `n` never has more than `n` members in flight and that keys and order are preserved across rounds.

## More information

- [0005 Key batch results by submission order](0005-key-batch-results-by-submission-order.md)
- [Architecture](../design/architecture.md)
