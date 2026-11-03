---
status: current
updated: 2026-11-03
history:
  - date: 2026-11-03
    summary: Repository layout, naming conventions and the migration of the first documents, approved by Serge.
---

# Repository structure and naming conventions

Where every kind of file lives, how it is named, and what ships in the Composer package. When a new kind of file appears, add it here first.

## Principles

Only runtime code ships. The package contains `src/`, `composer.json`, `LICENSE`, `README.md` and `CHANGELOG.md`; an allow-list in `.gitattributes` excludes everything else, so new development files stay out by default.

Each kind of knowledge has one home: scope, vocabulary, decisions, design, research and user guides. A fact is written once and linked from elsewhere.

Names say what is inside. The path alone tells a reader what a file contains.

Published conventions come first: [pds/skeleton](https://github.com/php-pds/skeleton) for root folders and files, PSR-4 for PHP, [MADR](https://adr.github.io/madr/) for decision records, Keep a Changelog for `CHANGELOG.md`, and the community file names GitHub recognizes.

## Repository tree

Items marked later are created when the work that needs them starts. Empty placeholder folders are never committed.

```text
wp-http-client/
|-- .agents/skills/              Agent skills (Codex and most agents)
|-- .claude/skills/              Same skills, copied for Claude Code
|-- .github/
|   |-- ISSUE_TEMPLATE/          Issue forms: bug report, feature request, question
|   |-- workflows/               CI: repository checks now, PHP checks later
|   |-- CODEOWNERS
|   |-- FUNDING.yml              GitHub Sponsors for TechSpokes
|   |-- PULL_REQUEST_TEMPLATE.md
|   `-- dependabot.yml
|-- bin/                         Maintenance scripts (Bash)
|-- docs/                        Project documentation
|-- src/                         (later) Package code
|-- tests/                       (later) Test code
|-- .editorconfig
|-- .gitattributes               Line endings and the package allow-list
|-- .gitignore
|-- AGENTS.md                    Operating rules for AI assistants and people
|-- CHANGELOG.md                 Release notes
|-- CLAUDE.md                    One line: @AGENTS.md
|-- CODE_OF_CONDUCT.md           Contributor Covenant 2.1
|-- CONTRIBUTING.md              How work is proposed, reviewed and merged
|-- LICENSE                      GPL-3.0
|-- README.md                    What the package is, status, requirements
|-- SECURITY.md                  How to report vulnerabilities privately
|-- SUPPORT.md                   Where to ask questions and report bugs
|-- THIRD-PARTY-NOTICES.md       Sources and licenses of the agent skills
|-- composer.json                (later)
|-- phpstan.neon.dist            (later)
|-- phpunit.xml.dist             (later)
`-- skills-lock.json             Installed skills, pinned commits and hashes
```

Tool configuration stays at the root, where the tools look for it. Committed configuration uses the `.dist` suffix so a developer can override it with an ignored local copy.

## Documentation

```text
docs/
|-- README.md                       Map of the documentation and reading order
|-- vision-and-scope.md             Problem, audiences, user stories, scope, phasing
|-- glossary.md                     Project vocabulary
|-- markdown-style.md               How to write Markdown here
|-- repository-structure.md         This document
|-- decisions/
|   |-- README.md                   Rules, template and index of records
|   `-- 0001-....md                 One file per decision
|-- design/                         (later) How the package works
|   |-- README.md                   Architecture overview
|   `-- one file per component: transport.md, client-api.md, middleware.md
|-- research/                       Verified facts with sources
|-- guides/                         (later) For plugin and theme authors
`-- agents/                         Configuration read by the agent skills
```

### What each part holds

`vision-and-scope.md` says what the package is for and what is in and out. It changes only with Serge's approval.

`glossary.md` defines the words the project uses. Code, issues and documents use these terms and no synonyms.

`decisions/` records why: one choice per file, with the rejected options. A changed mind is a new record that supersedes the old one, never an edit.

`design/` describes how the package works now, kept current in place and linking to the decisions behind it. Each component has one file named after it; `transport.md` describes `src/Transport/`.

`research/` holds verified facts with their sources and the WordPress and Requests versions checked. Design and decisions cite them instead of repeating them.

`guides/` is for the package's users, written once the public API exists.

`agents/` holds the configuration Matt Pocock's skills read through the "Agent skills" section of `AGENTS.md`.

### Reading order

Read `AGENTS.md`, `docs/README.md`, `vision-and-scope.md` and `glossary.md`, then the accepted decisions and the design file for the area being changed.

## Naming conventions

| Kind | Convention | Example |
| --- | --- | --- |
| Folders outside `src/` and `tests/` | lowercase, hyphens | `docs/research/` |
| Documents | lowercase, hyphens, subject as a noun phrase | `wordpress-http-request-pipeline.md` |
| Folder index | `README.md` | `docs/decisions/README.md` |
| Root and GitHub community files | the names GitHub recognizes | `SECURITY.md` |
| Issue forms | lowercase, hyphens | `bug-report.yml` |
| Decision records | `NNNN-` and the decision as a statement | `0003-let-the-site-decide-unsafe-url-rejection.md` |
| Scripts | verb-object | `bin/install-agent-skills.sh` |
| GitHub workflows | what they check | `repository-checks.yml` |
| PHP source | PSR-4, one class per file named after it | `src/Transport/WordPressTransport.php` |
| PHP tests | mirror the source path, `Test` suffix | `tests/Unit/Transport/WordPressTransportTest.php` |

Names use ASCII letters, digits and hyphens. Do not put dates, versions or status words in names; they go in frontmatter.

### Decision records

The rules for numbering, naming, statuses and sections are in [decisions/README.md](decisions/README.md).

### Document status

Documents other than decision records use `draft`, `review` (waiting for Serge) or `current` (approved and true). They are updated in place; Git keeps history.

### Branches and commits

Branches are named `<type>/<short-description>` with the Conventional Commits types `docs`, `feat`, `fix`, `test` and `chore`.

## Code and tests

- `src/` is the PSR-4 root of `TechSpokes\WpHttpClient\`, as proposed in decision 0013.
- The design sets the folders inside `src/`.
- `tests/Unit/` runs under plain PHPUnit, without WordPress.
- `tests/Integration/` runs inside WordPress; the batch parity suite is `tests/Integration/Parity/`.
- `tests/Fixtures/` holds synthetic data only.
- `docs/design/testing.md` chooses the integration test harness.
- `composer.lock` is not committed, so the library is tested against the newest dependencies it allows.

## Agent configuration

`AGENTS.md` stays short and links to `docs/` for detail. Its "Agent skills" section points Matt Pocock's skills to `docs/agents/` and overrides two of their defaults: decisions live in `docs/decisions/`, not `docs/adr/`, and the glossary is `docs/glossary.md`, not a root `GLOSSARY.md`.

His setup skill is not installed, because it writes into `CLAUDE.md`. `bin/install-agent-skills.sh` holds the skill list and the pinned upstream commits and copies the skills into `.agents/skills/` and `.claude/skills/`.

The repository checks workflow fails when the two skill folders differ or when a package archive contains anything outside the allow-list.

## Migration of the first documents

| Earlier document | Now |
| --- | --- |
| `scope-and-user-stories.md`, vision, stories, scope | `vision-and-scope.md` |
| `scope-and-user-stories.md`, developer problems | `research/developer-pain-points.md` |
| `scope-and-user-stories.md`, what WordPress offers | `research/existing-solutions.md` |
| `scope-and-user-stories.md`, open questions | answered by decision records |
| `decisions.md`, what it should feel like | `vision-and-scope.md` |
| `decisions.md`, D1 to D10 | `decisions/0001` to `0010` |
| `decisions.md`, D11 | `decisions/0011` and `0012` |
| `decisions.md`, O1 | `decisions/0015` |
| Handoff, earlier TechSpokes clients | `research/existing-solutions.md`, lessons only |
| Handoff, verified WordPress facts | `research/wordpress-http-request-pipeline.md` |
| Batch-mode findings | `research/requests-batch-mode-gaps.md` |

## GitHub settings

Serge sets these once in the repository settings, because a commit cannot:

- Protect `main` and require pull requests.
- Enable private vulnerability reporting.
- Create the triage labels `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human` and `wontfix`.
- Create the planning labels `wayfinder:map`, `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling` and `wayfinder:task`.
- Enable GitHub Sponsors display, which reads `.github/FUNDING.yml`.
