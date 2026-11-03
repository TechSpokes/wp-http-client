# Third-party notices

This repository contains copies of third-party agent skills used by AI assistants that work on the package. They are development material only: `bin/install-agent-skills.sh` installs them, pinned to the commits below, into `.agents/skills/` (read by Codex and other agents) and `.claude/skills/` (read by Claude Code), and `.gitattributes` excludes them from the Composer package.

The copies are unmodified. Project-specific overrides belong in `AGENTS.md`, not in the skill files.

## Agent Skills for WordPress

- Source: https://github.com/WordPress/agent-skills
- Commit: `eff3785fc28c4380d172094518c66a6a997c95d4` (2026-10-21)
- Skills: `blueprint`, `wp-env`, `wp-performance`, `wp-phpstan`, `wp-playground`, `wp-plugin-development`, `wp-plugin-directory-guidelines`, `wp-project-triage`
- License: GPL-2.0-or-later

```text
Agent Skills for WordPress
Copyright (C) 2026 WordPress Contributors

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
```

This repository uses them under version 3 of the GPL, as the "or later" option allows; the full text is in `LICENSE`.

## Skills For Real Engineers (Matt Pocock)

- Source: https://github.com/mattpocock/skills
- Commit: `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d` (2026-10-31)
- Skills: `ask-matt`, `code-review`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grill-me`, `grill-with-docs`, `grilling`, `handoff`, `implement`, `implement-spec`, `improve-codebase-architecture`, `pr`, `prototype`, `research`, `retro`, `tdd`, `teach`, `to-questionnaire`, `to-spec`, `to-tickets`, `triage`, `wait-what`, `wayfinder`, `wizard`, `writing-for-agents`
- License: MIT

```text
MIT License

Copyright (c) 2026 Matt Pocock

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
