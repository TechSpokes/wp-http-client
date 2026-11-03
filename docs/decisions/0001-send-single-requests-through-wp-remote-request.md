---
status: proposed
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Migrated from D1 in docs/decisions.md.
---

# Send single requests through wp_remote_request()

## Context and problem

`WP_Http::request()` runs about 200 lines of pre-flight before a request leaves PHP: filtered defaults, `http_request_args`, `pre_http_request`, URL validation, `block_request()`, stream setup, header normalisation, redirect hooks, byte limit, cookies, SSL verification with `https_ssl_verify`, proxy, the `mbstring` guard, response wrapping, `http_api_debug` and `http_response`.

All of it is public, but it changes between WordPress releases. The package needs every single request to behave exactly as WordPress would send it.

## Options considered

### Use the package's own replica for every request

Single and batched requests share one code path, so behaviour is uniform. The replica must stay correct for every request the package sends, and any drift from core affects all traffic.

### Send single requests through wp_remote_request() and use a replica only for batches

Single requests get exact parity by construction. The replica only has to be right for the case WordPress cannot handle itself, which limits drift to batches.

## Decision

Send single requests through `wp_remote_request()` unchanged. Single requests, including a batch with one member, go through `wp_remote_request()`; the replica of the pre-flight is used only for batches of two or more (see 0002), because exact parity for single requests then costs nothing and needs no maintenance.

## Consequences

Single requests carry no blast radius: they behave exactly as plugins calling `wp_remote_request()` today. Documented differences from WordPress are confined to batches.

## Confirmation

Parity tests force the replica path for one request and compare its output with `wp_remote_request()` on every CI run, so drift is caught before release.

## More information

- [0002 Run batches through the WordPress request pipeline](0002-run-batches-through-the-wordpress-request-pipeline.md)
- [WordPress HTTP request pipeline](../research/wordpress-http-request-pipeline.md)
