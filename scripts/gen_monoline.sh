#!/bin/bash
ARGS=`./scripts/fontmake_args.sh`

# Stroke all glyphs, removing internal contours (useful for !, i, j, ?, …, :, etc.)
find FRBAmericanCursive-SOURCE.ufo/glyphs/ -iname '*.glif' | parallel MFEKstroke CWS -i {} -o build/FRBAmericanCursive-"$1".ufo/glyphs/{/} -w "$2" --remove-internal
# Restroke glyphs which shouldn't have their internal contours removed
find FRBAmericanCursive-SOURCE.ufo/glyphs/ -iname 'zero.glif' -or -iname 'degree.glif' -or -iname 'uni030A_.glif' -or -iname 'O_slash*' | parallel MFEKstroke CWS -i {} -o build/FRBAmericanCursive-"$1".ufo/glyphs/{/} -w "$2"
# Generate OTF
pypy3 -m fontmake --verbose DEBUG -u build/FRBAmericanCursive-"$1".ufo --output-path dist/FRBAmericanCursive-"$3"-"$1".otf -o otf $ARGS
