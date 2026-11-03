# Documentation Agent Instructions

These rules apply to every file under `docs/`. They add to the root [AGENTS.md](../AGENTS.md); they do not replace it.

## Only current information

Everything under `docs/` describes the project as it is at the current commit, and an agent reading it must be able to treat it as authoritative. When something changes, update, replace or delete the affected text in the same commit that makes it obsolete.

Do not keep superseded versions, "previously" or "was" notes, migration tables, per-file change logs or dated history entries. Git history holds the past; use `git log --follow -p -- <file>` when you need to know how something evolved.

Do not put status, dates or versions in file names.

## Frontmatter

Do not add YAML frontmatter to documents. The only state a document carries is the status line of a decision record; everything else on the current commit is in force.

## Where things go

Put each document where [repository-structure.md](repository-structure.md) says it belongs, and add a new kind of document there before creating it. Write Markdown following [markdown-style.md](markdown-style.md).

## Decision records

Create, change, rename and delete records as [decisions/README.md](decisions/README.md) describes. A changed decision is edited in place under its number; it never gets a superseding record. Update the index in that README in the same commit.

## Research notes

A research note states facts as they are now, with the sources and versions it was checked against. When a fact changes, for example after a WordPress or Requests release, rewrite the note and its "Sources checked" section; do not append the new state below the old one.

When a research fact changes, check the decisions and design documents that cite it and update them in the same commit.

## Links and references

Fix every link to a renamed or deleted file in the same commit. Refer to decision records by number and title, and to research notes by file name.

## Glossary

Add a term to [glossary.md](glossary.md) once its meaning is settled, and use it everywhere. When a term is renamed, rename it across the repository in the same commit.
