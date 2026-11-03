# wp-http-client

An HTTP client for WordPress plugins and themes. It sends every request through the WordPress HTTP API, so site settings, proxies, blocklists and debugging tools keep working, and it adds what plugin code keeps rewriting by hand: parallel requests, retries, logging with secrets redacted, body encoding and decoding, mapping responses to classes, streaming downloads and PSR-18 compatibility.

## Status

The package is in design and the public API is not settled. Version 0.0.1 is a scaffolding prerelease with no runtime implementation or installable Composer package. Its source archives contain only this README, the changelog and license; browse the [tagged repository](https://github.com/TechSpokes/wp-http-client/tree/v0.0.1) for the documentation and development files.

The problem, scope and design decisions are documented in [docs/README.md](docs/README.md). Progress is tracked in [GitHub Issues](https://github.com/TechSpokes/wp-http-client/issues).

## Requirements

- WordPress 7.0 or later
- PHP 8.2 or later (proposed in [decision 0012](docs/decisions/0012-require-php-8-2-or-later.md))

## Installation

The package will be published on Packagist as `techspokes/wp-http-client`. Plugins and themes that bundle it should prefix it with Strauss so that two plugins shipping different versions cannot collide; a guide comes with the first runtime release.

## Design principles

The package defers to WordPress. Timeouts, redirects, user agent, SSL verification, proxy settings and external request blocking come from the site, not from the package.

Features that change what is sent or recorded, such as retries, logging and caching, are opt-in and off by default.

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Ask questions and report bugs as described in [SUPPORT.md](SUPPORT.md), report vulnerabilities as described in [SECURITY.md](SECURITY.md), and follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Sponsorship

Development is maintained by [TechSpokes](https://www.techspokes.com). You can support it through [GitHub Sponsors](https://github.com/sponsors/TechSpokes).

## License

GNU General Public License v3.0 or later. See [LICENSE](LICENSE).
