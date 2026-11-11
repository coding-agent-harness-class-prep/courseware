#!/usr/bin/env bash
#
# entrypoint.sh — runs INSIDE the container (see Containerfile).
#
# Converts every Markdown slide deck in $SLIDES_DIR/md into:
#   1. $SLIDES_DIR/pptx/<name>.pptx        (Marp)
#   2. $SLIDES_DIR/pdf/<name>.pdf          (Marp / headless Chrome)
#   3. $SLIDES_DIR/pdf/<COMBINED_NAME>     (all module PDFs merged, in order)
#
# Each deck is first run through preprocess.mjs, which converts the authored
# convention (YAML front matter, `#`/`##` headings, no `---`) into Marp-ready
# Markdown. Everything is driven by files, so adding a new deck is just a matter
# of dropping another NN-Section-Name-Slides.md into md/ and re-running.
#
# Env vars (all optional):
#   SLIDES_DIR      root slides dir mounted into the container (default /work)
#   DIAGRAMS_DIR    courseware/diagrams mounted read-only (default /diagrams);
#                   preprocess.mjs reads figures from here and inlines them
#   THEME           path to the Marp theme CSS (default $SLIDES_DIR/utils/courseware.css)
#   COMBINED_NAME   filename for the merged deck (default below)

set -euo pipefail

SLIDES_DIR="${SLIDES_DIR:-/work}"
export DIAGRAMS_DIR="${DIAGRAMS_DIR:-/diagrams}"
MD_DIR="$SLIDES_DIR/md"
PPTX_DIR="$SLIDES_DIR/pptx"
PDF_DIR="$SLIDES_DIR/pdf"
THEME="${THEME:-$SLIDES_DIR/utils/courseware.css}"
COMBINED_NAME="${COMBINED_NAME:-GitHub-Copilot-as-a-Coding-Agent-Harness-All-Slides.pdf}"

MARP="node /home/marp/.cli/marp-cli.js"
SRC_DIR="$(mktemp -d)"   # preprocessed Marp Markdown lands here

mkdir -p "$PPTX_DIR" "$PDF_DIR"

if [ ! -f "$THEME" ]; then
    echo "ERROR: theme not found at $THEME" >&2
    exit 1
fi

shopt -s nullglob
md_files=("$MD_DIR"/*.md)
if [ ${#md_files[@]} -eq 0 ]; then
    echo "ERROR: no .md files found in $MD_DIR" >&2
    exit 1
fi

echo "==> [1/3] Preprocess (authored Markdown -> Marp Markdown)"
for md in "${md_files[@]}"; do
    base="$(basename "$md" .md)"
    printf '    %-40s -> src/%s.md\n' "$base.md" "$base"
    node /usr/local/bin/preprocess.mjs "$md" > "$SRC_DIR/$base.md"
done

echo "==> [2/3] Marp -> PPTX + PDF"
for md in "${md_files[@]}"; do
    base="$(basename "$md" .md)"
    printf '    %-40s -> pptx/%s.pptx + pdf/%s.pdf\n' "$base.md" "$base" "$base"
    $MARP "$SRC_DIR/$base.md" --theme-set "$THEME" \
        --pptx --output "$PPTX_DIR/$base.pptx"
    $MARP "$SRC_DIR/$base.md" --theme-set "$THEME" \
        --pdf  --output "$PDF_DIR/$base.pdf"
done

echo "==> [3/3] Merge module PDFs -> pdf/$COMBINED_NAME"
combined="$PDF_DIR/$COMBINED_NAME"
rm -f "$combined"

# Collect per-module PDFs in sorted (module) order, excluding the combined file.
module_pdfs=()
while IFS= read -r f; do
    module_pdfs+=("$f")
done < <(find "$PDF_DIR" -maxdepth 1 -type f -name '*.pdf' ! -name "$COMBINED_NAME" | sort)

if [ ${#module_pdfs[@]} -eq 0 ]; then
    echo "WARNING: no per-module PDFs to merge" >&2
elif [ ${#module_pdfs[@]} -eq 1 ]; then
    cp "${module_pdfs[0]}" "$combined"
    echo "    only one module PDF; copied to $COMBINED_NAME"
else
    pdfunite "${module_pdfs[@]}" "$combined"
    echo "    merged ${#module_pdfs[@]} module PDFs"
fi

rm -rf "$SRC_DIR"

echo "==> Done."
echo "    pptx/ : $(find "$PPTX_DIR" -maxdepth 1 -name '*.pptx' | wc -l) file(s)"
echo "    pdf/  : $(find "$PDF_DIR" -maxdepth 1 -name '*.pdf' | wc -l) file(s) (incl. combined)"
