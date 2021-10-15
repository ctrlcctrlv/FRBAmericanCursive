#!/bin/bash
ARGS=`./scripts/fontmake_args.sh`
if [[ -z $FONTFAMILY ]]; then
	echo Must set FONTFAMILY >&2
	exit 1
fi

# Stroke all glyphs, removing internal contours (useful for !, i, j, ?, …, :, etc.)
find $FONTFAMILY-SOURCE.ufo/glyphs/ -iname '*.glif' | parallel MFEKstroke CWS -i {} -o build/$FONTFAMILY-"$1".ufo/glyphs/{/} -w "$2" --remove-internal
# Restroke glyphs which shouldn't have their internal contours removed
find $FONTFAMILY-SOURCE.ufo/glyphs/ -iname 'zero.glif' -or -iname 'degree.glif' -or -iname 'uni030A_.glif' -or -iname 'O_slash*' | parallel MFEKstroke CWS -i {} -o build/$FONTFAMILY-"$1".ufo/glyphs/{/} -w "$2"
# Generate OTF
python3 -m fontmake --verbose DEBUG -u build/$FONTFAMILY-"$1".ufo --output-path dist/$FONTFAMILY-"$3"-"$1".otf -o otf $ARGS
