# Follow site redirect settings on the PSR-18 path

Status: proposed.

## Context and problem

PSR-18 says nothing about redirects. Guzzle's `sendRequest()` turns redirect following off, so the SDK sees the 3xx response. WordPress follows up to `http_request_redirection_count` redirects, five by default, and some SDKs expect the client to follow them.

## Options considered

### Turn redirects off on the PSR-18 path

Matches Guzzle. An SDK that relies on the client following redirects breaks, and the package overrides a site setting for one entry point.

### Follow the site's setting

Matches every other call the package makes. An SDK that wants to see the 3xx itself does not get it.

## Decision

Follow the site's setting on the PSR-18 path, as on every other path. The package defers to WordPress, and one entry point behaving differently would surprise site owners and be hard to document. Host rules, safe mode and credential dropping apply to every hop exactly as for other calls.

## Consequences

An SDK that needs to handle redirects itself sets the redirect limit to zero through the call options the package exposes for PSR-7 requests, which maps to `redirection => 0`.

## Confirmation

The transport contract tests send a PSR-7 request to a redirecting endpoint and check that the final response is returned, and that `redirection => 0` returns the 3xx.

## More information

- [0004 Inherit transport settings from WordPress](0004-inherit-transport-settings-from-wordpress.md)
- [PSR-18](https://www.php-fig.org/psr/psr-18/)
- [Guzzle client](https://github.com/guzzle/guzzle/blob/7.10/src/Client.php)
