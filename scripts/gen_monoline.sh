#!/bin/bash
ARGS=`./scripts/fontmake_args.sh`
if [[ -z $FONTFAMILY ]]; then
	echo Must set FONTFAMILY >&2
	exit 1
fi

# Stroke all glyphs, removing internal contours (useful for !, i, j, ?, …, :, etc.)
NAMEDWEIGHT=$1
WIDTH=$2
OS2WEIGHT=$3

find $FONTFAMILY-SOURCE.ufo/glyphs/ -iname '*.glif' | parallel --bar "MFEKstroke DASH -i {} -o build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/} -w $WIDTH -d 100000 0"
# Restroke glyphs which shouldn't have their internal contours removed
#find $FONTFAMILY-SOURCE.ufo/glyphs/ -iname 'zero.glif' -or -iname 'degree.glif' -or -iname 'uni030A_.glif' -or -iname 'O_slash*' | parallel MFEKstroke CWS -i {} -o build/$FONTFAMILY-"$NAMEDWEIGHT".ufo/glyphs/{/} -w "$WIDTH"
# Generate OTF
python3 -m fontmake --verbose DEBUG -u build/$FONTFAMILY-"$NAMEDWEIGHT".ufo --output-path dist/$FONTFAMILY-"$OS2WEIGHT"-"$NAMEDWEIGHT".otf -o otf $ARGS
