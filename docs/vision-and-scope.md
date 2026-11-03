# Vision and scope

## Vision

One Composer package that makes outbound HTTP from a WordPress plugin or theme boring.

The developer describes what to call: an endpoint, a body, the class they want back. The package handles how: it runs through the WordPress HTTP layer so site settings, proxies and other plugins' filters still apply, sends several calls at once when possible, retries sensibly, logs what happened with secrets removed, decodes the body, maps it onto typed objects, streams large downloads to disk, and reports failures as exceptions that carry the response, or as `WP_Error` when the plugin prefers that.

It is not a new transport and never opens its own cURL handles. It is not a general-purpose PHP client competing with Guzzle. Its audience is code that runs inside WordPress.

The evidence behind this vision is in [research/developer-pain-points.md](research/developer-pain-points.md) and [research/existing-solutions.md](research/existing-solutions.md).

## Audiences

### Plugin authors

Stop writing the same `wp_remote_get()`, `is_wp_error()`, `json_decode()` and null-check block in every plugin.

### Theme and agency developers

Call three APIs on a page and wait for the slowest one, not the sum.

### SDK integrators

Hand a WordPress-backed PSR-18 client to any modern PHP SDK, and its traffic respects the site's HTTP settings.

### Site operators and hosts

Every outbound request is visible, timed, and logged with secrets masked, and every site-level HTTP policy applies to it.

## What it should feel like

The examples below are illustrative; the public API is set in the design.

Today, calling an API from a plugin looks like this, repeated per endpoint:

```php
$response = wp_remote_get( $url, [ 'timeout' => 20, 'headers' => [ 'Authorization' => "Bearer $token" ] ] );
if ( is_wp_error( $response ) ) { return $response; }
if ( 200 !== wp_remote_retrieve_response_code( $response ) ) { return new WP_Error( /* ... */ ); }
$data = json_decode( wp_remote_retrieve_body( $response ), true );
if ( null === $data ) { return new WP_Error( /* ... */ ); }
return new License( $data['license_key'] ?? '', $data['status'] ?? '' );
```

With the package, the author writes one class that holds a client, and the rest of the plugin calls named methods:

```php
final class StoreClient
{
    private ApiClient $http;

    public function __construct( string $token, LoggerInterface $logger, ?Transport $transport = null )
    {
        $this->http = new ApiClient(
            baseUri: 'https://store.example.com/api/v1',
            auth: Auth::bearer( $token ),
            retry: RetryPolicy::default(),
            logger: $logger,
            transport: $transport,
        );
    }

    public function license( string $key ): License
    {
        return $this->http->get( '/license/{key}', [ 'key' => $key ] )->expects( License::class )->send();
    }
}

$store   = new StoreClient( $token, $logger );
$license = $store->license( $key );
```

A method that needs three things waits for the slowest:

```php
$results = $this->http->batch( [
    'license' => Endpoint::get( '/license/{key}', [ 'key' => $key ] )->expects( License::class ),
    'version' => Endpoint::get( '/version/{slug}', [ 'slug' => $slug ] )->expects( PluginVersion::class ),
    'notices' => Endpoint::get( '/notices' ),
] );

$results['license']->value();
$results['notices']->isFailure();
```

Nothing in those calls changes a timeout, user agent, SSL verification, proxy or URL policy; those come from the site. The author overrides only what the plugin owns: its auth, its retry appetite, its logger, a longer timeout for a known slow endpoint.

For the site operator, every request, including every member of a batch, passes through `http_request_args`, `pre_http_request`, `https_ssl_verify`, `http_api_debug` and `http_response`, and honours `WP_HTTP_BLOCK_EXTERNAL`, `WP_ACCESSIBLE_HOSTS` and the proxy constants. Query Monitor and host tooling see the package's traffic as ordinary WordPress traffic. Where Requests' batch mode drops a setting, the package applies it explicitly, as decision 0002 describes.

## User stories

### Plugin author

- Define a client once with a base URL, default headers and auth, so each call is one line.
- Have `GET /thing/{id}` return a `Thing` object or throw, so arrays need no null checks.
- Get 4xx and 5xx responses as exceptions carrying status, headers, decoded body and request.
- Call `toWpError()` on any exception, so existing `WP_Error` code paths keep working.
- Send several requests at once and get results under the same keys, with per-key success or failure.
- Set a retry policy per client and override it per call, with backoff and `Retry-After` support.
- Retry only the failed members of a batch, so a batch of 50 does not become 100.
- Set a timeout for one slow endpoint without touching the site-wide filter.
- Encode request bodies from arrays by `Content-Type` and decode responses by theirs.
- Get `application/problem+json` as a typed exception with `title`, `detail` and `type`.
- Download a large file straight to disk with a size cap.
- Upload a file as multipart from a path or stream, so the API receives a file.
- See every request in Query Monitor and `http_api_debug`, to debug on sites I do not control.
- Give the client a PSR-3 logger that receives one structured entry per attempt with secrets masked.
- Configure which headers and body patterns are redacted.
- Replace the transport with an in-memory fake in tests, without WordPress or the network.
- Bundle the package with Strauss so it cannot collide with another plugin's copy.
- Pass the client to any PSR-18 SDK so its traffic follows the site's proxy and blocklist.

### Theme and agency developer

- Fetch three widgets' data in one batch during render.
- Cache responses with a TTL and stale-on-error, so a vendor outage shows stale data, not an empty page.
- Allow-list the hosts a client may call, so a URL from a content field cannot reach an internal host.

### Site operator and host

- See which domains a plugin calls, how long each call took and how often it failed, without global debug logging.
- Have `WP_HTTP_BLOCK_EXTERNAL`, `WP_ACCESSIBLE_HOSTS`, proxy constants and the standard filters apply to batches.

### Package maintainer

- Confine WordPress-specific code to one transport class, so everything else runs under plain PHPUnit.
- Enforce the compatibility matrix (WordPress 7.0+, PHP 8.2+ as proposed in decision 0012) in CI.
- Freeze the public API at 1.0 under semantic versioning, so plugins can pin `^1.0`.

## Scope for 1.0

### Transport

A `Transport` interface takes a keyed set of PSR-7 requests and returns keyed results. The WordPress transport sends single requests through `wp_remote_request()` and batches through `Requests::request_multiple()` with the same pipeline WordPress applies to one request. An in-memory transport for tests ships in the package.

### Client surface

`ApiClient` is a `final` class that a plugin or theme holds inside its own class, as decision 0017 records. It keeps the base URI, default headers, auth, middleware and codecs, and implements PSR-18 `ClientInterface` for single requests. A `batch()` method accepts keyed requests or endpoints and returns a result set with per-key success or failure. An `Endpoint` value object describes one call.

### Middleware

Middleware operates on batches, a single request being a batch of one. 1.0 ships retry, logging with redaction, auth injection and a host allow and deny list. Caching is designed as middleware and may ship in 1.1.

### Codecs

Requests are encoded as JSON, form-urlencoded or multipart with files. Responses are decoded from JSON, HAL+JSON, problem+JSON and text. The `Accept` header is derived from the registered decoders.

### Hydration

An attribute-based mapper handles constructor promotion, scalars, enums, `DateTimeImmutable`, nested objects, lists and key renaming, with a `fromArray()` convention for anything else. A mapping failure names the path that failed.

### Errors

`TransportException` records where a request failed (DNS, connect, TLS, read, blocked by the site). `ResponseException` carries a 4xx or 5xx response, `ProblemException` a problem+JSON body, and `DecodingException` and `MappingException` the failing body or path. Every package exception offers `toWpError()`.

### Streaming

Downloads stream to a file with a size cap and return a PSR-7 response whose body reads from disk. Multipart upload bodies are built from paths or streams.

### Packaging

The only runtime dependencies are PSR interfaces and one small PSR-7 implementation. The package ships a Strauss configuration and build instructions, and plugins and themes distributed to sites their authors do not control must prefix it. It supports WordPress 7.0+ and PHP 8.2+ (the PHP floor is proposed in decision 0012). It is licensed GPL-3.0-or-later, and its public API is everything under the package namespace not marked `@internal`.

### Observability

Each attempt produces one structured PSR-3 log entry with timing. `Authorization`, `Cookie`, `Set-Cookie` and configured body patterns are redacted by default.

## Later in 1.x

- Cache middleware backed by transients or the object cache, with TTL, ETag revalidation and stale-on-error.
- Client-side rate limiting per host, to avoid 429 responses in batch jobs.
- A WP-CLI command listing recent requests from the log.

## Exploratory

- Endpoint classes generated from OpenAPI specifications.
- A Guzzle transport so the same client runs outside WordPress, for tests and tooling.
- A Query Monitor collector showing batch grouping and attempts.

## Out of scope

- A cURL or socket transport of its own; it would bypass every WordPress filter.
- Promises, event loops or true async; the batch model is honest about blocking.
- Streamed request bodies; Requests turns every body into a string.
- Fire-and-forget requests, as recorded in decision 0015.
- Defeating server-side request forgery through DNS rebinding, a limitation of the platform.
- A general PHP serializer; the hydrator stays small.

## Non-functional requirements

- Only the WordPress transport and the `toWpError()` conversion reference WordPress functions or classes.
- No global state, no filters registered at load time, no constants required.
- A batched request produces the same hooks and `http_api_debug` arguments as the same request sent alone, except for differences documented in the design.
- Secrets never reach logs unless a client explicitly opts out.
- The public API is documented with examples, and `CHANGELOG.md` is kept from the first tag.
- CI covers every supported PHP version, the oldest and newest supported WordPress, and a Strauss build.

## Phasing

1. Foundation: PSR-7 and PSR-17 wiring, in-memory transport, codecs, error model, single-request PSR-18 client.
2. WordPress transport: single-request parity with `wp_remote_request()`, then batch parity.
3. Middleware: batch-aware retry, logging with redaction, auth, host policy.
4. Developer surface: `Endpoint`, `ApiClient`, hydrator, `toWpError()`, and a worked example client.
5. Streaming: downloads with size caps, multipart uploads.
6. Release 1.0, then cache and rate-limit middleware in 1.x.
