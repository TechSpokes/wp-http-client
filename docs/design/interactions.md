# Interactions

How the actors in the [design overview](README.md) meet the package, one short scenario at a time. Each scenario ends with the needs it covers: plain sentences stating what an actor can rely on. Every need becomes a test, and a test that traces back to no need is not written.

Component files link to these scenarios instead of repeating them.

## A developer adds a client

Actors: plugin or theme developer.

1. The developer requires the package and, if it goes on sites they do not control, sets up Strauss.
2. They write one class that holds an `ApiClient`, with the base URI and any auth, retry policy and logger.
3. They add named methods for the calls the plugin makes.
4. The rest of the plugin calls those methods and never builds a URL.

Needs:

- A client that sets only a base URI works.
- A one-off call needs no class of its own.
- A package update that adds a method cannot clash with a plugin's own methods.

## One call

Actors: calling code, WordPress, remote service.

1. Calling code calls a method on its client.
2. The client builds a PSR-7 request and encodes the body.
3. Attached middleware runs; with none attached, nothing happens here.
4. The transport hands the request to WordPress, which applies site settings and filters and sends it.
5. The client receives a PSR-7 response, decodes the body and hydrates the expected class.

Needs:

- A successful call returns the class the endpoint expects.
- A client with no middleware sends exactly one request per call.
- A call with no overrides uses the site's timeout, user agent, redirect and SSL settings.

## A batch

Actors: calling code, visitors and admins, site owner, remote service.

1. Calling code submits three endpoints under its own keys.
2. Each member goes through the site's rules as if sent alone.
3. The members are sent in parallel.
4. One member times out and the other two succeed.
5. Calling code gets all three results under its keys, and the site owner sees three requests in their usual tools.

Needs:

- A batch takes about as long as its slowest member, not the sum of all of them.
- A failed member does not stop the others.
- Results come back under the submitted keys, in submission order.
- Every member passes through the same filters and site settings as a request sent alone.
- Every member appears as one request in the site's debugging tools.

## The site blocks a call

Actors: site owner, calling code.

1. The site owner blocks external requests or a specific host.
2. A plugin sends a call or a batch that includes that host.
3. WordPress refuses the call, and nothing leaves the site.
4. Calling code gets a failure that says the site blocked it.

Needs:

- A request the site blocks never leaves the site, whether sent alone or in a batch.
- A blocked request is reported differently from a network failure.
- A retry policy never repeats a blocked request.

## Another plugin answers a call itself

Actors: other plugins, calling code.

1. Another plugin short-circuits a request through `pre_http_request`.
2. WordPress uses that answer, and nothing is sent.
3. Calling code receives the answer as it would any other.

Needs:

- A short-circuited call returns the filter's answer and sends nothing.
- A short-circuited member leaves the other members untouched.
- A `WP_Error` from a filter reaches calling code as a normal failure.

## A remote service says slow down

Actors: remote service, calling code, visitors and admins.

1. A client with a retry policy sends a batch.
2. The service answers one member with status 429 and `Retry-After`.
3. If the wait fits within the policy's limit, the policy waits and re-sends that member.
4. Otherwise, calling code gets the failure with the response attached.

Needs:

- Without a retry policy, nothing is retried.
- A retry re-sends only the failed members of a batch.
- Methods that are not safe to repeat are not retried by default.
- Retries never hold a request past the policy's time limit.
- Each attempt appears as its own request in the site's debugging tools.

## A response is not what was expected

Actors: calling code, plugin or theme developer.

1. The service answers with an error status, a problem+JSON body, or an HTML page in place of JSON.
2. The client raises a typed exception that carries the response.
3. The plugin handles the exception, or converts it to a `WP_Error`.

Needs:

- A 4xx or 5xx response raises an exception carrying status, headers, decoded body and request.
- A body that cannot be decoded raises an exception carrying the raw body and never yields `null`.
- A mapping failure names the path that failed.
- Every package exception converts to a `WP_Error`.

## A call is redirected to another host

Actors: site owner, bad actors, calling code.

1. A call that carries credentials gets a redirect to a different host.
2. The package applies safe mode and host rules to the new location.
3. If the location is allowed, the request continues without the client's credentials.
4. If not, calling code gets a failure.

Needs:

- Safe mode and host rules apply to every redirect, not only the first URL.
- Credentials added by a client never reach a different host.

## A developer debugs on a site they do not control

Actors: plugin or theme developer, site owner, bad actors.

1. The client has a PSR-3 logger attached.
2. Every attempt produces one structured entry with its timing.
3. Secrets are masked before the entry reaches the logger.

Needs:

- Without a logger, the package records nothing.
- Each attempt produces one log entry.
- Secrets never appear in log entries, exceptions or `WP_Error` data unless a client explicitly opts out.

## A large download

Actors: calling code, site owner, bad actors.

1. Calling code asks for a file to be written to disk, with a size cap.
2. WordPress streams the response to the file.
3. Calling code gets a PSR-7 response whose body reads from that file.

Needs:

- A download stays off the PHP heap.
- A download that passes the size cap is reported as such, never as complete.
- A download works the same alone and inside a batch.

## A file upload

Actors: calling code, remote service.

1. Calling code gives a file path or stream as part of a multipart body.
2. The client builds the whole body in memory and sends it through the normal path.

Needs:

- The remote service receives a file, not a text field.

## An SDK uses the package

Actors: plugin or theme developer, site owner, WordPress.

1. The developer creates an `ApiClient`.
2. They pass it to an SDK that accepts a PSR-18 client, bundled in the same prefixed build.
3. The SDK sends PSR-7 requests through the client, down the same path as any other call.

Needs:

- SDK traffic follows site settings like any other call.
- `sendRequest()` returns 4xx and 5xx responses and throws only when a request cannot be sent.
- The returned response is internally consistent, as PSR-18 requires.

## Two plugins bundle different versions

Actors: other plugins, plugin or theme developer, site owner.

1. Two plugins bundle different versions of the package, each under its own prefix.
2. Both run in the same PHP request, and each plugin uses its own copy.

Needs:

- Two prefixed copies of different versions run side by side.
- The package leaves nothing registered in WordPress after a call ends.

## A developer tests their plugin

Actors: plugin or theme developer.

1. A test creates a client with the in-memory transport and gives it to the plugin's class.
2. It queues the responses or failures it wants.
3. It runs the plugin's code, without WordPress or a network.

Needs:

- A plugin's class can use the in-memory transport without changes to its code.
- The in-memory transport behaves like the WordPress transport in everything a client can see.
