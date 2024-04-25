#!/bin/bash

#--css ./pandoc.css
pandoc "$1" \
    -f gfm \
    -V linkcolor:blue \
    -V geometry:a4paper \
    -V geometry:margin=1cm \
    -V mainfont="DejaVu Serif" \
    -V monofont="DejaVu Sans Mono" \
    -V fontsize=11pt \
    --pdf-engine=xelatex \
    --highlight-style ./custom.theme \
    --include-in-header ./chapter-break.tex \
    --include-in-header ./inline-code.tex \
    --include-in-header ./bullet-list.tex \
    -o "$2"

