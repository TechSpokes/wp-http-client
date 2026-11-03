# Issue tracker: GitHub

Issues and specs for this repository live in GitHub Issues for `TechSpokes/wp-http-client`. File issues only there, never in the repositories the skills come from.

## Use the REST API

Run every operation as a REST call with `gh api`, from inside a clone. Commands such as `gh issue create` and `gh issue list` use GitHub's GraphQL API, which some agent environments block; the REST calls below work everywhere. `gh api` replaces `{owner}/{repo}` with the current repository.

## Create, read and list

- Create: `gh api 'repos/{owner}/{repo}/issues' -f title='...' -f body='...' -f 'labels[]=needs-triage'`.
- Read: `gh api 'repos/{owner}/{repo}/issues/<n>'`, and its comments with `gh api 'repos/{owner}/{repo}/issues/<n>/comments'`.
- List: `gh api 'repos/{owner}/{repo}/issues?state=open&labels=<label>' --jq '.[] | select(.pull_request | not) | {number, title}'`.
- Comment: `gh api 'repos/{owner}/{repo}/issues/<n>/comments' -f body='...'`.
- Add a label: `gh api 'repos/{owner}/{repo}/issues/<n>/labels' -f 'labels[]=<label>'`.
- Remove a label: `gh api -X DELETE 'repos/{owner}/{repo}/issues/<n>/labels/<label>'`.
- Close: comment with the reason, then `gh api -X PATCH 'repos/{owner}/{repo}/issues/<n>' -f state=closed`.

The issues endpoint also returns pull requests; the `select(.pull_request | not)` filter drops them. Write multi-line bodies to a file and pass them with `-F body=@<file>`.

## Parents and blocking

Sub-issues and dependencies take the database id of the other issue, not its number. Get it with `gh api 'repos/{owner}/{repo}/issues/<n>' --jq .id`.

- Make a sub-issue: `gh api 'repos/{owner}/{repo}/issues/<parent>/sub_issues' -F sub_issue_id=<child-id>`.
- Record a blocker: `gh api 'repos/{owner}/{repo}/issues/<n>/dependencies/blocked_by' -F issue_id=<blocker-id>`.
- Count open blockers: `gh api 'repos/{owner}/{repo}/issues/<n>' --jq .issue_dependencies_summary.blocked_by`; 0 means the issue can start.

When these endpoints are unavailable, put `Part of #<parent>` or `Blocked by: #<n>` at the top of the issue body instead.

## Pull requests as a triage surface

PRs as a request surface: no. External pull requests are reviewed as pull requests, not triaged as feature requests.

## Skill vocabulary

When a skill says "publish to the issue tracker", create a GitHub issue. When it says "fetch the relevant ticket", read the issue and its comments as above.

For the wayfinder skill, the map is one issue labelled `wayfinder:map`; its tickets are sub-issues labelled `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling` or `wayfinder:task`. Claim a ticket with `gh api 'repos/{owner}/{repo}/issues/<n>/assignees' -f "assignees[]=$(gh api user --jq .login)"`, then resolve it with a comment and close it.
