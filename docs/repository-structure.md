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
|-- docs/                        Project documentation, with its own AGENTS.md
|-- src/                         (later) Package code
|-- tests/                       (later) Test code
|-- .editorconfig
|-- .gitattributes               Line endings and the package allow-list
|-- .gitignore
|-- AGENTS.md                    Operating rules for AI assistants and people
|-- CHANGELOG.md                 Release notes
|-- CLAUDE.md                    One line: @AGENTS.md (beside every AGENTS.md)
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
|-- AGENTS.md                       Rules for keeping the documentation current
|-- CLAUDE.md                       One line: @AGENTS.md
|-- README.md                       Map of the documentation and reading order
|-- vision-and-scope.md             Problem, audiences, user stories, scope, phasing
|-- glossary.md                     Project vocabulary
|-- markdown-style.md               How to write Markdown here
|-- repository-structure.md         This document
|-- decisions/
|   |-- README.md                   Rules, template and index of records
|   `-- 0001-....md                 One file per decision
|-- design/                         How the package works
|   |-- README.md                   Actors, promises, components and open questions
|   |-- interactions.md             Scenarios and the needs that become tests
|   |-- architecture.md             Elements, their responsibilities and contracts
|   |-- plan.md                     Gates from the design to 1.0
|   `-- (later) one file per component: client-api.md, transport.md, middleware.md
|-- research/                       Verified facts with sources
|-- guides/                         (later) For plugin and theme authors
`-- agents/                         Configuration read by the agent skills
```

### What each part holds

`vision-and-scope.md` says what the package is for and what is in and out. It changes only with Serge's approval.

`glossary.md` defines the words the project uses. Code, issues and documents use these terms and no synonyms.

`decisions/` records why: one choice per file, with the rejected options. When a decision changes, its record is edited in place under the same number.

`design/` describes how the package works now, kept current in place and linking to the decisions behind it. `README.md` is the overview, `interactions.md` holds the scenarios, `architecture.md` defines the elements and their contracts, `plan.md` holds the gates to 1.0, and each element has one file named after it; `transport.md` describes `src/Transport/`.

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

Names use ASCII letters, digits and hyphens. Do not put dates, versions or status words in names.

### Decision records

The rules for numbering, naming, statuses and sections are in [decisions/README.md](decisions/README.md).

### Current information only

Every file on the current commit is in force and describes the project as it is now. Superseded content is updated, replaced or deleted in place, never kept beside the current version; Git history holds the past. Work that is not approved yet lives on a branch or in a pull request, not on `main`. Decision records carry the only status line, as described in [decisions/README.md](decisions/README.md). Documents have no YAML frontmatter.

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

`AGENTS.md` stays short and links to `docs/` for detail.

### Scoped instructions

A folder whose work needs rules of its own gets an `AGENTS.md` with only those rules, and a `CLAUDE.md` beside it containing the single line `@AGENTS.md`. Codex reads `AGENTS.md` files from the root down to its working folder, and Claude Code reads `CLAUDE.md` files in the folders it works in, so both tools see the same rules.

Scoped files exist today in `docs/`. They are planned for `src/` (code rules: transport boundary, public API and `@internal`) and `tests/` (synthetic fixtures, unit versus integration, parity suite) when those folders are created. `.gitattributes` keeps every `AGENTS.md` and `CLAUDE.md` out of the package.

### Skills

The "Agent skills" section of the root `AGENTS.md` points Matt Pocock's skills to `docs/agents/` and overrides two of their defaults: decisions live in `docs/decisions/`, not `docs/adr/`, and the glossary is `docs/glossary.md`, not a root `GLOSSARY.md`.

His setup skill is not installed, because it writes into `CLAUDE.md`. `bin/install-agent-skills.sh` holds the skill list and the pinned upstream commits and copies the skills into `.agents/skills/` and `.claude/skills/`.

`bin/verify-repository.sh` compares the working skill folders and checks the `HEAD` archive against the runtime allow-list. Local verification and the repository checks workflow share this command; see [CONTRIBUTING.md](../CONTRIBUTING.md#verification) for its use.

## GitHub settings

Repository settings are managed through GitHub, because a commit cannot set them. The branch, merge, Actions and security policy is in [CONTRIBUTING.md](../CONTRIBUTING.md#repository-settings).

The triage and planning labels are listed in [agents/triage-labels.md](agents/triage-labels.md) and [agents/issue-tracker.md](agents/issue-tracker.md). GitHub Sponsors reads `.github/FUNDING.yml`; the wiki and Projects are disabled because documentation and planning use repository files and issues.
