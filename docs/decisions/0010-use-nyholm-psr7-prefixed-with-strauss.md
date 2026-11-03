# Use nyholm/psr7, prefixed with Strauss

Status: proposed.

## Context and problem

The package implements PSR-18 and needs a PSR-7 and PSR-17 implementation. Core bundles one under `WordPress\AiClientDependencies\`, but it is prefixed and private, so plugins cannot depend on it.

WordPress has no dependency manager: when two plugins bundle different versions of a library, whichever loads first wins (Trac #52400). Prefixing with Strauss or PHP-Scoper is the accepted answer.

## Options considered

### nyholm/psr7

The smallest implementation, with PSR-17 factories included.

### guzzlehttp/psr7

The most common implementation, larger, and the most frequent source of collisions between plugins.

### A package-owned implementation

No dependency, but permanent maintenance of code that is not the package's purpose.

## Decision

Use `nyholm/psr7`. Otherwise depend only on the interface packages `psr/http-message`, `psr/http-factory`, `psr/http-client` and `psr/log`. This gives the smallest prefixed footprint with no code to maintain.

Consumers must prefix the package and its dependencies with Strauss when they distribute it to sites they do not control. A consumer that already provides PSR-7 may inject its own factories from the same prefixed build.

## Consequences

The package documents the Strauss configuration and build step for consumers. Every new runtime dependency must stay prefixable.

Strauss prefixes `psr/*` packages by default, so the PSR interfaces change name with everything else. A logger, factory or SDK passed to a client must come from the same prefixed build.

## Confirmation

CI runs a Strauss build of the package and checks that the prefixed result loads and passes the unit tests.

## More information

- [Existing solutions](../research/existing-solutions.md)
- [Trac #52400: dependency management for plugins](https://core.trac.wordpress.org/ticket/52400)
- [Strauss](https://packagist.org/packages/brianhenryie/strauss)
