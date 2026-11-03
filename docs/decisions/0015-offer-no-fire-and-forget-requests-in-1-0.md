---
status: proposed
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Migrated from O1 in docs/decisions.md.
---

# Offer no fire-and-forget requests in 1.0

## Context and problem

Plugins use `blocking => false` as fire-and-forget for webhooks and pings. WordPress accepts it, but it is neither reliably non-blocking nor fast: the cURL transport has a one-second timeout floor (Trac #63547), and core moved cron spawning to `fastcgi_finish_request()` for that reason (Trac #18738). In Requests' multi mode a non-blocking member still waits in the loop and only loses its response.

## Options considered

### Expose fireAndForget() mapping to blocking => false

Familiar to plugin authors, but it would be the first package feature whose documented behaviour is "this probably does not do what you think".

### Do not expose it, and point to Action Scheduler or WP-Cron

Slightly less convenient, but never misleading. A short example shows how to queue background work.

### Send queued requests on the shutdown action

Better developer experience, but it adds behaviour WordPress does not have and depends on the server setup.

## Decision

Do not expose fire-and-forget requests in 1.0, and document Action Scheduler or WP-Cron for background work. It is the only option consistent with deferring to WordPress, which itself stopped relying on non-blocking HTTP for cron.

## Consequences

A "send on shutdown" middleware can come in a 1.x release if a real consumer asks for it.

## Confirmation

Review checks that the public API exposes no `blocking => false` convenience.

## More information

- [Trac #63547: wp_remote_post not respecting timeout and blocking](https://core.trac.wordpress.org/ticket/63547)
- [Trac #18738: cron spawning and non-blocking requests](https://core.trac.wordpress.org/ticket/18738)
