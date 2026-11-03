# Plan to 1.0

The way from the current design to release 1.0, derived backwards from the goal. Each gate lists what must be true before the work behind it starts, so that nothing is built on a guess. Progress against this plan is tracked in GitHub issues; this file holds only the gates and their order.

## Goal

Release 1.0 so that plugins and themes can pin `^1.0`. The release must hold the five promises of the [design overview](README.md), which means:

1. Every need in [interactions.md](interactions.md) has a passing test on the supported matrix: WordPress 7.0 and the newest release, PHP 8.2 and the newest release.
2. The public API is frozen: everything not marked `@internal` is documented in `docs/guides/`.
3. A Strauss-prefixed build passes the same tests, with two prefixed copies loaded side by side.
4. At least one real client built on the package has been reviewed, as decision 0017 requires.
5. The package is on Packagist with a changelog.

## Walking backwards

Each line names what the item above it cannot exist without.

Passing tests on the matrix need the code, the harness and the matrix in CI. The code needs approved element design files. The element design files need the transport contract settled. The transport contract needs the answer to the batch question. The batch question needs real WordPress in two versions, a server that can replay redirects, TLS and proxies, and an experiment script. The harness needs the same things, plus a choice of test runner and WordPress bootstrap. The matrix needs CI jobs, which need the harness.

A frozen public API needs every element design file written, the four unneeded features settled, and the three open decisions settled. None of these need the batch answer, except the parts of `transport.md` that describe the batch path.

The Strauss build needs `composer.json` and a stand-in plugin pair. It needs no WordPress.

The real client needs the code through slice 6 and Serge's plugin.

## Gates

Each gate is a condition, not a date. Work behind a gate starts only when the gate is true.

### Gate 0: the design is merged

Pull request #5 is merged and decisions 0018 to 0021 are accepted or rewritten. This plan, the four records and the edits to decisions 0005 and 0006 are part of that review.

### Gate 1: WordPress runs where the experiments run

The experiments for the batch question, redirects and failure kinds all need WordPress 7.0 and the newest release booted from the command line, against a local server the experiment controls. Decision 0021 chooses how. This gate is true when one command boots both versions and makes one request to the fixture, on the machine that will run the experiments.

### Gate 2: the batch question is answered

The yes-test from the design overview: every site setting and debugging tool treats a member as it would a request sent alone, and every remaining difference is listed and acceptable. The experiment runs the same ten scenarios through `wp_remote_request()` and through each candidate batch approach and diffs the hook trace, the `http_api_debug` arguments, what the server received and the result.

The scenarios are: plain GET, POST with body, redirect to the same host, redirect to another host, TLS with the core CA bundle, `sslverify` false, proxy constants set, cookies sent and received, `pre_http_request` short-circuit, blocked host, connection refused, timeout, and a request sent from inside a filter.

Two candidates are compared:

1. The pre-flight replica of decision 0002, which recomputes what `WP_Http::request()` computes and then calls `Requests::request_multiple()`.
2. Interception: run the real `wp_remote_request()` for each member inside a PHP Fiber, swap in a transport through the `transport` option during `requests.before_request`, park the prepared request, send all parked requests together, and resume each Fiber with its raw response.

The recommendation before running is interception, because it copies nothing from core and therefore cannot drift, and because redirects and cookies take WordPress's own path. Its known costs are that a request made from inside a hook callback must stay blocking, because a Fiber may not suspend inside WordPress's hook stack, and that without cURL members run one at a time. The replica wins if interception fails any scenario the replica passes, or if the Fiber constraint turns out to bite in a way the design cannot contain. Decision 0002 is edited in place with the result, and the research note records the diff for every scenario.

Gate 2 is true when one candidate passes the yes-test and its differences are written into `docs/research/`.

### Gate 3: redirects and failure kinds are settled

Both run in the harness from gate 1 and need no new setup. Redirects: a hop to another host drops the client's credentials and is checked against host rules and safe mode, for single requests and members alike. Failure kinds: timeout, refused connection, TLS failure, blocked host and a filter's `WP_Error` are each told apart, and the classifier's rules are written into `transport.md` with the messages they match.

### Gate 4: the element design files are approved

`transport.md`, `client-api.md`, `middleware.md`, `body.md` and `testing.md` exist, each turning its card in [architecture.md](architecture.md) into signatures, value objects and the list of test names it owns. Serge approves them, which unlocks `src/`, `tests/` and `composer.json`.

`client-api.md`, `middleware.md`, `body.md` and `testing.md` can be written before gate 2. `transport.md` waits for it.

### Gate 5: the harness proves itself

`composer.json`, PHPUnit, PHPStan, the coding-standard check, the wire fixture, the WordPress bootstrap and the CI matrix exist. The first test compares `wp_remote_request()` with itself through the harness. Gate 5 is true when that test passes locally and in CI on all four matrix cells, and a Strauss build job runs on a stand-in plugin pair.

### Gate 6: slices

Each slice is one pull request carrying its needs as tests, its code, and the design file it changes. A slice starts only when the previous one is merged.

1. One GET from `ApiClient` through real WordPress to the fixture, and the same test against the in-memory adapter.
2. A batch of two through the batch path chosen at gate 2.
3. Failure kinds, `Result`, exceptions and `toWpError()`.
4. Host rules and safe mode on the first URL and every hop.
5. Retry with the time budget of decision 0019.
6. Logging with redaction.
7. Codecs, problem+JSON and the hydrator.
8. Downloads with the byte cap and multipart uploads.
9. PSR-18 `sendRequest()` with the redirect behaviour of decision 0020.

### Gate 7: release

A 0.x prerelease after slice 6, Serge's client built on it, an API review that marks everything else `@internal`, the guides, then 1.0.

## Open input

One input only Serge can give: where gates 1 to 3 run. The options are Serge's machine, or this assistant's sandbox once it is allowed to run downloaded WordPress code. The recommendation is the sandbox, because the experiment and its write-up then happen in one place and the research note is written from the raw output.
