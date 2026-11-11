#!/usr/bin/env bash
#
# convert.sh — host wrapper for macOS / Linux.
#
# Builds the slide-toolchain container image (if needed) and runs it against
# the slides directory, converting md/*.md into pptx/ and pdf/ (plus a merged
# all-modules PDF).
#
# Usage:
#   ./convert.sh                 # build image + convert everything
#   ./convert.sh --no-build      # skip the image build, just convert
#   CONTAINER_ENGINE=docker ./convert.sh   # use docker instead of podman
#
# Requires podman (default) or docker on PATH.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SLIDES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# Diagrams live beside slides/, outside the /work mount, so they get their own
# read-only volume. preprocess.mjs reads from it to inline each figure.
DIAGRAMS_DIR="$(cd "$SLIDES_DIR/../diagrams" && pwd)"
IMAGE="copilot-harness-slides:latest"
ENGINE="${CONTAINER_ENGINE:-podman}"

if ! command -v "$ENGINE" >/dev/null 2>&1; then
    echo "ERROR: '$ENGINE' not found on PATH. Install podman (or set CONTAINER_ENGINE=docker)." >&2
    exit 1
fi

if [ "${1:-}" != "--no-build" ]; then
    echo "==> Building image '$IMAGE' with $ENGINE"
    # -f is explicit because Docker, unlike podman, only looks for a file named Dockerfile.
    "$ENGINE" build -t "$IMAGE" -f "$SCRIPT_DIR/Containerfile" "$SCRIPT_DIR"
fi

echo "==> Converting slides in: $SLIDES_DIR"
echo "    diagrams from      : $DIAGRAMS_DIR"
# NOTE: on an SELinux-enforcing Linux host, append ':Z' to each volume, i.e.
#   -v "$SLIDES_DIR":/work:Z  -v "$DIAGRAMS_DIR":/diagrams:ro,Z
# On macOS/Windows podman machines (and Docker Desktop) the plain form is correct.
"$ENGINE" run --rm \
    -v "$SLIDES_DIR":/work \
    -v "$DIAGRAMS_DIR":/diagrams:ro \
    -e SLIDES_DIR=/work \
    -e DIAGRAMS_DIR=/diagrams \
    "$IMAGE"

echo "==> Finished. Outputs are in:"
echo "      $SLIDES_DIR/pptx"
echo "      $SLIDES_DIR/pdf"
