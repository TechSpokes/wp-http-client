# WordPress HTTP request pipeline

What `WP_Http::request()` does to one request, in order. The package's batch transport must reproduce this for every member, so each step names the hook or option involved.

## Sources checked

Read on 2026-11-03 from WordPress trunk: `wp-includes/class-wp-http.php` and `wp-includes/class-wp-http-requests-hooks.php`. Not yet re-checked against the 7.0 tag, the oldest supported release.

## 1. Defaults

Five defaults come from filters, each receiving the URL:

| Argument | Filter | Default |
| --- | --- | --- |
| `timeout` | `http_request_timeout` | 5 |
| `redirection` | `http_request_redirection_count` | 5 |
| `httpversion` | `http_request_version` | `1.0` |
| `user-agent` | `http_headers_useragent` | `WordPress/<version>; <site URL>` |
| `reject_unsafe_urls` | `http_request_reject_unsafe_urls` | false |

Fixed defaults: `blocking` true, `decompress` true, `sslverify` true, `sslcertificates` set to the core CA bundle, `stream` false, `filename` null, `limit_response_size` null. HEAD requests default to zero redirects.

## 2. Filters and short-circuit

The caller's arguments are merged over the defaults with `wp_parse_args()`, then passed through the `http_request_args` filter. Next, `pre_http_request` runs; any non-false return is used as the response and nothing is sent.

## 3. URL checks

When `reject_unsafe_urls` is true, the URL goes through `wp_http_validate_url()`. Every URL then goes through `wp_kses_bad_protocol()` and `WP_Http::block_request()`, which applies `WP_HTTP_BLOCK_EXTERNAL` and `WP_ACCESSIBLE_HOSTS`. Each failure fires `http_api_debug` and returns a `WP_Error`.

## 4. Streaming to a file

When `stream` is true and no `filename` is given, the file becomes `get_temp_dir() . basename( $url )`. `blocking` is forced to true, and the destination directory must be writable.

## 5. Requests options

`WP_Http` builds the options for Requests from known keys only:

- `timeout`, `useragent` and `blocking` from the arguments.
- `hooks`: a new `WP_HTTP_Requests_Hooks( $url, $parsed_args )` per request.
- `browser_redirect_compatibility` registered on `requests.before_redirect`.
- `validate_redirects` registered on `requests.before_redirect` when unsafe URLs are rejected.
- `filename` when streaming, `redirects` or `follow_redirects` from `redirection`.
- `max_bytes` from `limit_response_size`, normalized `cookies`.
- `verify` and `verifyname` from `sslverify` and `sslcertificates`, then the `https_ssl_verify` filter.
- `data_format` set to `body` for methods other than GET and HEAD.
- `proxy` from `WP_HTTP_Proxy` when the URL should go through it.

Because only these keys are passed, some settings never reach Requests through `wp_remote_request()`:

- `httpversion`: Requests uses its own default, HTTP/1.1, so the `http_request_version` filter has no effect.
- `compress` and `decompress`: Requests always decompresses responses.
- `connect_timeout`: Requests' own default of 10 seconds applies.

## 6. Sending

`mbstring_binary_safe_encoding()` is set, `Requests::request()` sends, the response is wrapped in `WP_HTTP_Requests_Response`, and `reset_mbstring_encoding()` restores the encoding. A `WpOrg\Requests\Exception` becomes `WP_Error( 'http_request_failed' )`.

## 7. After the response

`http_api_debug` fires with the response or error, the context `response`, the class `WpOrg\Requests\Requests`, the parsed arguments and the URL. For blocking requests that succeeded, the `http_response` filter runs last.

## Hooks bridge

`WP_HTTP_Requests_Hooks::dispatch()` turns every Requests hook into the WordPress action `requests-{$hook}`, with the request's own URL and arguments. It also maps `curl.before_send` to the `http_api_curl` action.

A batch therefore needs one hooks object per member; a shared object would report the wrong URL and arguments to these actions.
