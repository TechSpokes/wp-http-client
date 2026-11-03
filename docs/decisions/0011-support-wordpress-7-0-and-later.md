---
status: accepted
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Accepted by Serge in conversation. Supersedes the WordPress 6.2 floor proposed in D11 of docs/decisions.md.
---

# Support WordPress 7.0 and later

## Context and problem

The package needs a WordPress floor for its compatibility promise and its CI matrix. The latest release on 2026-11-03 is 7.1.4. D11 had proposed 6.2, the first release with the `WpOrg\Requests` namespace.

## Options considered

### WordPress 6.2

The widest reach, but parity tests must cover several Requests versions and older core behaviour.

### WordPress 7.0

The release that updated the bundled Requests library to 2.0.17 (Trac #64752), and the target of the official WordPress agent skills.

## Decision

Support WordPress 7.0 and later. It narrows the parity matrix to one modern Requests line and matches the guidance the agent skills give.

## Consequences

Sites on WordPress 6.x cannot use the package. Parity tests run against 7.0 and the newest release.

## Confirmation

The CI matrix runs the integration and parity suites on WordPress 7.0 and the newest release.

## More information

- [0012 Require PHP 8.2 or later](0012-require-php-8-2-or-later.md)
- [Trac #64752: update Requests to 2.0.17](https://core.trac.wordpress.org/ticket/64752)
- [WordPress/agent-skills compatibility policy](https://github.com/WordPress/agent-skills/blob/trunk/docs/compatibility-policy.md)
