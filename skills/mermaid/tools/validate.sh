#!/bin/bash
# Validate a Mermaid diagram by parsing + rendering it to SVG with Pele (no headless browser).
# Usage: validate.sh diagram.mmd [output.svg]
#
# Pele (https://github.com/obsidianmd/pele, MIT) is pinned to tag 1.6.0 / commit 659c3593 and
# built from source by tools/setup_pele.sh on first run (into ~/.cache/pele-1.6.0, or $PELE_HOME).
# Set PELE_DIST to use an already built pele.js.

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 diagram.mmd [output.svg]"
    exit 1
fi

INPUT="$1"
OUTPUT="${2:-}"
TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PELE_HOME="${PELE_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/pele-1.6.0}"
PELE_DIST="${PELE_DIST:-$PELE_HOME/dist/pele.js}"

if [ ! -f "$INPUT" ]; then
    echo "Error: File not found: $INPUT"
    exit 1
fi

if [ ! -f "$PELE_DIST" ]; then
    echo "Pele not found at $PELE_DIST; building pinned release..."
    PELE_HOME="$PELE_HOME" bash "$TOOLS_DIR/setup_pele.sh" >&2
    if [ ! -f "$PELE_DIST" ]; then
        echo "Error: Pele build not found at $PELE_DIST (check PELE_DIST / PELE_HOME)" >&2
        exit 1
    fi
fi

CLEANUP=0
if [ -z "$OUTPUT" ]; then
    OUTPUT=$(mktemp "${TMPDIR:-/tmp}/mermaid_validate.XXXXXX")
    CLEANUP=1
fi

trap 'if [ "$CLEANUP" -eq 1 ]; then rm -f "$OUTPUT"; fi' EXIT

echo "Validating: $INPUT"

# Parse + render with Pele. Errors mean invalid syntax.
if node "$TOOLS_DIR/pele_render.mjs" "$PELE_DIST" "$INPUT" > "$OUTPUT"; then
    echo "✓ Mermaid OK"
    echo ""
    echo "ASCII preview:"
    if ! MERMAID_INPUT="$INPUT" npx -y --package beautiful-mermaid node -e '
const fs = require("node:fs");
const path = require("node:path");
const binPath = process.env.PATH.split(":")[0];
const moduleRoot = path.dirname(binPath);
const { renderMermaidAscii } = require(path.join(moduleRoot, "beautiful-mermaid"));
const text = fs.readFileSync(process.env.MERMAID_INPUT, "utf8");
process.stdout.write(renderMermaidAscii(text));
process.stdout.write("\n");
'; then
        echo "Warning: ASCII preview failed (diagram type may be unsupported)."
    fi
    if [ "$CLEANUP" -eq 0 ]; then
        echo "Rendered to: $OUTPUT"
    fi
else
    rm -f "$OUTPUT"
    echo "✗ Mermaid validation failed"
    exit 1
fi
