---
status: review
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Where the domain documentation lives, for the domain modeling skills.
---

# Domain docs

How the engineering skills find and use this repository's domain documentation. The repository has a single context.

## Before exploring, read these

- `docs/glossary.md`, the project vocabulary. There is no root `GLOSSARY.md`.
- `docs/decisions/`, the decision records that touch the area you are about to work in. There is no `docs/adr/` folder.

## Writing decision records

Skills that record an ADR write a decision record instead, in `docs/decisions/`, following the rules and template in [docs/decisions/README.md](../decisions/README.md). Use the next free four-digit number and a file name stating the decision. New records start with status `proposed`.

## Using the glossary

Name domain concepts in issues, tests, code and proposals with the terms in `docs/glossary.md`, and avoid the synonyms it lists. When a needed concept is missing, either the language is invented (reconsider it) or there is a real gap; add the term once its meaning is settled.

## Flagging conflicts

When your output contradicts an existing decision record, say so explicitly and name the record instead of silently overriding it.
