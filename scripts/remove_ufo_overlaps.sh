#!/bin/bash
# via AFDKO
shopt -s expand_aliases
source $AFDKO_ENV_ACTIVATE
UFO="$1"
if [[ -z "$UFO" || ! -d "$UFO" ]]; then exit 1; fi
alias newlines_to_commas='sed -e '\'':a;N;$!ba;s/\n/,/g'\'
./scripts/fake_ufo_glyphOrder.py "$UFO" # ugh
make UFO="$UFO" glif-refigure
checkoutlinesufo -q -e -d --min-area 10 -g $(grep -rl "<point" $FONTFAMILY-SOURCE.ufo/glyphs/*.glif | xargs xidel --silent -e /glyph/@name | newlines_to_commas) --ignore-contour-order -w "$UFO"
make UFO="$UFO" glif-refigure

# Possible future method if Rust and/or Skia ever gets good overlap removal:
#find $UFO/glyphs/ -iname '*.glif' | parallel "MFEKpathops BOOLEAN -p union -i {} -o {}_o && (grep -q '<point' {}_o && mv {}_o {}) || rm {}_o"
