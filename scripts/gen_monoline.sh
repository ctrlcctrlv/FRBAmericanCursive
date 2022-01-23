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

#find $FONTFAMILY-SOURCE.ufo/glyphs/ -iname '*.glif' | parallel --bar "MFEKstroke DASH -i {} -o build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/} -w $WIDTH -d 100000 0"
find build/BUILD.ufo/glyphs/ -iname '*.glif' -and -not -iname '__combstroke*' | parallel --ctag --tag --linebuffer "
MFEKstroke CWS -i {} -o build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/} -w $WIDTH -S
if [[ ! -s build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/} ]]; then
    echo 'Warning: Dashing {/} ($FONTFAMILY-$NAMEDWEIGHT.ufo)'
    MFEKstroke DASH -i {} -o build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/} -w $WIDTH -d 1000 0
fi
if [[ ! -s build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/} ]]; then
    echo 'Error: Even dashing failed!'
fi
MFEKpathops BOOLEAN -p remove_interior -i build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/} -o build/$FONTFAMILY-$NAMEDWEIGHT.ufo/glyphs/{/}
"
# Generate OTF
python3 -m fontmake --verbose DEBUG -u build/$FONTFAMILY-"$NAMEDWEIGHT".ufo --output-path dist/$FONTFAMILY-"$OS2WEIGHT"-"$NAMEDWEIGHT".otf -o otf $ARGS
