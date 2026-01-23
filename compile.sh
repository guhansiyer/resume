#!/bin/bash
set -e

OUTDIR="output"
ORDER_FILE="sections/order.tex"

mkdir -p "$OUTDIR"

if [[ "$1" == "ww-ordering" ]]; then
    echo "Building with Skills before Education"

    cat > "$ORDER_FILE" <<EOF
% Auto-generated
\\newif\\ifskillsfirst
\\skillsfirsttrue
EOF
else
    echo "Building with Education before Skills"

    cat > "$ORDER_FILE" <<EOF
% Auto-generated
\\newif\\ifskillsfirst
\\skillsfirstfalse
EOF
fi

pdflatex -output-directory="$OUTDIR" GI_Resume.tex
