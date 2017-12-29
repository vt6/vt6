#!/bin/sh
set -euo pipefail
if [ $# -ne 1 -o ! -f "${1:-}" ]; then
  echo "usage: $0 input.tikz > output.svg" >&2
  exit 1
fi
if [[ "$1" != *.tikz ]]; then
  echo "usage: $0 input.tikz > output.svg" >&2
  exit 1
fi

mkdir -p "$(dirname "$1")/.tikz"
cd "$(dirname "$1")/.tikz"
JOBNAME="$(basename "$1" .tikz)"

# build full TeX document (kudos to # build full TeX document
(
  echo '\documentclass[tikz]{standalone}'
  sed '/---/,$d' "../${JOBNAME}.tikz" # include preamble from input file
  echo '\begin{document}\begin{tikzpicture}'
  sed '1,/---/d' "../${JOBNAME}.tikz" # include body from input file
  echo '\end{tikzpicture}\end{document}'
) > "${JOBNAME}.tex"
pdflatex -interaction nonstopmode "${JOBNAME}"

# convert to final SVG
pdf2svg "${JOBNAME}.pdf" "../${JOBNAME}.svg"
