# Developer pain points

What developers struggle with when making HTTP calls from WordPress plugins and themes, the evidence, and what each problem implies for the package. Sources are listed at the end.

## Timeouts and certificate errors

Support forums and hosts are full of cURL error 28 (timeout) and 60 (certificate). The default 5-second timeout is short for slow vendor APIs, plugins that hard-code `timeout` bypass the global filter, and plugins bundling their own cURL code ignore the WordPress CA bundle. Hosts advise against disabling SSL verification or raising the global timeout. [StackHarbor]

Requests' cURL transport rounds every timeout up to one second, so `blocking => false` with a tiny timeout still costs time (Trac #63547). Core solved its own cron case with `fastcgi_finish_request()` instead of non-blocking HTTP (Trac #18738).

The package must allow a timeout per client or endpoint without touching the site filter, must not offer an "SSL off" shortcut, must not pretend `blocking => false` is fire-and-forget, and must report where a request failed (DNS, connect, TLS, read, blocked by the site) in a structured way.

## Serial requests add up

Every `wp_remote_get()` blocks, so a dashboard calling four APIs waits for the sum. The 2015 ticket asking for parallel support called it vital; the answer was to use Requests directly, which bypasses the WordPress hooks. The only packaged alternative is a small feature plugin without logging. [Trac #33055, #37459, alleyinteractive]

Batching is the core differentiator. Each member must pass through the same filters as a single request, results must come back under the submitted keys, and partial failure must be normal.

## Rate limits and transient errors

Responses 429 and 503 are routine with payment, AI, SEO and shipping APIs. Developers either retry in a hand-written loop with `sleep()` or not at all; the standard advice is exponential backoff, `Retry-After` and an attempt cap. [Jorijn, stellarwp/pup]

The package needs a retry policy as middleware: which statuses and transport errors, which methods are safe to retry, backoff with jitter, `Retry-After`, a cap, and re-sending only the failed members of a batch.

## No visibility into what was sent

Asking how to inspect outgoing requests gets no answers on the support forums. The known recipe hooks `http_api_debug` and dumps everything to `debug.log`, which logs every plugin's traffic and prints `Authorization` headers in clear. Query Monitor sees `WP_Http` traffic but not direct Requests or cURL calls. [WordPress.org support, templ.io, nextgenthemes, Seravo]

Logging must be scoped to the client that owns the request, structured, PSR-3 compatible and redacting by default. Batched requests must still fire `http_api_debug`.

## Decoding by hope

Forgetting `is_wp_error()` is old enough to have a 2008 ticket. Its modern form is calling `json_decode()` on an HTML error page and passing `null` on; `application/problem+json` bodies carrying the useful detail are treated as plain strings. [Trac #8620]

Decode by content type, throw on a failed decode with the raw body attached, turn 4xx and 5xx into typed exceptions, and let the plugin choose exceptions or `WP_Error` at the edge.

## Hand-written response mapping

Every API client ends up with methods mapping arrays to model objects field by field. General PHP hydrators exist but are heavy to bundle or collide with other plugins' copies.

A small hydrator is enough: constructor promotion, scalars, enums, dates, nested objects, lists and key renaming, with a `fromArray()` escape hatch. The endpoint declares the class it expects.

## Large downloads and file uploads

`WP_Http` can stream to a file with `stream`, `filename` and `limit_response_size`, and core uses them for bounded sideloads, but few plugin authors know these options. Passing a `CURLFile` to `wp_remote_post()` sends the file as a text field because Requests turns the body into a string. [WP_Http reference, wordpress-develop PR #12825, Trac #63828]

Streaming downloads with size caps are in scope. Multipart uploads are in scope as body building; streamed request bodies are not possible through Requests.

## SDKs that need PSR-18

Modern PHP SDKs accept any PSR-18 client and fail when none is installed. Inside WordPress the usual answer is to bundle Guzzle, which bypasses the site's HTTP settings and causes namespace collisions. Core's AI client hit the same problem and wrote a private adapter. [WP_AI_Client_HTTP_Client, Psr18ClientDiscovery]

The package implements PSR-18 over the WordPress HTTP API. PSR-18 is synchronous, so batching is a separate interface on the same transport.

## Dependency collisions between plugins

WordPress has no dependency manager; the first plugin to load a class wins. Core ticket #52400 concludes this is unlikely to be solved in core, and the accepted answer is prefixing with Strauss or PHP-Scoper. [Roots, Trac #52400, Strauss]

Prefixing is a first-class concern: the package documents a Strauss build and keeps its runtime dependencies to PSR interfaces and one small PSR-7 implementation.

## Unsafe URLs

`wp_safe_remote_*()` only sets `reject_unsafe_urls`, which calls `wp_http_validate_url()`. That function restricts schemes and ports but remains open to DNS rebinding, so plugins fetching user-supplied URLs stay exposed to limited server-side request forgery. [Patchstack, wp_safe_remote_get reference]

The package follows the site's setting and offers safe mode per client or endpoint, documents when to use it, and states plainly that it does not defeat DNS rebinding.

## Slow vendors stall the admin

Hosts see sites stall because a license check or update ping blocks on a slow vendor. One host built response caching into its platform plugin because plugins do not cache. [Seravo]

Caching is valuable but secondary: it is designed as middleware from the start so it can ship in a later minor release.

## Sources

- [WP_Http class reference](https://developer.wordpress.org/reference/classes/wp_http/)
- [Trac #33055: parallel HTTP requests in WP_Http](https://core.trac.wordpress.org/ticket/33055)
- [Trac #37459: WP_Http layer for parallel requests](https://core.trac.wordpress.org/ticket/37459)
- [StackHarbor: cURL error 28 and 60](https://stackharbor.com/en/knowledge-base/wp-curl-error-28-60-outbound-requests/)
- [Trac #63547: wp_remote_post not respecting timeout and blocking](https://core.trac.wordpress.org/ticket/63547)
- [Trac #18738: cron spawning and non-blocking requests](https://core.trac.wordpress.org/ticket/18738)
- [Trac #63828: CURLFile with wp_remote_post](https://core.trac.wordpress.org/ticket/63828)
- [wordpress-develop PR #12825: bounded URL sideloads](https://github.com/WordPress/wordpress-develop/pull/12825/files)
- [Trac #8620: WP_Error handling](https://core.trac.wordpress.org/ticket/8620)
- [WordPress.org support: logging wp_remote requests](https://wordpress.org/support/?p=3313947)
- [templ.io: logging wp_remote_get](https://templ.io/blog/how-to-enable-logging-of-wp_remote_get-wp_http/)
- [nextgenthemes: debugging wp_remote calls](https://gist.github.com/nextgenthemes/426879a7689ecd5899fbb5e7f3570edd)
- [Seravo: caching external HTTP requests](https://help.seravo.com/en/articles/413200-caching-responses-of-external-http-requests)
- [Jorijn: 429 Too Many Requests in WordPress](https://jorijn.com/en/knowledge-base/wordpress/errors/429-too-many-requests-in-wordpress/)
- [stellarwp/pup PR #53: retry on HTTP 429](https://github.com/stellarwp/pup/pull/53)
- [WP_AI_Client_HTTP_Client reference](https://developer.wordpress.org/reference/classes/wp_ai_client_http_client/)
- [Psr18ClientDiscovery::find reference](https://developer.wordpress.org/reference/classes/wordpress-aiclientdependencies-http-discovery-psr18clientdiscovery/find/)
- [Roots: prefixing namespaces in plugins](https://roots.io/prefix-namespaces-in-wordpress-plugins-to-avoid-conflicts/)
- [Trac #52400: dependency management](https://core.trac.wordpress.org/ticket/52400)
- [Strauss on Packagist](https://packagist.org/packages/brianhenryie/strauss)
- [Patchstack: unpatched WordPress SSRF](https://patchstack.com/articles/exploring-the-unpatched-wordpress-ssrf/)
- [wp_safe_remote_get reference](https://developer.wordpress.org/reference/functions/wp_safe_remote_get/)
- [alleyinteractive/wp-concurrent-remote-requests](https://github.com/alleyinteractive/wp-concurrent-remote-requests)
