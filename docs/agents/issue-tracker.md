# Issue tracker: GitHub

Issues and specs for this repository live in GitHub Issues for `TechSpokes/wp-http-client`. Use the `gh` CLI for every operation; it infers the repository from `git remote -v` inside a clone.

File issues only in `TechSpokes/wp-http-client`. Never file in the repositories the skills come from.

## Create, read and list

- Create: `gh issue create --title "..." --body "..."`, with a heredoc for multi-line bodies.
- Read: `gh issue view <number> --json number,title,body,labels,comments`.
- List: `gh issue list --state open --json number,title,labels` with `--label` filters as needed.
- Comment: `gh issue comment <number> --body "..."`.
- Label: `gh issue edit <number> --add-label "..."` or `--remove-label "..."`.
- Close: comment with the reason first, then `gh issue close <number>`.

## Parents and blocking

These commands need `gh` 2.94 or later; with an older `gh`, use the text fallbacks.

Make an issue a sub-issue with `gh issue create --parent <parent>` or `gh issue edit <parent> --add-sub-issue <child>`. Without sub-issue support, put `Part of #<parent>` at the top of the child body.

Record blocking with GitHub issue dependencies: `gh issue edit <child> --add-blocked-by <blocker>`. Without dependency support, put `Blocked by: #<n>` at the top of the child body. An issue is ready when every blocker is closed.

## Pull requests as a triage surface

PRs as a request surface: no. External pull requests are reviewed as pull requests, not triaged as feature requests.

## Skill vocabulary

When a skill says "publish to the issue tracker", create a GitHub issue. When it says "fetch the relevant ticket", read the issue as above.

For the wayfinder skill, the map is one issue labelled `wayfinder:map`; its tickets are sub-issues labelled `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling` or `wayfinder:task`. Claim a ticket with `gh issue edit <n> --add-assignee @me` and resolve it with a comment, then close it.
