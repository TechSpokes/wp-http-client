---
status: proposed
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Migrated from D4 in docs/decisions.md, with the connect timeout limit and the exception from 0003.
---

# Inherit transport settings from WordPress

## Context and problem

WordPress decides timeout, redirect count, user agent, SSL verification and CA bundle, proxy and the external request blocklist through filtered defaults and constants evaluated inside the pipeline. The defaults are `http_request_timeout` 5 seconds, `http_request_redirection_count` 5, `http_headers_useragent`, `sslverify` true with the core CA bundle, `WP_HTTP_Proxy` and `WP_HTTP_BLOCK_EXTERNAL`.

The site also decides the temp directory for streamed downloads, transport selection, redirect validation, cookie normalization, response decompression, the location of `debug.log` and the cache backend behind transients. The package never sets any of these on its own.

`WP_Http` never passes `httpversion`, `compress` or `decompress` to Requests, so the `http_request_version` filter has no effect and Requests uses HTTP/1.1. The package inherits that behavior as it is.

A package that sets its own values would override the site's operator for every plugin that uses it.

## Options considered

### Set package defaults

The package could raise the timeout, set its own user agent or offer a switch to disable SSL verification. Every such default overrides a site decision for all consumers.

### Inherit everything and pass only explicit developer overrides

The package sets nothing on its own. When a developer sets a value on a client or an endpoint, it is passed as a normal request argument, exactly as a plugin would pass it today, so `http_request_args` can still change it.

## Decision

Inherit everything and pass only explicit developer overrides. This keeps the site in control and matches what plugin authors already know from `wp_remote_request()`.

The one exception is `reject_unsafe_urls`: an explicit `false` is not passed through, as decided in 0003.

There is no package convenience for disabling SSL verification. A developer who needs it passes `sslverify => false` and owns that choice. The package does not raise the default timeout; known-slow calls set a per-endpoint timeout.

`WP_Http::request()` builds Requests options from its own known keys and never passes `connect_timeout`, so Requests' 10-second default always applies to single requests. Per-client connect timeouts are therefore not offered for single requests in 1.0. Whether batches expose one is decided during design.

## Consequences

Nothing changes for a site that migrates a plugin to the package. Developers who want different behaviour for one API set it on that client or endpoint.

## Confirmation

Unit tests check that a client without overrides produces request arguments without timeout, redirection, httpversion, user-agent or sslverify keys. Parity tests check that site filters still apply.

## More information

- [0003 Let the site decide unsafe URL rejection](0003-let-the-site-decide-unsafe-url-rejection.md)
- [WordPress HTTP request pipeline](../research/wordpress-http-request-pipeline.md)
- [Requests batch-mode gaps](../research/requests-batch-mode-gaps.md)
