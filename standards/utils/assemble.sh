#!/usr/bin/env bash
#
# assemble.sh — build the repo's AGENTS.md from its two sources:
#
#   AGENTS.md  =  <course profile>  +  <shared standards>
#              =  AGENTS.course.md   +  standards/AGENTS.base.md
#
# Edit those two SOURCE files, never the generated AGENTS.md. Run this after editing
# either. CLAUDE.md imports the generated AGENTS.md (`@AGENTS.md`); Copilot, Codex,
# Grok, Cursor, Gemini and other tools read AGENTS.md natively.
#
# Layout assumed (standards/ is typically a git submodule):
#   <repo>/AGENTS.course.md
#   <repo>/standards/AGENTS.base.md
#   <repo>/standards/utils/assemble.sh   (this file)
#   <repo>/AGENTS.md                      (generated)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # standards/utils
STANDARDS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"                # standards
REPO_ROOT="$(cd "$STANDARDS_DIR/.." && pwd)"                 # repo root

BASE="$STANDARDS_DIR/AGENTS.base.md"
COURSE="$REPO_ROOT/AGENTS.course.md"
OUT="$REPO_ROOT/AGENTS.md"

for f in "$COURSE" "$BASE"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: missing source file: $f" >&2
        exit 1
    fi
done

{
    printf '%s\n' '<!-- GENERATED FILE — do not edit. Assembled from AGENTS.course.md + standards/AGENTS.base.md'
    printf '%s\n' '     by standards/utils/assemble.(sh|ps1). Edit those sources and re-run. -->'
    printf '\n'
    cat "$COURSE"
    printf '\n---\n\n'
    printf '%s\n\n' '<!-- ===== Shared cross-course standards (standards/AGENTS.base.md) ===== -->'
    cat "$BASE"
} > "$OUT"

echo "Wrote $OUT (from AGENTS.course.md + standards/AGENTS.base.md)"
