# Contributing to wp-http-client

Thank you for helping. This guide covers how work is proposed, reviewed and merged. The package is in design, so most contributions today are to the documentation and the decision records.

## Before you start

Read [AGENTS.md](AGENTS.md) for the operating rules, then [docs/README.md](docs/README.md) for the problem, scope and decisions. The rules in `AGENTS.md` apply to people and AI assistants alike.

Search existing [issues](https://github.com/TechSpokes/wp-http-client/issues) before opening a new one. For larger changes, open an issue first so the approach can be agreed before work starts.

## Guiding principle

The package defers to WordPress. When WordPress already has a default, filter, constant or setting for something, the package uses it and adds no option of its own. A package option is added only when WordPress has no equivalent or the option makes a plugin stricter than the site, and the proposal must explain which.

## Reporting issues

Use the issue forms for bugs, feature requests and questions. Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md), never in a public issue.

## Proposing a decision

Record any choice that is hard to reverse or would surprise a reader as a new file in [docs/decisions/](docs/decisions/README.md), with status `proposed`. The maintainer accepts or rejects it.

## Branches and commits

Create a branch from `main` named `<type>/<short-description>`, for example `fix/batch-result-order`. Use the types `docs`, `feat`, `fix`, `test` and `chore`.

Write commit subjects in the Conventional Commits format, for example `fix(transport): keep submission order in batch results`. Do not add tool or AI attribution lines such as `Co-Authored-By` to commits or pull requests.

## Pull requests

Open the pull request against `main` and fill in the template. Link the issue and the decision record the change follows, and describe the checks you ran. The maintainer reviews and merges.

## Changelog

Add a line under `## [Unreleased]` in `CHANGELOG.md` for every user-visible change, in the matching Keep a Changelog section (`Added`, `Changed`, `Fixed`, `Removed`). Write each entry as one line with a Conventional Commits prefix; do not list files or use vague phrasing.

## Documentation

Write documentation in Markdown following [docs/markdown-style.md](docs/markdown-style.md). Put each file where [docs/repository-structure.md](docs/repository-structure.md) says it belongs.

## Development setup

There is no package code yet. Once it exists, it needs Composer and PHP 8.2 or later (the floor proposed in decision 0012), and the setup steps will be listed here.

The agent skills in `.agents/skills/` and `.claude/skills/` are third-party copies. Update them only with `bin/install-agent-skills.sh`, which needs Node.js 22.20 or later.

## Code of Conduct

Everyone taking part follows the [Code of Conduct](CODE_OF_CONDUCT.md).
