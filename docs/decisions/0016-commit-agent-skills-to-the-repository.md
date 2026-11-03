---
status: accepted
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Accepted by Serge in conversation.
---

# Commit agent skills to the repository

## Context and problem

The package is developed by several AI assistants, including Claude, ChatGPT and Codex. They work better with the official WordPress agent skills and Matt Pocock's engineering skills. Codex reads `.agents/skills/`, and Claude Code reads `.claude/skills/`.

Cloud sessions of any assistant see only the repository, not skills installed on a developer's machine.

## Options considered

### Per-developer global install

Nothing is committed, but cloud sessions get no skills, and each developer may run different versions.

### Tool plugins or marketplaces

Updates are automatic but differ per tool, cannot be pinned the same way across tools, and do not reach cloud sessions.

### Committed copies in both folders

Every tool and every session reads the same pinned files. The repository carries the copies.

### One committed copy with symlinks for Claude Code

Halves the size, but some tools and checkouts handle symlinks differently, and plain files are the most predictable choice.

## Decision

Commit unmodified copies of the skills to `.agents/skills/` and `.claude/skills/`. `bin/install-agent-skills.sh` installs them from pinned upstream commits and records them in `skills-lock.json`. This is the only option where every assistant, local or cloud, reads the same files.

`.gitattributes` excludes the skills from the Composer package. Project-specific overrides live in `AGENTS.md`, never in the skill files.

## Consequences

Updates are deliberate: change a pinned commit, run the script, review the diff in a pull request. `THIRD-PARTY-NOTICES.md` carries the upstream licenses.

## Confirmation

CI checks that `.agents/skills/` and `.claude/skills/` are identical and that the package archive contains only runtime files.

## More information

- [WordPress/agent-skills](https://github.com/WordPress/agent-skills)
- [mattpocock/skills](https://github.com/mattpocock/skills)
- [vercel-labs/skills installer](https://github.com/vercel-labs/skills)
