# Follow PER Coding Style

Status: proposed.

## Context and problem

The package needs one coding standard that every contributor and assistant follows and CI enforces. It implements PSR interfaces, whose method names are camelCase, such as `sendRequest()`.

## Options considered

### WordPress Coding Standards

Familiar to plugin authors, but it requires snake_case methods and would flag the method names the PSR interfaces require.

### PSR-12

Compatible with PSR interfaces, but superseded by PER Coding Style and no longer updated for new PHP syntax.

### PER Coding Style 3.1

The PHP-FIG successor to PSR-12, maintained for current PHP syntax, compatible with PSR interfaces.

## Decision

Follow PER Coding Style 3.1. It is the only option that is both current and compatible with the interfaces the package implements.

## Consequences

Code uses four-space indentation and camelCase methods. The tool that enforces the standard is chosen with the first code.

## Confirmation

CI runs the coding-standard check on every pull request.

## More information

- [0013 Use the TechSpokes\WpHttpClient namespace](0013-use-the-techspokes-wphttpclient-namespace.md)
- [PER Coding Style](https://github.com/php-fig/per-coding-style)
