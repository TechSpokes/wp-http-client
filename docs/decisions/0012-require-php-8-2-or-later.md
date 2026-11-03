# Require PHP 8.2 or later

Status: proposed.

## Context and problem

WordPress 7.0 supports PHP 7.4 and later and recommends 8.3. The package needs a floor that gives it modern language features without excluding most sites.

On WordPress.org's figures from January 2026, PHP 8.2 and newer ran on about 49% of sites, 8.3 and newer on about 22%, and 7.4 on 22.2%. Among WooCommerce stores sampled by Metorik in March 2026, about 67% ran 8.2 or newer.

PHP 8.2 security support ends on 2026-12-31.

## Options considered

### PHP 8.1

Adds about 15% of WordPress sites, but 8.1 is already out of security support, and the package would lose readonly classes and standalone `true`, `false` and `null` types.

### PHP 8.2

Readonly classes and standalone `true`, `false` and `null` types suit value objects and the hydrator. About half of WordPress sites qualify today.

### PHP 8.3

Typed class constants and `json_validate()`, but only about a fifth of WordPress sites qualify.

## Decision

Require PHP 8.2 or later. It balances reach and language features better than the other options; 8.3 would exclude most sites for features the package can live without.

## Consequences

The floor is reviewed once a year and raised when the share of sites on the next version allows. The CI matrix covers 8.2 through the newest PHP release.

## Confirmation

`composer.json` declares the constraint, and CI runs the test suites on PHP 8.2 and the newest release.

## More information

- [0011 Support WordPress 7.0 and later](0011-support-wordpress-7-0-and-later.md)
- [Dropping support for PHP 7.2 and 7.3](https://make.wordpress.org/core/2026/01/09/dropping-support-for-php-7-2-and-7-3/)
- [PHP supported versions](https://www.php.net/supported-versions.php)
- [Metorik: WooCommerce PHP version statistics](https://metorik.com/blog/woocommerce-php-version-statistics)
