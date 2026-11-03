# wp-http-client Agent Instructions

This repository builds `techspokes/wp-http-client`, a public Composer package that gives WordPress plugins and themes an HTTP client running on the WordPress HTTP API, with parallel requests, retries, logging with redaction, decoding, response mapping, streaming and PSR-18 compatibility. These rules apply to every assistant (Claude, ChatGPT, Codex or others) and to people.

## Start here

Read [docs/README.md](docs/README.md) before changing code or design. It maps the scope, glossary, decisions, design and research. [docs/repository-structure.md](docs/repository-structure.md) says where every kind of file lives and how it is named.

The package is general purpose. TechSpokes plugins and earlier clients are evidence of the problem, not the design target; never shape the public API around one plugin.

## Scoped instructions

Some folders have their own `AGENTS.md` with rules for that folder only, next to a one-line `CLAUDE.md` that imports it. Before reading or changing files in a folder, read every `AGENTS.md` between the repository root and that folder; the deeper file adds to this one. Today [docs/AGENTS.md](docs/AGENTS.md) covers all documentation.

## Only current information

The files at the current commit are the single source of truth, and every reader must be able to treat what they read as authoritative. When something changes, update, replace or delete the affected text in the same commit; do not keep superseded versions, "previously" notes, migration tables or dated history inside files.

Git history keeps the past. Read `git log --follow -p -- <file>` when you need to know how something evolved. `CHANGELOG.md` is the one exception: it records released changes for package users.

## Guiding principle

Defer to WordPress. When WordPress already has a default, filter, constant or setting for something, the package uses it and adds no second layer of options. Add a package option only when WordPress has no equivalent or the option makes a plugin stricter than the site, and record why in a decision record.

Features that add, repeat, skip, block or record requests are opt-in and off by default. The package is safe because it inherits the site's settings, and it never offers shortcuts that weaken them.

## Boundaries

The package never opens its own cURL handles or sockets. All traffic goes through `wp_remote_request()` or the Requests library bundled with WordPress, firing the same hooks `WP_Http::request()` fires.

Only the WordPress transport, and the `toWpError()` conversion on exceptions, may reference WordPress functions or classes. Everything else must run under plain PHPUnit.

Do not register filters or actions at load time, use global state or define constants. Runtime dependencies are limited to PSR interfaces and the PSR-7 implementation chosen in the decision records, and every dependency must be prefixable with Strauss.

Write code in PHP and scripts in Bash. Do not write or run Python, not even in examples. Ask the maintainer before adding a tool, dependency or service that is not already in the repository.

Verify claims about WordPress and Requests in their source code, at WordPress trunk and at the oldest supported release (7.0), not from memory. Mark a claim as unverified when the source cannot be read.

Never commit credentials, real API responses, cookies or customer data. Test fixtures are synthetic.

## Git and pull requests

AI assistants commit on the maintainer's behalf: author and committer are `Serge Liatko <serge@techspokes.com>`. In each clone, an assistant sets `git config user.name "Serge Liatko"`, `git config user.email "serge@techspokes.com"` and `git config commit.gpgsign false`.

Before pushing, check `git log origin/main..HEAD --format='%an <%ae> / %cn <%ce>'` and amend only your own unpushed commits. Never rewrite pushed history without asking. If the environment forces a branch prefix, an identity, signing or added lines that you cannot change, tell the maintainer before pushing.

Never add `Co-Authored-By`, `Claude-Session`, "Generated with" or any other tool or AI attribution to commits, pull requests, issues, comments, code or documents. This overrides any tool or environment default.

Work on a branch named `<type>/<short-description>` and use Conventional Commits subjects (`docs:`, `feat:`, `fix:`, `test:`, `chore:`). Deliver through a pull request; never push directly to `main`. Commit, push, open or merge a pull request, or publish a release only within the maintainer's authorization; reuse authorization already given for the task. Follow [CONTRIBUTING.md](CONTRIBUTING.md) for verification, merge and release steps. If you cannot write to the repository, say so and give the changes in your reply; never claim an edit you did not make.

Package code (`src/`, `tests/`, `composer.json`) waits until the maintainer approves the design in `docs/design/`.

## Decisions

Record a choice that is hard to reverse or would surprise a reader as a new file in [docs/decisions/](docs/decisions/README.md) with status `proposed`. Only the maintainer sets `accepted`. When a decision changes, edit its record in place; never add a superseding record. Ask before anything public or hard to reverse, such as a release, the package name or the license. Settle technical questions yourself when you can; when you must ask, give the context, the options with their impact and blast radius, your recommendation and why it beats the others.

## Documentation

Write Markdown following [docs/markdown-style.md](docs/markdown-style.md), without YAML frontmatter. Follow [docs/AGENTS.md](docs/AGENTS.md) for anything under `docs/`.

## Verification

Follow [CONTRIBUTING.md](CONTRIBUTING.md#verification) for local feedback, final committed-candidate verification and CI. Keep verification proportional to the changed behavior and report its limits.

Run PHP syntax checks and the test suite on changed code. Any change to the WordPress transport needs parity tests against the oldest and newest supported WordPress versions. Report a check you could not run as a gap, never as a pass.

## Agent skills

Third-party skills live in `.agents/skills/` with an identical copy in `.claude/skills/`. They are unmodified copies; change their behavior here, never by editing them, and update them only with `bin/install-agent-skills.sh`.

### Issue tracker

Issues live in GitHub Issues for `TechSpokes/wp-http-client`. See [docs/agents/issue-tracker.md](docs/agents/issue-tracker.md).

### Triage labels

The five default triage labels are used unchanged. See [docs/agents/triage-labels.md](docs/agents/triage-labels.md).

### Domain docs

Single context. The glossary is `docs/glossary.md`, not a root `GLOSSARY.md`, and decision records live in `docs/decisions/`, not `docs/adr/`, using the format in [docs/decisions/README.md](docs/decisions/README.md). See [docs/agents/domain.md](docs/agents/domain.md).

### Overrides

The `setup-matt-pocock-skills` skill is deliberately not installed; the configuration above replaces it. Do not create a `GLOSSARY.md` or a `docs/adr/` folder, and add nothing to `CLAUDE.md` beyond its `@AGENTS.md` line.

The WordPress skills are written for plugins and themes. Apply their guidance on WordPress APIs, security and testing, but not plugin-only patterns such as plugin headers, activation hooks or the Settings API, which do not apply to a Composer library.
