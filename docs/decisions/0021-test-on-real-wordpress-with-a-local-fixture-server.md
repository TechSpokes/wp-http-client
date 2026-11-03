# Test on real WordPress with a local fixture server

Status: proposed.

## Context and problem

Half of the needs belong to the transport, and the transport's job is to behave like WordPress. Tests that stub `wp_remote_request()` or short-circuit `pre_http_request` bypass exactly what is at risk. The tests need real WordPress, in the oldest and newest supported versions, making real HTTP requests to a server the tests control, and they must run with one command on a maintainer's machine and in CI.

Constants such as `WP_HTTP_BLOCK_EXTERNAL` cannot be undefined, so each site configuration needs its own PHP process.

## Options considered

### The WordPress core test suite with WP_UnitTestCase

Familiar, but it pins `yoast/phpunit-polyfills` at `^1.1`, which stops at PHPUnit 9, and it brings factories and database rollback the package does not use.

### wp-env

Official and already in the repository as a skill, but it needs Docker and Node on every machine that runs the tests, and it is built around a browser-facing site rather than command-line requests.

### A plain WordPress bootstrap on SQLite, with a PHP fixture server

WordPress is downloaded once per version, booted from the command line with the SQLite Database Integration drop-in, and tests make requests to a single-process PHP server that answers plain HTTP, TLS with a generated CA, and acts as a proxy. Nothing but PHP is needed.

## Decision

Use a plain WordPress bootstrap on SQLite with a PHP fixture server. It is the only option that runs with PHP alone, on any machine and in CI, and it tests the WordPress HTTP layer directly.

The parts are:

- PHPUnit 11.5, the last line that supports PHP 8.2, with three suites: `Unit` without WordPress, `Integration` inside WordPress, and `Integration/Parity`.
- A bootstrap that downloads WordPress 7.0 and the newest release into an ignored folder, installs the SQLite drop-in, and boots one version per PHPUnit run; a site configuration that needs constants runs in a child PHP process.
- A fixture server in one PHP file using `stream_select`, so it needs no extensions beyond OpenSSL and runs on Windows; it logs every request it receives so tests can assert what reached the wire.
- PHPStan at the highest level that passes, with WordPress stubs allowed only for the transport and `toWpError()`, so a stray WordPress call elsewhere fails analysis.
- A coding-standard check for PER Coding Style, with the tool chosen when `composer.json` is created.
- GitHub Actions running all suites on WordPress 7.0 with PHP 8.2 and on the newest WordPress with the newest PHP, plus a Strauss build job that prefixes two stand-in plugins and runs the unit suite against them.

If the SQLite drop-in fails on a version the package must support, the fallback is a MySQL service container in CI and a local MySQL for maintainers, with the same bootstrap.

## Consequences

Running the tests needs PHP, Composer and network access to download WordPress once. Database behaviour is not under test, so the SQLite choice costs nothing. The fixture server and bootstrap are the first code written, before any package code, and they are dev dependencies only.

## Confirmation

The first test in the repository sends `wp_remote_request()` to the fixture through the harness and compares the result with itself; it passes on all four CI cells before any package code is merged.

## More information

- [0011 Support WordPress 7.0 and later](0011-support-wordpress-7-0-and-later.md)
- [0012 Require PHP 8.2 or later](0012-require-php-8-2-or-later.md)
- [SQLite Database Integration](https://github.com/WordPress/sqlite-database-integration)
- [PHPUnit Polyfills](https://github.com/Yoast/PHPUnit-Polyfills)
