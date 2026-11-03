# Design overview

Who the package serves, what it promises them and how it is built. [interactions.md](interactions.md) shows how the actors and elements meet, [architecture.md](architecture.md) defines each element's responsibility and contracts, and each element gets its own file as it is designed.

## Actors

An actor is anyone or anything that depends on the package or is affected by it. Actors meet the package at three moments.

### When a plugin or theme is built

Plugin and theme developers want to learn the package quickly, make a call in a few lines, test their code without a live service, bundle the package safely and upgrade without surprises.

### When the package runs on a site

| Actor | What it needs |
| --- | --- |
| Calling code | A usable answer or a clear failure |
| Visitors and admins | Pages that do not hang on a slow vendor |
| Site owner or host | Site settings respected, traffic visible, nothing unrequested |
| WordPress | Outbound traffic through its own HTTP layer |
| Other plugins | Traffic they can still see and change |
| Remote service | Reasonable traffic that respects its limits |

Bad actors may control a URL or a response. The package does not serve them, and it must never trust either.

### Over time

Maintainers, people and AI assistants alike, need a package small enough to hold, quick warning when something breaks and simple releases. WordPress releases can change behaviour the package relies on, so the package must notice when they do.

## Promises

The actors' needs come down to five promises. A feature that serves none of them does not belong in the package.

1. It is easy to use.
2. It behaves like normal WordPress traffic.
3. It does only what it was asked to do.
4. Failures are clear and secrets stay private.
5. It stays small.

## Requirements

The design must meet these. The open questions below decide how, not whether.

- A batch sends its members in parallel.
- Requests and responses are PSR-7 messages.
- `ApiClient` implements PSR-18.
- Logging goes to a PSR-3 logger that the plugin or theme supplies.
- Copies distributed to sites the author does not control are prefixed with Strauss.

## Tensions

Actors pull against each other in four places, and these are the real design questions.

### Convenience and control

Developers want shortcuts, and site owners want the final say. The site wins, as decision 0004 Inherit transport settings from WordPress records.

### Speed and normal traffic

Batches are a main reason to use the package, but WordPress sends one request at a time. The design must state how close a member gets to a request sent alone, list every difference, and decide whether a batch limits how many members run at once.

### Reliability and waiting

Retries help the developer, but they cost visitors time and add load on the remote service. The design must set a limit on how long retries can hold a request.

### Visibility and privacy

Logs help debugging, but they can expose secrets. Redaction must cover everything the package records or carries, including exceptions.

## Elements

A call travels down through four elements, and the answer comes back up the same way. [architecture.md](architecture.md) defines each one.

```text
Plugin or theme code, or an SDK
        |
     ApiClient     intent in, answer out; builds requests, applies auth
        |          uses Body handling
     Middleware    retry and logging, only when attached
        |
     Transport     delivers a batch through WordPress, or in memory
        |
     WordPress  -> remote service
```

| Element | Job | Folder | Design file |
| --- | --- | --- | --- |
| ApiClient | Configuration, single calls, batches, PSR-18, exceptions | `src/Client/` | `client-api.md` |
| Body handling | Encoding, decoding and hydration | `src/Body/` | `body.md` |
| Middleware | Retry and logging | `src/Middleware/` | `middleware.md` |
| Transport | One contract, a WordPress and an in-memory adapter | `src/Transport/` | `transport.md` |

Three groups of shared values travel between them: messages, results and errors, and redaction.

`ApiClient` is a `final` class. A plugin or theme holds one inside its own class and the rest of its code calls that class, as decision 0017 Hold a final client in each plugin or theme records. An SDK or a one-off call may use `ApiClient` directly.

## Rules

- Each element knows only the element below it.
- Only the WordPress transport and `toWpError()` reference WordPress.
- With no middleware attached, a single call behaves like plain `wp_remote_request()`.
- Middleware treats a single call as a batch of one.
- Anything the package adds to WordPress lasts for one call and is removed afterwards.
- A logger, PSR-7 factory or SDK passed to a client comes from the same prefixed build.

## Open questions

Each question could change the design, and each has a test for what counts as yes. Work through them in this order and record each answer in `docs/research/` with its sources and versions.

### Can batch members count as normal WordPress traffic?

Yes means every site setting and debugging tool treats a member as it would a request sent alone, and any remaining difference is listed and acceptable. The known differences are in [requests-batch-mode-gaps.md](../research/requests-batch-mode-gaps.md).

### Can site and plugin rules survive a redirect?

Yes means blocked hosts stay blocked and credentials do not reach another host.

### Can failures be told apart reliably?

Yes means a timeout, a refused connection and a request blocked by the site are distinguishable, for single requests and members alike. Retries depend on this.

### Does PSR compatibility survive prefixing, with two copies on one site?

Yes means both copies run without interfering, and a logger or SDK in the same prefixed build works with the client. Strauss prefixes `psr/*` packages by default, so these interfaces change name with everything else.

### Can tests on real WordPress stay simple?

Yes means one command, on a maintainer's machine and in CI.
