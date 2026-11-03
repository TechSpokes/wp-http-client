---
status: current
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Rules, template and index for decision records.
---

# Decision records

Each file in this folder records one decision: the problem, the options considered, the choice and why it beats the others. Records follow [MADR](https://adr.github.io/madr/), adapted to the order the maintainer reviews decisions.

## When to write a record

Write a record for a choice that is hard to reverse, would surprise a reader, or came out of a real trade-off. Do not write one for an obvious choice; state obvious choices in the document they affect.

## Numbering and names

Number records with four digits, in sequence, starting at `0001`. Assign the number when the record is created and never reuse or change it after merge.

If two open branches pick the same number, the branch merged second renumbers its record before merging.

Name the file after the decision, not the topic: `0006-stream-downloads-with-wordpress-file-options.md`, not `0006-streaming.md`. Use lowercase ASCII letters, digits and hyphens.

## Status

Keep the status in frontmatter. Use one of these values:

- `proposed`: written and waiting for the maintainer.
- `accepted`: approved by the maintainer and in force.
- `rejected`: considered and turned down by the maintainer.
- `deprecated`: no longer in force, with nothing replacing it.
- `superseded by NNNN`: replaced by the named record.

Only the maintainer sets `accepted`, `rejected` or `deprecated`. Never edit an accepted record to mean something else; write a new record that supersedes it and update the old record's status.

## Template

```markdown
---
status: proposed
updated: YYYY-MM-DD
history:
  - date: YYYY-MM-DD
    summary: Proposed.
---

# Decision stated in sentence case

## Context and problem

What forces the decision, in one to three short paragraphs.

## Options considered

### First option

What it means, its impact and its blast radius.

### Second option

What it means, its impact and its blast radius.

## Decision

The chosen option and why it beats the others.

## Consequences

What becomes easier, what becomes harder, and what must follow.

## Confirmation

How the decision is verified: tests, CI checks or review.

## More information

Links to related records, research notes and sources.
```

## Index

| Record | Status |
| --- | --- |
| [0001 Send single requests through wp_remote_request()](0001-send-single-requests-through-wp-remote-request.md) | proposed |
| [0002 Run batches through the WordPress request pipeline](0002-run-batches-through-the-wordpress-request-pipeline.md) | proposed |
| [0003 Let the site decide unsafe URL rejection](0003-let-the-site-decide-unsafe-url-rejection.md) | proposed |
| [0004 Inherit transport settings from WordPress](0004-inherit-transport-settings-from-wordpress.md) | proposed |
| [0005 Key batch results by submission order](0005-key-batch-results-by-submission-order.md) | proposed |
| [0006 Stream downloads with WordPress file options](0006-stream-downloads-with-wordpress-file-options.md) | proposed |
| [0007 Decode responses by content type](0007-decode-responses-by-content-type.md) | proposed |
| [0008 Map responses to objects only](0008-map-responses-to-objects-only.md) | proposed |
| [0009 Ship retries, logging, caching and host rules as opt-in middleware](0009-ship-retries-logging-caching-and-host-rules-as-opt-in-middleware.md) | proposed |
| [0010 Use nyholm/psr7, prefixed with Strauss](0010-use-nyholm-psr7-prefixed-with-strauss.md) | proposed |
| [0011 Support WordPress 7.0 and later](0011-support-wordpress-7-0-and-later.md) | accepted |
| [0012 Require PHP 8.2 or later](0012-require-php-8-2-or-later.md) | proposed |
| [0013 Use the TechSpokes\WpHttpClient namespace](0013-use-the-techspokes-wphttpclient-namespace.md) | proposed |
| [0014 Follow PER Coding Style](0014-follow-per-coding-style.md) | proposed |
| [0015 Offer no fire-and-forget requests in 1.0](0015-offer-no-fire-and-forget-requests-in-1-0.md) | proposed |
| [0016 Commit agent skills to the repository](0016-commit-agent-skills-to-the-repository.md) | accepted |
