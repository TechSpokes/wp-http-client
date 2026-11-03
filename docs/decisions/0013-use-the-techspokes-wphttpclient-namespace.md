---
status: proposed
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Proposed. Replaces the TechSpokes\WPHttpClient namespace proposed in the handoff.
---

# Use the TechSpokes\WpHttpClient namespace

## Context and problem

The Composer package is `techspokes/wp-http-client`. Its PHP namespace becomes part of the public API from the first release and is expensive to change afterwards.

## Options considered

### TechSpokes\WPHttpClient

Keeps the acronym uppercase like WordPress's `WP_` prefix, but mixes styles: `WP` is uppercase while `Http` is not.

### TechSpokes\WpHttpClient

Treats acronyms as words, the way the bundled Requests library names its own root (`WpOrg\Requests`) and Symfony writes `HttpClient`.

### TechSpokes\WordPressHttpClient

Avoids the acronym, but is longer and no longer matches the package name.

## Decision

Use `TechSpokes\WpHttpClient`. It applies one consistent rule to both acronyms and follows the library the package wraps.

## Consequences

Class names inside the package treat acronyms as words too, for example `HttpException`, not `HTTPException`.

## Confirmation

`composer.json` maps the namespace to `src/` with PSR-4, and the coding-standard check flags acronym casing that breaks the rule.

## More information

- [0014 Follow PER Coding Style](0014-follow-per-coding-style.md)
