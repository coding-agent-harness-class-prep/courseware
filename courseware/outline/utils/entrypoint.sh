#!/usr/bin/env bash
#
# entrypoint.sh — runs INSIDE the container (see Containerfile).
#
# Converts every Markdown outline in $OUTLINE_DIR/md into a styled PDF in
# $OUTLINE_DIR/pdf:
#   Markdown --(build.mjs + marked)--> HTML --(headless Chrome)--> PDF
#
# Everything is file-driven: drop another *.md into md/ and re-run.
#
# Env vars (all optional):
#   OUTLINE_DIR   root outline dir mounted into the container (default /work)
#   CHROME_PATH   path to the headless Chrome binary (set by the base image)

set -euo pipefail

OUTLINE_DIR="${OUTLINE_DIR:-/work}"
MD_DIR="$OUTLINE_DIR/md"
PDF_DIR="$OUTLINE_DIR/pdf"
BUILD="/opt/outline/build.mjs"
PRINT="/opt/outline/print.cjs"
# puppeteer-core lives in the marp-cli base image; let `require` find it.
export NODE_PATH="/home/marp/.cli/node_modules"
TMP="$(mktemp -d)"

mkdir -p "$PDF_DIR"

shopt -s nullglob
md_files=("$MD_DIR"/*.md)
if [ ${#md_files[@]} -eq 0 ]; then
    echo "ERROR: no .md files found in $MD_DIR" >&2
    exit 1
fi

for md in "${md_files[@]}"; do
    base="$(basename "$md" .md)"
    printf '==> %-50s -> pdf/%s.pdf\n' "$base.md" "$base"
    node "$BUILD" "$md" "$TMP/$base.html"
    node "$PRINT" "$TMP/$base.html" "$PDF_DIR/$base.pdf"
done

rm -rf "$TMP"

echo "==> Done."
echo "    pdf/ : $(find "$PDF_DIR" -maxdepth 1 -name '*.pdf' | wc -l) file(s)"
