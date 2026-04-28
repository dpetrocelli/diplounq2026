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

# Clase 3 — Cierre clase 2 + AcademicCredentials (ERC-721)
render "clase-3.md" \
  "clase-3.html" \
  "Clase 3 — Credenciales académicas (ERC-721)" \
  "CLASE 3"

# Clase 4 — Frontend NFT + Seguridad
render "clase-4.md" \
  "clase-4.html" \
  "Clase 4 — Frontend NFT + Seguridad" \
  "CLASE 4"

echo ""
echo "Done. Open with:"
echo "  xdg-open $DIR/index.html"
