---
status: current
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Markdown rules for all documents in the repository, adopted from the TechSpokes house style.
---

# Markdown style

Humans, AI assistants, parsers and editors all read the Markdown in this repository. Each parses structure differently, so meaning must live in words and in structural syntax, never in visual decoration.

## Principles

Use only Markdown elements that carry structural meaning in the syntax. Bold text that looks like a heading is still emphasized text to every tool that reads it.

If removing bold, a dash, nesting or indentation would change what the text says, rewrite the text. Express relationships with words and punctuation.

## Headings

- Use `#` (ATX) headings only.
- Use exactly one h1 per file, as the title.
- Do not skip levels.
- Never use bold text instead of a heading.

## Lists

- Use lists only for parallel, enumerable items.
- Keep each item to one idea on one line.
- Do not nest lists; promote the nested part to its own heading.
- Do not use the bold-label pattern (`- **Label:** content`); use a heading with prose under it.
- Use `-` for unordered lists and numbers for ordered ones.

## Inline markup and punctuation

- Do not use bold or italic to signal importance; use position and word choice (`must`, `never`, `always`).
- Use backticks for code, file paths, hooks and commands.
- Do not use em dashes or double hyphens as punctuation; use a period, a semicolon or a colon.
- Write prose in ASCII.

## Separators, code and tables

- Allow YAML frontmatter only at the very start of a file.
- Never use horizontal rules in the body; use headings.
- Give every fenced code block a language identifier and keep examples minimal.
- Give every table a header row and keep cells to short phrases; no lists, headings or code blocks in cells.

## Prose

Write paragraphs of one to three sentences, one idea each, with the key information first. Use the imperative mood and active voice for directives. Choose one term per concept and use it everywhere, as defined in [glossary.md](glossary.md).

Use `must` and `must not` for requirements, `should` for strong recommendations, `do not` for prohibitions, `prefer` for defaults and `avoid` for discouraged patterns.

## Frontmatter

Documents in `docs/` and `AGENTS.md` start with YAML frontmatter holding `status`, `updated` and `history`. Decision records use the statuses in [decisions/README.md](decisions/README.md); other documents use `draft`, `review` or `current`. Root community files and `CLAUDE.md` have no frontmatter; `SKILL.md` files keep the frontmatter their format requires.
