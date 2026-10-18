#!/usr/bin/env bash
# Build the pinned Pele Mermaid renderer (https://github.com/obsidianmd/pele, MIT) from source.
# Reproducible: clones tag $PELE_TAG, refuses to build unless HEAD is exactly $PELE_SHA,
# then installs build deps from the upstream package-lock (npm ci) and runs the build.
# Usage: setup_pele.sh            (installs into $PELE_HOME, default ~/.cache/pele-1.6.0)
#        PELE_HOME=/path setup_pele.sh
set -euo pipefail

PELE_REPO="${PELE_REPO:-https://github.com/obsidianmd/pele.git}"
PELE_TAG="1.6.0"
PELE_SHA="659c3593ce43794dce7ec7ab45d424ad2de182a5"
PELE_HOME="${PELE_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/pele-$PELE_TAG}"

for bin in git node npm; do
    command -v "$bin" >/dev/null || { echo "setup_pele: '$bin' is required" >&2; exit 1; }
done

if [ ! -d "$PELE_HOME/.git" ]; then
    git clone --quiet --depth 1 --branch "$PELE_TAG" "$PELE_REPO" "$PELE_HOME"
fi

actual="$(git -C "$PELE_HOME" rev-parse HEAD)"
if [ "$actual" != "$PELE_SHA" ]; then
    echo "setup_pele: $PELE_HOME is at $actual, expected $PELE_SHA (tag $PELE_TAG). Remove it and re-run." >&2
    exit 1
fi

if [ ! -f "$PELE_HOME/dist/pele.js" ]; then
    (cd "$PELE_HOME" && npm ci --ignore-scripts --no-audit --no-fund --silent && npm run --silent build)
fi

echo "Pele $PELE_TAG ($PELE_SHA) ready: $PELE_HOME/dist/pele.js"
