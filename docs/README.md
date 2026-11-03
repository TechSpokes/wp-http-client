# Documentation

This folder holds everything the project knows about itself. Read the documents in the order below; each one links to the next level of detail.

## Reading order

1. [vision-and-scope.md](vision-and-scope.md): what the package is for, who it serves, what is in and out of scope.
2. [glossary.md](glossary.md): the terms used in code, issues and documents.
3. [decisions/README.md](decisions/README.md): every design decision, why it was made and its status.
4. [design/README.md](design/README.md): who the package serves and how it is built, followed by [design/interactions.md](design/interactions.md), [design/architecture.md](design/architecture.md), [design/plan.md](design/plan.md) and one file per element. The design is reviewed before any code.

## Reference

- [research/](#research): verified facts the decisions and design rely on.
- [repository-structure.md](repository-structure.md): where every kind of file lives and how it is named.
- [markdown-style.md](markdown-style.md): how to write Markdown in this repository.
- [AGENTS.md](AGENTS.md): rules for keeping the documentation current.
- [agents/](#agent-configuration): configuration read by the agent skills.

## Research

| Note | Subject |
| --- | --- |
| [wordpress-http-request-pipeline.md](research/wordpress-http-request-pipeline.md) | What `WP_Http::request()` does, step by step |
| [requests-batch-mode-gaps.md](research/requests-batch-mode-gaps.md) | Where batched requests differ from single ones |
| [developer-pain-points.md](research/developer-pain-points.md) | Problems developers report with outbound HTTP |
| [existing-solutions.md](research/existing-solutions.md) | What WordPress and other packages offer today |

## Agent configuration

| File | Purpose |
| --- | --- |
| [issue-tracker.md](agents/issue-tracker.md) | Where issues live and how agents work with them |
| [triage-labels.md](agents/triage-labels.md) | Label vocabulary for issue triage |
| [domain.md](agents/domain.md) | Where the glossary and decision records live |

The rules for assistants are in [AGENTS.md](../AGENTS.md).
