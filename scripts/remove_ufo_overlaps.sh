#!/bin/bash
# via AFDKO
shopt -s expand_aliases
UFO="$1"
if [[ -z "$UFO" || ! -d "$UFO" ]]; then exit 1; fi
alias newlines_to_commas='sed -e '\'':a;N;$!ba;s/\n/,/g'\'
./scripts/fake_ufo_glyphOrder.py "$UFO" # ugh
checkoutlinesufo -q -e -d --min-area 10 -g $(grep -rl "<point" $FONTFAMILY-SOURCE.ufo/glyphs/*.glif | xargs xidel --silent -e /glyph/@name | newlines_to_commas) --ignore-contour-order -w "$UFO"

# Possible future method if Rust and/or Skia ever gets good overlap removal:
#MFEKpathops BOOLEAN -p remove_interior -i build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/} -o build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/}_o
#(grep -q '<point' build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/}_o && mv build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/}_o build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/}) || rm build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/}_o
