#!/usr/bin/env bash
#
# convert.sh — host wrapper for macOS / Linux.
#
# Builds the outline-toolchain container image (if needed) and runs it against
# the outline directory, converting md/*.md into pdf/*.pdf.
#
# Usage:
#   ./convert.sh                 # build image + convert
#   ./convert.sh --no-build      # skip the image build, just convert
#   CONTAINER_ENGINE=docker ./convert.sh   # use docker instead of podman
#
# Requires podman (default) or docker on PATH.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTLINE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGE="copilot-harness-outline:latest"
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

echo "==> Converting outline in: $OUTLINE_DIR"
# NOTE: on an SELinux-enforcing Linux host, append ':Z' to the volume, i.e.
#   -v "$OUTLINE_DIR":/work:Z
# On macOS/Windows podman machines (and Docker Desktop) the plain form is correct.
"$ENGINE" run --rm \
    -v "$OUTLINE_DIR":/work \
    -e OUTLINE_DIR=/work \
    "$IMAGE"

echo "==> Finished. Output is in:"
echo "      $OUTLINE_DIR/pdf"
