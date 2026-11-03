# Requests batch-mode gaps

`Requests::request_multiple()` does not behave like `Requests::request()` in five ways that matter for parity with `wp_remote_request()`. How the package handles each gap is decided in the design.

## Sources checked

Checked on 2026-11-03 against Requests 2.0.17, the copy bundled with WordPress 7.0 under `wp-includes/Requests/src/`, and Requests 2.0.21, the latest release. All five gaps exist in both. The files read, as paths inside the Requests library, are `src/Requests.php`, `src/Transport/Curl.php`, `src/Proxy/Http.php`, `src/Cookie/Jar.php` and `src/Auth/Basic.php`; they are not files of this package.

An earlier TechSpokes batch client already works around the first gap, which confirms it in practice.

## What batch mode does support

Each member may carry its own `options`, merged over the global options, so it can carry its own timeout, `filename`, `max_bytes`, proxy, cookies and hooks, although some of these are not applied (gaps 1 and 4). Results come back keyed by the submitted ids. `multiple.request.complete` fires per member in completion order, and `request.progress` fires as bytes arrive.

## Gap 1: SSL options are ignored

In single mode, `Curl::request()` applies `verify` and `verifyname` to the handle after setup. In batch mode, `Curl::get_subrequest_handle()` calls the same setup but never applies them.

Batch members therefore use cURL's system certificate store instead of the WordPress CA bundle, and `sslverify => false` and the `https_ssl_verify` filter have no effect. On a host with an outdated system store, a batch fails where the same single request succeeds.

## Gap 2: `http_api_curl` does not fire

Single mode dispatches `curl.before_send`, which `WP_HTTP_Requests_Hooks` maps to the `http_api_curl` action. Batch mode dispatches only `curl.before_multi_add` for each handle, so plugins and hosts that adjust cURL through `http_api_curl` do not affect batch members.

## Gap 3: redirects block the batch

A member that receives a redirect is followed inside `parse_multiple()`, which calls `parse_response()` and then a blocking `Requests::request()` from within the multi loop. While it runs, `curl_multi_exec()` is not called, so the other transfers stall and their timeouts keep running.

The redirected hop goes through single mode, so it applies `verify` and fires `http_api_curl`, unlike the first leg of the same member.

## Gap 4: proxy, basic auth and cookies are not applied

`Requests::set_defaults()` does not apply these settings directly; it registers them on hooks. The proxy and basic auth act on `curl.before_send`, and the cookie jar adds its header on `requests.before_request`.

Batch mode dispatches neither hook, so with the cURL transport a member's first leg goes out without the `WP_HTTP_Proxy` settings, without basic auth from the `auth` option, and without its cookies. A redirected hop goes through single mode and gets them back.

## Gap 5: batch-level hooks fire on one member

`curl.before_multi_exec` and `curl.after_multi_exec` are dispatched on the hooks object of the last member in the loop. With one hooks object per member, the matching `requests-*` actions fire once, with that member's URL and arguments.

## Related fact

`WP_Http` never passes `connect_timeout` to Requests (see [wordpress-http-request-pipeline.md](wordpress-http-request-pipeline.md)). A batch transport builds options itself and could pass it, which would make batches configurable where single requests are not.
