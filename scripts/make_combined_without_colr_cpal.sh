#!/bin/bash

cd build
FONT=$1
FONT_GA=${FONT/-/-GuidelinesArrows}
FONT_GA_OTF=${FONT_GA%%.ufo}.otf
FONT_GA_OTF=../dist/`basename "${FONT_GA_OTF}"`
echo Writing to $FONT_GA_OTF
rm -rf "$FONT_GA" "$FONT_GA_OTF"
cp -r "$FONT" "$FONT_GA"

for f in COLR_glyphs/*; do
	fn=`basename "$f"`
	cp "$f" $FONT_GA/glyphs/"$fn";	
done

if [ -z $PRODUCTION ]; then
	ARGS='--keep-overlaps --optimize-cff 1 --cff-round-tolerance 0'
else
	ARGS='--cff-round-tolerance 0'
fi

./../scripts/combine_plists.py COLR_glyphs/contents.plist "$FONT"/glyphs/contents.plist > "$FONT_GA"/glyphs/contents.plist
fontmake -u "$FONT_GA" --output-path "$FONT_GA_OTF" -o otf $ARGS
