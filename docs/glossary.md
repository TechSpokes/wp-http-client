---
status: review
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: First set of project terms.
---

# Glossary

Use these terms in code, issues and documents, and avoid the listed synonyms. Add a term here when a discussion settles its meaning.

## Batch

A set of requests submitted together and sent in parallel, each under a key chosen by the caller. A single request is treated as a batch of one. Avoid: multi-request, async request.

## Member

One request inside a batch, identified by its key. Each member has its own arguments, hooks and result.

## Result

The outcome for one member: a response, or the exception that explains why there is none. A result set holds the results of a batch under the submitted keys.

## Endpoint

A value object describing one API call: method, path template, query, body, expected class and per-call options.

## Site setting

Any decision the WordPress installation already makes about HTTP: a default, a filter, a constant or a bundled library choice. The package inherits site settings and does not re-decide them.

## Pre-flight

The work `WP_Http::request()` does before sending: filtered defaults, `http_request_args`, `pre_http_request`, URL validation, blocklist, stream setup, SSL and proxy options.

## Short-circuit

A non-false value returned by the `pre_http_request` filter, used as the response instead of sending the request.

## Parity

Identical observable behavior between a batch member and the same request sent alone with `wp_remote_request()`: the same hooks, arguments and result.

## Transport

The component that hands requests to WordPress and returns results. The WordPress transport is the only code that references WordPress.

## Middleware

A layer wrapped around the transport that acts on a whole batch, such as retry, logging, auth or host policy. Middleware is opt-in.

## Hydration

Mapping a decoded response body onto an object of the class the endpoint expects.

## Safe mode

Forcing `reject_unsafe_urls` on for a client or an endpoint, as `wp_safe_remote_request()` does. Avoid: secure mode.
