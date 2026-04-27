#!/usr/bin/env bash
# Build UNQ-branded HTML pages from markdown sources for Diplo Blockchain 2026.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

TEMPLATE="$DIR/template.html"

render() {
  local src="$1"
  local out="$2"
  local title="$3"
  local banner="${4:-}"

  echo "→ $src"
  echo "   $out"

  pandoc "$src" \
    --from=gfm+smart \
    --to=html5 \
    --standalone \
    --template="$TEMPLATE" \
    --toc \
    --toc-depth=3 \
    --highlight-style=tango \
    --metadata title="$title" \
    --metadata banner-num="$banner" \
    --metadata pagetitle="$title — UNQ Diplo Blockchain" \
    --output "$out"
}

# ============ Render targets ============

# Clase 2 — Foundry + SimpleStorage
render "clase-2.md" \
  "clase-2.html" \
  "Clase 2 — Foundry + SimpleStorage" \
  "CLASE 2"

echo ""
echo "Done. Open with:"
echo "  xdg-open $DIR/index.html"
