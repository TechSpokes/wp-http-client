#!/usr/bin/env bash
set -euo pipefail

cd "$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

diff -r .agents/skills .claude/skills

inventory="$(mktemp)"
trap 'rm -f -- "$inventory"' EXIT

# @constraints Archive checks cover HEAD; commit the candidate before final verification.
git archive --format=tar HEAD | tar -tf - > "$inventory"

unexpected=0
while IFS= read -r path; do
    case "$path" in
        src/*|composer.json|LICENSE|README.md|CHANGELOG.md) ;;
        *)
            printf 'Unexpected package archive entry: %s\n' "$path" >&2
            unexpected=1
            ;;
    esac
done < "$inventory"

if ((unexpected)); then
    exit 1
fi

printf 'Repository checks passed: working skill copies match; HEAD archive contains only runtime files.\n'
