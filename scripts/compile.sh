#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SRC_DIR="$ROOT_DIR/src"
ORDER_FILE="$SRC_DIR/order.tex"

BUILD_DIR="$ROOT_DIR/.latex-build"
FINAL_PDF="$ROOT_DIR/resume.pdf"
JOBNAME="resume"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
trap 'rm -rf "$BUILD_DIR"' EXIT

if [[ "${1:-}" == "ww-ordering" || "${1:-}" == "skills-first" ]]; then
  echo "Building with Skills before Education"
  cat > "$ORDER_FILE" <<'EOF'
% Auto-generated
\newif\ifskillsfirst
\skillsfirsttrue
EOF
else
  echo "Building with Education before Skills"
  cat > "$ORDER_FILE" <<'EOF'
% Auto-generated
\newif\ifskillsfirst
\skillsfirstfalse
EOF
fi

(
  cd "$SRC_DIR"
  for pass in 1 2; do
    pdflatex -interaction=nonstopmode -halt-on-error \
      -output-directory="$BUILD_DIR" \
      "resume.tex" >/dev/null
  done
)

if [[ -f "$BUILD_DIR/$JOBNAME.pdf" ]]; then
  cp -f "$BUILD_DIR/$JOBNAME.pdf" "$FINAL_PDF"
  echo "Wrote: $FINAL_PDF"
else
  echo "Error: expected PDF not found at $BUILD_DIR/$JOBNAME.pdf" >&2
  exit 1
fi