# Run batches through the WordPress request pipeline

Status: proposed.

## Context and problem

WordPress has no API for parallel requests. `Requests::request_multiple()` sends several requests at once and accepts a per-request `options` array merged over the global options, so each member can carry its own timeout, `filename`, `max_bytes`, `verify`, proxy, cookies and `hooks`.

It dispatches `multiple.request.complete` as each member finishes and `request.progress` as bytes arrive. The cURL transport also dispatches `curl.before_multi_add`, `curl.before_multi_exec` and `curl.after_multi_exec`.

Calling it directly bypasses every WordPress filter, so proxies, blocklists and debugging tools stop seeing the traffic.

## Options considered

### Call Requests::request_multiple() directly

This is the simplest option. Site filters, constants and debugging tools do not apply to batched traffic, which contradicts the guiding principle.

### Send batch members one by one through wp_remote_request()

Parity is exact, but the batch takes the sum of all request times instead of the slowest one, which removes the reason for batching.

### Replicate the WP_Http::request() pre-flight per member, then call request_multiple()

Each member gets the same treatment as a single request, and the transfer still runs in parallel. The replica must track core changes.

## Decision

For each member, compute exactly what `WP_Http::request()` computes: the five filtered defaults (`http_request_timeout`, `http_request_redirection_count`, `http_request_version`, `http_headers_useragent`, `http_request_reject_unsafe_urls`), then `http_request_args`, then `pre_http_request`.

A member whose `pre_http_request` returns a non-false value is removed from the batch, and the filter result is used as its response.

For the remaining members, URL validation, `block_request()`, stream, header, redirect-hook, byte-limit, cookie, SSL, `https_ssl_verify` and proxy settings are computed exactly as WordPress computes them, then applied explicitly wherever Requests' batch mode would drop them. Each member has its own `WP_HTTP_Requests_Hooks` instance so that the `requests-*` actions fire with the right `$url` and `$parsed_args`.

After `request_multiple()` returns, wrap each member in `WP_HTTP_Requests_Response`, fire `http_api_debug` and apply `http_response`. An exception for one member becomes a transport failure for that member, never a failed batch.

This option is the only one that keeps both parallelism and site control over every request.

## Consequences

Hooks fire per phase rather than per request: all `http_request_args` calls first, then the transfer, then all `http_response` calls. The replica forces `blocking` to true: in multi mode a `blocking => false` member still waits in the loop but gets no response body or headers.

Requests' multi mode also differs from a single request in the ways below, which the replica must handle explicitly. How each one is handled is decided during design.

- `verify` and `verifyname` are applied only on the single-request path, so the WordPress CA bundle, `sslverify` and `https_ssl_verify` do not reach batch members.
- `curl.before_send` is not dispatched, so `http_api_curl` does not fire for batch members.
- Redirects are followed with a blocking `Requests::request()` inside the multi loop, which stalls the other members.
- `curl.before_send` and `requests.before_request` are not dispatched, so the proxy, basic auth and cookies that Requests attaches through those hooks never reach a member's first leg.

This is the one place the package re-implements WordPress logic. The replica lives in a single class.

## Confirmation

Parity tests force the replica path for one request and compare it with `wp_remote_request()`, including the hooks fired and the `http_api_debug` arguments. The CI matrix includes the oldest and newest supported WordPress, so core changes to `WP_Http::request()` surface as test failures.

## More information

- [0001 Send single requests through wp_remote_request()](0001-send-single-requests-through-wp-remote-request.md)
- [0005 Key batch results by submission order](0005-key-batch-results-by-submission-order.md)
- [Requests batch-mode gaps](../research/requests-batch-mode-gaps.md)
- [WordPress HTTP request pipeline](../research/wordpress-http-request-pipeline.md)
- [Trac #37459: WP_Http layer for parallel requests](https://core.trac.wordpress.org/ticket/37459)
