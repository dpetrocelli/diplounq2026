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
    --from=gfm+smart+attributes \
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

# ---------- Clase 2 (Foundry + SimpleStorage) ----------
render "clase-2-clase.md" \
  "clase-2-clase.html" \
  "Clase 2 — Foundry + SimpleStorage · En clase" \
  "C2 · CLASE"

render "clase-2-tarea.md" \
  "clase-2-tarea.html" \
  "Clase 2 — Foundry + SimpleStorage · Tarea" \
  "C2 · TAREA"

# ---------- Clase 3 (AcademicCredentials ERC-721) ----------
render "clase-3-clase.md" \
  "clase-3-clase.html" \
  "Clase 3 — Credenciales académicas (ERC-721) · En clase" \
  "C3 · CLASE"

render "clase-3-tarea.md" \
  "clase-3-tarea.html" \
  "Clase 3 — Credenciales académicas (ERC-721) · Tarea" \
  "C3 · TAREA"

# ---------- Clase 4 (Frontend NFT + Seguridad) ----------
render "clase-4-clase.md" \
  "clase-4-clase.html" \
  "Clase 4 — Frontend NFT + Seguridad · En clase" \
  "C4 · CLASE"

render "clase-4-tarea.md" \
  "clase-4-tarea.html" \
  "Clase 4 — Frontend NFT + Seguridad · Tarea" \
  "C4 · TAREA"

# ---------- TP Final ----------
render "tp-final.md" \
  "tp-final.html" \
  "Trabajo Final — Verificación de credenciales académicas UNQ" \
  "TP FINAL"

echo ""
echo "Done. Open with:"
echo "  xdg-open $DIR/index.html"
