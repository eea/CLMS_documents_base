#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
META_DIR="$DOCS_DIR/_meta"

# Track copied index.qmd files to clean up later
COPIED_INDEX_FILES=("$DOCS_DIR/index.qmd")

cleanup() {
  echo "🧹 Cleaning up temporary files..."
  for file in "${COPIED_INDEX_FILES[@]}"; do
    rm -f "$file"
  done
  rm -rf "$DOCS_DIR/_preview"
}
trap cleanup EXIT INT TERM

echo "🔧 Rendering documents..."
quarto render "$DOCS_DIR" --to html

echo "🔧 Rendering index.qmd file..."
cp "$META_DIR/index.qmd" "$DOCS_DIR/index.qmd"
cp "$DOCS_DIR/_quarto.yml" "$DOCS_DIR/_quarto-not-used.yml"
cp "$META_DIR/_quarto-index.yml" "$DOCS_DIR/_quarto.yml"
quarto render "$DOCS_DIR/index.qmd" --to html --no-clean
mv "$DOCS_DIR/_quarto-not-used.yml" "$DOCS_DIR/_quarto.yml"

quarto preview "$DOCS_DIR" --to html