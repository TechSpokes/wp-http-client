#!/usr/bin/env bash
#
# Installs the third-party agent skills, pinned to the upstream commits below.
# Skills are copied into .agents/skills/ (Codex and most agents) and
# .claude/skills/ (Claude Code), and recorded in skills-lock.json.
#
# To update: change a commit or the lists, run this script, review the diff.
# Requires Node.js 22.20 or newer.

set -euo pipefail
cd "$(dirname "$0")/.."

installer='skills@1.7.6'

wordpress='WordPress/agent-skills#eff3785fc28c4380d172094518c66a6a997c95d4'
wordpress_skills=(
  blueprint wp-env wp-performance wp-phpstan wp-playground
  wp-plugin-development wp-plugin-directory-guidelines wp-project-triage
)

pocock='mattpocock/skills#4ae2317ddb22b046e26455e4f9c9b3aaaf62212d'
pocock_skills=(
  ask-matt code-review codebase-design diagnosing-bugs domain-modeling
  grill-me grill-with-docs grilling handoff implement implement-spec
  improve-codebase-architecture pr prototype research retro tdd teach
  to-questionnaire to-spec to-tickets triage wait-what wayfinder wizard
  writing-for-agents
)

export DISABLE_TELEMETRY=1 DO_NOT_TRACK=1

# Start clean so the installed set matches the lists above exactly.
rm -rf .agents/skills .claude/skills skills-lock.json

npx --yes "$installer" add "$wordpress" --skill "${wordpress_skills[@]}" --agent codex claude-code --copy --yes
npx --yes "$installer" add "$pocock" --skill "${pocock_skills[@]}" --agent codex claude-code --copy --yes
