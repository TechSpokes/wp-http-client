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

Record any choice that is hard to reverse or would surprise a reader as a new file in [docs/decisions/](docs/decisions/README.md), with status `proposed`. The maintainer accepts it or turns it down; a changed decision is edited in place rather than superseded by a new record.

## Branches and commits

Create a branch from `main` named `<type>/<short-description>`, for example `fix/batch-result-order`. Use the types `docs`, `feat`, `fix`, `test` and `chore`.

Write commit subjects in the Conventional Commits format, for example `fix(transport): keep submission order in batch results`. Do not add tool or AI attribution lines such as `Co-Authored-By` to commits or pull requests.

## Pull requests

Open the pull request against `main` and describe the change and verification. Link an issue or decision record when applicable; routine maintenance needs neither a new issue nor a decision record. The maintainer reviews and squash-merges, or explicitly authorizes an assistant to do so.

Use a Conventional Commits PR title as the squash commit subject and write a merge body only when useful. Intermediate commit messages are not copied into the squash commit by default.

## Verification

Use targeted local checks while editing. After committing the complete candidate, run the shared repository check from the repository root before pushing:

```bash
bash bin/verify-repository.sh
```

Use Git Bash on Windows. The check needs Bash, Git, `diff`, `tar` and `mktemp`; it compares the working skill copies and checks the archive of `HEAD` against the runtime allow-list. Commit any further changes and rerun the affected checks before pushing.

The `Repository checks` workflow runs the same command on pull requests to `main` and on manual dispatch. Its `repository` job is the required status check; keep that name stable and let it run for documentation changes too. Superseded runs are canceled, and routine verification is not repeated after merge.

Run PHP syntax checks and relevant tests when package code exists. Transport changes require parity tests against the oldest and newest supported WordPress versions. Choose the PHP and WordPress CI coverage in the testing design before adding jobs; broader manual checks supplement required verification rather than replace it.

## Repository settings

Protect `main` for admins too: require a pull request, the current-base `repository` check from GitHub Actions, and resolved review conversations; block force pushes and deletion. Require zero approving reviews because the maintainer works alone. Allow squash merges and delete merged head branches automatically.

Keep Actions tokens read-only by default, disable workflow PR approvals, and require approval before running workflows from external fork contributors. Use standard GitHub-hosted runners for public CI; run local checks directly with the same repository commands.

Keep private vulnerability reporting, Dependabot alerts and security updates, secret scanning and push protection enabled. CodeQL default setup scans GitHub Actions workflows and has a weekly schedule; it does not analyze PHP. Keep paid Code Quality and AI scanning features disabled; obtain the maintainer's approval before enabling a feature with uncertain costs or changing organization-wide settings.

## Releases

Publish a release only with the maintainer's authorization. Choose an unused version, move the relevant changelog entries from `Unreleased` into a dated version section, and complete verification and review before merging the release PR.

After merge, select the exact merged commit, run the shared check from a clean checkout, and create the version tag there. Verify the tag target and inspect `git archive` output before publishing the GitHub release with curated notes; leave unrelated branch work untouched.

While the package is in design, mark releases as prereleases and state that they contain no runtime implementation or installable Composer package. Link to the tagged repository tree and documentation: source archives follow `.gitattributes` and currently contain only `README.md`, `CHANGELOG.md` and `LICENSE`. No release workflow or extra downloadable artifact is needed at this stage.

## Changelog

Add a line under `## [Unreleased]` in `CHANGELOG.md` for every user-visible change, in the matching Keep a Changelog section (`Added`, `Changed`, `Fixed`, `Removed`). Write each entry as one line with a Conventional Commits prefix; do not list files or use vague phrasing.

## Documentation

Write documentation in Markdown following [docs/markdown-style.md](docs/markdown-style.md). Put each file where [docs/repository-structure.md](docs/repository-structure.md) says it belongs, and follow [docs/AGENTS.md](docs/AGENTS.md). Keep only current information: update or delete outdated text in place and leave the past to Git history.

## Development setup

There is no package code yet. Once it exists, it needs Composer and PHP 8.2 or later (the floor proposed in decision 0012), and the setup steps will be listed here.

The agent skills in `.agents/skills/` and `.claude/skills/` are third-party copies. Update them only with `bin/install-agent-skills.sh`, which needs Node.js 22.20 or later.

## Code of Conduct

Everyone taking part follows the [Code of Conduct](CODE_OF_CONDUCT.md).
