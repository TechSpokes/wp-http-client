# Existing solutions

What already exists for outbound HTTP in WordPress, and why none of it covers the problem. Lessons from earlier TechSpokes attempts are recorded without their code, which is private.

## The WordPress HTTP API

`WP_Http` and the `wp_remote_*()` functions wrap the bundled Requests library and fire the filters that proxies, blocklists, caches and debugging tools hook into. The full pipeline is described in [wordpress-http-request-pipeline.md](wordpress-http-request-pipeline.md). It sends one blocking request at a time and offers no retries, decoding or mapping.

## Requests

`Requests::request_multiple()` sends requests in parallel and plugin code can call it, but it bypasses the WordPress filters unless the caller rebuilds the pipeline. Its batch mode also differs from single mode, as described in [requests-batch-mode-gaps.md](requests-batch-mode-gaps.md).

WordPress 7.0 updated the bundled copy to 2.0.17, mostly for PHP 8.5 compatibility (Trac #64752). Upstream releases since then are certificate bundle updates; there is no PSR-7 or PSR-18 work.

## The WordPress parallel request ticket

A WordPress-level layer for parallel requests was split from Trac #33055 into #37459 in 2016 and remains open with milestone Future Release.

## Core's private PSR-18 adapter

Since 7.0, `WP_AI_Client_HTTP_Client` adapts a PSR-7 request to `wp_safe_remote_request()` and builds a PSR-7 response. It is marked not for plugin or theme use, always blocks, buffers the whole body, supports only timeout and redirects, and depends on prefixed PSR interfaces under `WordPress\AiClientDependencies\` that plugins cannot rely on.

It confirms the shape of this package, PSR-18 on top of the WordPress HTTP layer, and leaves the public niche open.

## Other packages

`alleyinteractive/wp-concurrent-remote-requests` is a feature plugin adding concurrent requests, with no logging or debugging story. `wp-oop/http-client` and `RebelCode/wp-http-client` wrap the HTTP API without batching, retries or mapping.

Bundling Guzzle is the common workaround for SDKs that need PSR-18; it bypasses the site's HTTP settings and is a frequent source of namespace collisions.

## Lessons from earlier TechSpokes clients

### A wrapper around wp_remote_request() (2020 to 2024)

Its best idea was a debugger attached to `http_api_debug` only for the duration of its own call, so it never logged other plugins' traffic, with log levels and redaction of card data and `Authorization` values by default.

Its weaknesses: it relied on Requests 1.x class names deprecated in WordPress 6.2, had no `composer.json`, returned `array|WP_Error` everywhere, wrote straight to `debug.log`, and read the raw response in a way that broke when `pre_http_request` short-circuited.

### A batch client on Requests (2025)

It called `Requests::request_multiple()` directly, re-applied SSL options on `curl.before_multi_add`, and hand-mapped decoded bodies into model objects. It bypassed the WordPress filters, so proxies, blocklists and debugging tools never saw its traffic. Copies vendored into other plugins drifted apart, which is why the solution must be a package.

### A standalone cURL client (2023)

It had its own `curl_multi` transport and a retry strategy with exponential backoff. The lesson is to keep the retry idea and drop the transport: a custom transport loses every WordPress filter, proxy and SSL setting. Its retry retried on cURL errors only; the new policy also needs HTTP statuses, `Retry-After`, jitter and safe-method rules.

## Sources

- [Requests::request_multiple reference](https://developer.wordpress.org/reference/classes/wporg-requests-requests/request_multiple/)
- [Trac #64752: update Requests to 2.0.17](https://core.trac.wordpress.org/ticket/64752)
- [WordPress/Requests releases](https://github.com/WordPress/Requests/releases)
- [Trac #37459: WP_Http layer for parallel requests](https://core.trac.wordpress.org/ticket/37459)
- [WP_AI_Client_HTTP_Client reference](https://developer.wordpress.org/reference/classes/wp_ai_client_http_client/)
- [Proposal for merging WP AI Client into WordPress 7.0](https://make.wordpress.org/core/2026/02/03/proposal-for-merging-wp-ai-client-into-wordpress-7-0/)
- [alleyinteractive/wp-concurrent-remote-requests](https://github.com/alleyinteractive/wp-concurrent-remote-requests)
- [wp-oop/http-client on Packagist](https://root.packagist.org/packages/wp-oop/http-client)
- [RebelCode/wp-http-client](https://github.com/RebelCode/wp-http-client)
