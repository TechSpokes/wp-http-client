# Plan to 1.0

The way from the current design to release 1.0, derived backwards from the goal. Each gate is a condition that must be true before the work behind it starts, so that nothing is built on a guess. Progress is tracked in GitHub issues; this file holds the gates, their order and what each one needs.

## Goal

Release 1.0 so that plugins and themes can pin `^1.0`. The release holds the five promises of the [design overview](README.md) when all of the following are true:

1. Every need in [interactions.md](interactions.md) has a passing test on the supported matrix: WordPress 7.0 and the newest release, PHP 8.2 and the newest release.
2. The public API is frozen: everything not marked `@internal` is documented in `docs/guides/`.
3. A Strauss-prefixed build passes the same tests, with two prefixed copies loaded side by side.
4. One real client built on the package has been reviewed, as decision 0017 requires.
5. The package is on Packagist with a changelog.

## What each condition needs

Each line names what the condition cannot exist without, down to things that exist today.

### Passing tests on the matrix

Needs the code, the harness and the CI matrix. The code needs approved element design files (gate 4). The transport design file needs the batch answer (gate 2) and the redirect and failure answers (gate 3). Those answers need real WordPress in both versions, a server the experiment controls, and the harness that boots them (gate 1). The harness needs the approved harness design, which is decision 0021 and `testing.md`.

### A frozen public API

Needs every element design file written and the open decisions settled. Decisions 0018 to 0021 settle them; they are reviewed with this plan (gate 0). Only `transport.md` depends on gates 2 and 3.

### A passing Strauss build

Needs `composer.json` and a stand-in plugin pair. It needs no WordPress and is part of the harness (gate 1).

### A reviewed real client

Needs the code through slice 6 and Serge's plugin.

## Gates

### Gate 0: the design is merged

Pull request #5 is merged. It carries the design overview, the scenarios, the architecture, this plan, decisions 0017 to 0021, and the edits to decisions 0005, 0006 and 0009.

### Gate 1: the harness boots WordPress

`testing.md` is approved, which unlocks `composer.json` with development dependencies only and `tests/`; `src/` stays closed until gate 4. The harness is built as decision 0021 describes: WordPress 7.0 and the newest release downloaded into an ignored folder, the SQLite drop-in, the one-file fixture server, and a bootstrap that boots one version per PHPUnit run.

The gate is true when one command boots each version and the first test sends `wp_remote_request()` to the fixture and asserts what the fixture received, on the maintainer's machine and on all four CI cells. The Strauss job runs the unit suite against two prefixed stand-in plugins in the same workflow.

The experiments in gates 2 and 3 run on this harness, so nothing is built twice.

### Gate 2: the batch question is answered

The yes-test from the design overview: every site setting and debugging tool treats a member as it would a request sent alone, and every remaining difference is listed and acceptable.

The experiment runs thirteen scenarios through `wp_remote_request()` and through each candidate, and diffs four things: the hook trace with arguments, the `http_api_debug` arguments, what the fixture received, and the result. Query Monitor is installed in the test site, and its HTTP panel data is part of the diff, because it is the debugging tool site owners use.

The scenarios are: plain GET, POST with a body, redirect to the same host, redirect to another host, TLS with the core CA bundle, `sslverify` false, proxy constants set, cookies sent and received, a `pre_http_request` short-circuit, a blocked host, a refused connection, a timeout, and a request sent from inside a filter callback.

Two candidates are compared:

1. The pre-flight replica of decision 0002: recompute what `WP_Http::request()` computes for each member, then call `Requests::request_multiple()`.
2. Interception: run the real `wp_remote_request()` for each member inside a PHP Fiber, replace the Requests transport through the `transport` option during `requests.before_request`, park the prepared request, send every parked request together through the bundled cURL transport, and resume each Fiber with its raw response.

Interception is the recommendation before running, because it copies nothing from core and so cannot drift, and because redirects and cookies take WordPress's own path. Its constraints are known: a Fiber may not suspend inside WordPress's hook stack, so a request made from inside a filter callback stays blocking; without cURL, members run one at a time; and the replacement transport must delegate to the bundled Requests transport, never open its own handles. The replica wins if interception fails a scenario the replica passes, or if the Fiber constraint cannot be contained in the transport.

The gate is true when one candidate passes the yes-test, decision 0002 is edited in place with the result, and a research note records the diff for every scenario.

### Gate 3: redirects and failure kinds are settled

Both run on the gate 1 harness with the gate 2 batch path. Redirects: a hop to another host drops the client's credentials and is checked against host rules and safe mode, for single requests and members alike. Failure kinds: timeout, refused connection, TLS failure, blocked host and a filter's `WP_Error` are each told apart, and the classifier's rules are written into `transport.md` with the messages they match on both WordPress versions.

### Gate 4: the element design files are approved

`client-api.md`, `middleware.md` and `body.md` can be written as soon as gate 0 passes. `transport.md` waits for gate 3. Each file turns its card in [architecture.md](architecture.md) into signatures, value objects and the test names it owns. Serge's approval of all four opens `src/`.

### Gate 5: slices

Each slice is one pull request carrying its needs as tests, its code and the design file it changes, and starts when the previous one is merged. The order follows risk, which puts the transport first.

1. One GET from `ApiClient` through real WordPress to the fixture, and the same test against the in-memory adapter.
2. A batch of two through the batch path chosen at gate 2, with the cap of decision 0018.
3. Failure kinds, `Result`, exceptions, `toWpError()` and `sendRequest()` with the redirect behaviour of decision 0020.
4. Host rules and safe mode on the first URL and every hop.
5. Retry with the time budget of decision 0019.
6. Logging with redaction.
7. Codecs, problem+JSON and the hydrator.
8. Downloads with the byte cap, and multipart uploads.

### Gate 6: release

A 0.x prerelease after slice 6, Serge's client built on it, an API review that marks everything else `@internal`, the guides, then 1.0.

## Where the work runs

Gates 1 to 3 and the slices run on the maintainer's machine, where the agent has PHP, Composer and network access to download WordPress. Design and review work can happen anywhere. The research notes and decision edits from gates 2 and 3 are written by the agent that ran the experiment, from the raw output, in the same pull request as the experiment's results.
