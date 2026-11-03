# Decision records

Each file in this folder records one decision: the problem, the options considered, the choice and why it beats the others. Records follow [MADR](https://adr.github.io/madr/), adapted to the order the maintainer reviews decisions.

## When to write a record

Write a record for a choice that is hard to reverse, would surprise a reader, or came out of a real trade-off. Do not write one for an obvious choice; state obvious choices in the document they affect.

## Numbering and names

Number records with four digits, in sequence, starting at `0001`. A number belongs to one decision for good: it is never reused, even after the record is deleted.

If two open branches pick the same number, the branch merged second renumbers its record before merging.

Name the file after the decision, not the topic: `0006-stream-downloads-with-wordpress-file-options.md`, not `0006-streaming.md`. Use lowercase ASCII letters, digits and hyphens. Never put a status or a date in the name.

## Status

State the status on the line under the title, as `Status: proposed.` or `Status: accepted.`

- `proposed`: written and waiting for the maintainer.
- `accepted`: approved by the maintainer and in force.

Only the maintainer sets `accepted`. A proposal the maintainer turns down is deleted, or rewritten as the decision that was taken instead.

## Changing a decision

Records describe the decisions in force at the current commit, nothing else. When a decision changes, edit its record in place in the same commit that changes the code or documents it governs: rewrite the context, options and decision so the record reads as if it had always been written that way.

Keep the number when a decision changes. If the new decision no longer matches the file name, rename the file and fix every link to it in the same commit.

Delete a record whose decision no longer applies, and remove the links to it. Do not keep superseded or deprecated records, "previously" notes or change logs inside a record; Git history holds them, and `git log --follow -p -- <record>` shows how a decision evolved.

## Template

```markdown
# Decision stated in sentence case

Status: proposed.

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

Each record states its own status. List the proposals with `grep -l 'Status: proposed' docs/decisions/0*.md`.

- [0001 Send single requests through wp_remote_request()](0001-send-single-requests-through-wp-remote-request.md)
- [0002 Run batches through the WordPress request pipeline](0002-run-batches-through-the-wordpress-request-pipeline.md)
- [0003 Let the site decide unsafe URL rejection](0003-let-the-site-decide-unsafe-url-rejection.md)
- [0004 Inherit transport settings from WordPress](0004-inherit-transport-settings-from-wordpress.md)
- [0005 Key batch results by submission order](0005-key-batch-results-by-submission-order.md)
- [0006 Stream downloads with WordPress file options](0006-stream-downloads-with-wordpress-file-options.md)
- [0007 Decode responses by content type](0007-decode-responses-by-content-type.md)
- [0008 Map responses to objects only](0008-map-responses-to-objects-only.md)
- [0009 Ship retries, logging and caching as opt-in middleware](0009-ship-retries-logging-and-caching-as-opt-in-middleware.md)
- [0010 Use nyholm/psr7, prefixed with Strauss](0010-use-nyholm-psr7-prefixed-with-strauss.md)
- [0011 Support WordPress 7.0 and later](0011-support-wordpress-7-0-and-later.md)
- [0012 Require PHP 8.2 or later](0012-require-php-8-2-or-later.md)
- [0013 Use the TechSpokes\WpHttpClient namespace](0013-use-the-techspokes-wphttpclient-namespace.md)
- [0014 Follow PER Coding Style](0014-follow-per-coding-style.md)
- [0015 Offer no fire-and-forget requests in 1.0](0015-offer-no-fire-and-forget-requests-in-1-0.md)
- [0016 Commit agent skills to the repository](0016-commit-agent-skills-to-the-repository.md)
- [0017 Hold a final client in each plugin or theme](0017-hold-a-final-client-in-each-plugin-or-theme.md)
- [0018 Send batch members at once with an optional cap](0018-send-batch-members-at-once-with-an-optional-cap.md)
- [0019 Cap the time retries may add to a call](0019-cap-the-time-retries-may-add-to-a-call.md)
- [0020 Follow site redirect settings on the PSR-18 path](0020-follow-site-redirect-settings-on-the-psr-18-path.md)
- [0021 Test on real WordPress with a local fixture server](0021-test-on-real-wordpress-with-a-local-fixture-server.md)
