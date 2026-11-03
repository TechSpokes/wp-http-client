# Architecture

How the package is built: which elements exist, what each one owns, and what each one guarantees to the others. It builds on the [design overview](README.md) and the [scenarios](interactions.md).

## How elements are defined

Each element has one card: a single responsibility, what it owns, what it does not own, and what it works with. Each seam between elements has one contract: what goes in, what comes back, what is guaranteed, and what happens on failure.

Three checks keep the design honest:

- Every need has exactly one owner.
- Deleting an element must push real complexity onto its callers; otherwise the element is cut.
- A seam needs two real implementations; otherwise it is an internal detail.

## System boundary

| Party | Owns |
| --- | --- |
| WordPress | Site settings, filters, sending, redirects, SSL, proxy, decompression |
| Plugin or theme | What to call, credentials, retry appetite, the logger, when to call |
| Package | Building requests, batching, retries, log entries, decoding, mapping, failures |
| Nobody here | DNS rebinding, background jobs, response caching in 1.0 |

The package never makes a decision from the first row, as decision 0004 Inherit transport settings from WordPress records.

## Elements

A call travels down through four elements and the answer comes back up the same way. Three shared values travel with it.

```text
Plugin or theme code, or an SDK
        |
     ApiClient      intent in, answer out; builds requests, applies auth
        |           uses Body handling
     Middleware     retry and logging, only when attached
        |
     Transport      delivers a batch through WordPress, or in memory
        |
     WordPress  ->  remote service
```

Dependencies point down only. Only the WordPress transport and `toWpError()` reference WordPress.

### ApiClient

| Field | Definition |
| --- | --- |
| Responsibility | Turn a caller's intent into a batch and return what the caller asked for |
| Owns | Base URI, default headers, auth, path templates, `Endpoint`, exceptions |
| Does not own | HTTP settings, retry logic, decoding rules, anything about WordPress |
| Works with | Body handling, Middleware, Transport |

`ApiClient` is `final` and immutable after construction, so one instance can be shared. It applies auth to the requests it builds; a PSR-7 request given to `sendRequest()` is sent as given, because an SDK owns its own auth.

It is the only element that creates exceptions. Below it, failures travel as values.

### Body handling

| Field | Definition |
| --- | --- |
| Responsibility | Convert between PHP values and message bodies |
| Owns | Encoders, decoders, the multipart builder, the hydrator |
| Does not own | The meaning of a status code, or anything about sending |
| Works with | ApiClient only |

Everything here runs without WordPress or a network, apart from reading an upload file.

### Middleware

| Field | Definition |
| --- | --- |
| Responsibility | Repeat or record what the transport does, only when the client attached it |
| Owns | Retry attempts and waits, one log entry per attempt |
| Does not own | Auth, host rules, decoding, exceptions, anything about WordPress |
| Works with | Transport, Redaction |

Retry wraps logging, which wraps the transport, so every attempt is logged. The order is fixed. With nothing attached, the client calls the transport directly.

### Transport

| Field | Definition |
| --- | --- |
| Responsibility | Deliver a batch through WordPress and report what happened to each member |
| Owns | PSR-7 and WordPress conversion, parallel sending, failure kinds, host rules and safe mode on every hop, files |
| Does not own | Retries, decoding, exceptions, or the meaning of a 4xx |
| Works with | WordPress, or nothing in the in-memory adapter |

This is the only seam with two adapters, and it owns 25 of the 51 needs. The interface stays small and everything difficult stays behind it.

Host rules and safe mode belong here, not in middleware, because middleware never sees redirect hops and the rule must hold on every hop.

### Shared values

Three groups of immutable values travel between the elements.

Messages: a `Member` holds a key, a PSR-7 request and call options; a `Batch` holds members in submission order. Call options carry what PSR-7 cannot: timeout, redirect limit, file target, byte cap, safe mode, host rules, and explicit WordPress arguments passed through under decision 0004, with the `reject_unsafe_urls` exception of decision 0003.

Results and errors: a `Result` holds a value or an exception, and either may carry the response. A `ResultSet` holds results under the submitted keys. Every package exception implements `toWpError()`, and transport failures implement the PSR-18 exception interfaces.

Redaction: the default secret list, configured patterns and the explicit opt-out. Log entries, exceptions and `toWpError()` carry only redacted copies of a request.

## Contracts

### Calling code and ApiClient

| Entry point | Returns | Throws |
| --- | --- | --- |
| A single call | The expected class, decoded body or response | Any package exception |
| `batch()` | A `ResultSet` under the submitted keys | Nothing for a member's failure |
| `sendRequest()` | A PSR-7 response, including 4xx and 5xx | Only when a request cannot be sent |

All three share one path down. Only the first two interpret the answer, because PSR-18 forbids treating a well-formed response as an error.

### Transport

```php
interface Transport
{
    public function send(Batch $batch): DeliverySet;
}
```

A delivery is a PSR-7 response or a `Failure` value with a kind, a message and the site's error code. The transport guarantees that:

- It returns exactly one delivery per member, under its key and in submission order.
- It never throws because of a member's failure.
- It adds no defaults of its own, so site settings apply.
- It returns a 4xx or 5xx as an ordinary response.
- It sends members in parallel where the platform allows.
- It applies host rules and safe mode to the first URL and to every hop.
- It drops the client's credentials when a redirect leaves the original host.
- It returns responses whose headers match their bodies.
- It leaves nothing registered in WordPress after `send()` returns.
- It records how long each member took.

Both adapters run one shared contract test suite, so the in-memory adapter cannot drift from the real one. Plugins pass a `Transport` in but do not implement one; the interface is marked `@internal` for implementers until 1.x.

### Middleware

```php
/** @internal */
interface Middleware
{
    public function process(Batch $batch, callable $next): DeliverySet;
}
```

A middleware returns exactly one delivery per member, may call `$next` again with only the failed members, and changes a request only by creating a new one. The interface is internal so that cache middleware can be added in 1.x without a public commitment now.

### Transport and WordPress

The WordPress adapter relies on as little as possible:

- `wp_remote_request()` sends single requests, as decision 0001 records.
- `wp_remote_retrieve_*()` reads responses, because a short-circuit array has no `http_response` key.
- `http_request_not_executed` identifies a blocked request.
- Every other failure is classified from its message, and `unknown` is a valid kind.
- A `WP_Error` returned by a filter keeps its own code and message.
- The batch path is decided by the first open question in the design overview.

Headers with several values stay separate, because values such as `Set-Cookie` cannot be joined with a comma.

### External interfaces

| Interface | Role | Obligation that matters |
| --- | --- | --- |
| PSR-7 | Messages | Immutable; bodies may not be replayable |
| PSR-17 | Building messages | File-backed responses for downloads |
| PSR-18 | SDK entry point | No exception for 4xx or 5xx; consistent responses |
| PSR-3 | Logging | Context must not throw; exceptions go under `exception` |

## Failure rules

- Transport and middleware report a member's failure as a `Failure` value.
- `ApiClient` turns failures into exceptions: thrown for a single call, kept in the `Result` for a batch member.
- Body handling throws, and `ApiClient` keeps that exception in the `Result` for a batch member.
- Failure kinds are blocked, timeout, DNS, connect, TLS, read, truncated and unknown.
- Truncated means the byte cap was reached; how the adapter detects it is settled with the first open question.

## Check against the needs

Every need has one owner, in scenario order.

| Scenario | Owners |
| --- | --- |
| A developer adds a client | ApiClient 3 |
| One call | Body 2, ApiClient, Transport 2 |
| A batch | Transport 5 |
| The site blocks a call | Transport 4, Middleware |
| Another plugin answers a call itself | Transport 3 |
| A remote service says slow down | Middleware 7 |
| A response is not what was expected | Results, Body 2, Results 2 |
| A call is redirected to another host | Transport 2 |
| A developer debugs on a site they do not control | Middleware 2, Redaction 2 |
| A large download | Transport 3 |
| A file upload | Body |
| An SDK uses the package | Transport, ApiClient, Transport |
| Two plugins bundle different versions | Packaging, Transport |
| A developer tests their plugin | Transport 2 |
| A new WordPress release | Transport |

| Owner | Needs |
| --- | --- |
| Transport | 25 |
| Middleware | 10 |
| ApiClient | 5 |
| Body handling | 5 |
| Results and errors | 3 |
| Redaction | 2 |
| Packaging | 1 |

Packaging is not a runtime element. It is `composer.json`, the Strauss guide and the prefixed CI build, and it owns the one need about two copies on one site.

### Features no need asks for

Each should gain a need or leave 1.0:

- The `onComplete` callback in decision 0005.
- The download progress callback in decision 0006.
- A separate HAL+JSON decoder, because any `+json` type decodes as JSON.
- Deriving the `Accept` header from registered decoders.

## Decisions to settle

- Whether a batch limits how many members run at once, and the default limit.
- The total time limit for retries, and where it is set.
- Whether redirects on the PSR-18 path follow the site's setting; this proposal says yes, because the package defers to WordPress.

## Prior art

| Source | What it confirms |
| --- | --- |
| [WP_AI_Client_HTTP_Client](https://github.com/WordPress/wordpress-develop/blob/trunk/src/wp-includes/ai-client/adapters/class-wp-ai-client-http-client.php) | Options travel beside the PSR-7 request |
| [Guzzle client](https://github.com/guzzle/guzzle/blob/7.10/src/Client.php) | The PSR-18 path turns off error exceptions |
| [Guzzle redirects](https://github.com/guzzle/guzzle/blob/7.10/src/RedirectMiddleware.php) | Credentials are dropped on cross-origin redirects |
| [Symfony Psr18Client](https://github.com/symfony/http-client/blob/7.4/Psr18Client.php) | PSR-18 sits as an adapter over the main client |
| [Symfony NoPrivateNetworkHttpClient](https://github.com/symfony/http-client/blob/7.4/NoPrivateNetworkHttpClient.php) | Host rules are enforced on every hop |
| [Symfony retry strategy](https://github.com/symfony/http-client/blob/7.4/Retry/RetryStrategyInterface.php) | The retry decision is separate from the retry mechanism |
| [HTTPlug Plugin](https://github.com/php-http/client-common/blob/2.x/src/Plugin.php) | Middleware receives a request and a `next` step |
| [Responsibility-driven design](https://wirfs-brock.com/resp_driven_design.html) | Define elements by roles, responsibilities and collaborators |
