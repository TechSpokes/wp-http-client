---
status: proposed
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Migrated from D8 in docs/decisions.md.
---

# Map responses to objects only

## Context and problem

Every API client ends up hand-mapping decoded arrays to model objects. General PHP hydrators exist but are too heavy to bundle in a plugin or pull in dependencies that collide with other plugins. The open question was whether the package should also map objects back to request bodies.

## Options considered

### Map in both directions

This covers request bodies too, but doubles the hydrator's surface for a need no consumer has shown yet.

### Map responses to objects only, and build request bodies from arrays and JsonSerializable

The hydrator stays small, and request bodies use what PHP already offers.

## Decision

Map responses to objects only. The hydrator handles constructor promotion, scalars, enums, `DateTimeImmutable`, nested objects, lists of objects, attribute-based key renaming and a `fromArray()` escape hatch.

Request bodies use arrays and PHP's own `JsonSerializable`, the WordPress-native default. This keeps the hydrator small enough to bundle, and the decision is revisited if real consumers need the reverse direction.

## Consequences

An endpoint declares the class it expects and the package returns that class or throws a `MappingException` naming the path that failed. Plugins that need object-to-body mapping implement `JsonSerializable`.

## Confirmation

Unit tests cover every supported type, key renaming, nested and list mapping, and failure paths.

## More information

- [Developer pain points](../research/developer-pain-points.md)
