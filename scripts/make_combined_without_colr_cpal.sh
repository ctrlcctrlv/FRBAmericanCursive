#!/bin/bash

FONT=$1
OS2WEIGHT=$2
NAMEDWEIGHT=`echo $FONT | sed 's/\.ufo$//; s/.*-//'`
FONT_GA=${FONT/-/-$OS2WEIGHT-GuidelinesArrows}
FONT_GA_OTF=${FONT_GA%%.ufo}.otf
FONT_GA_OTF=dist/`basename "${FONT_GA_OTF}"`
FONT_G=${FONT/-/-$OS2WEIGHT-Guidelines}
FONT_G_OTF=${FONT_G%%.ufo}.otf
FONT_G_OTF=dist/`basename "${FONT_G_OTF}"`
echo Writing to $FONT_GA_OTF
rm -rf build/"$FONT_GA" "$FONT_GA_OTF" build/"$FONT_G" "$FONT_G_OTF"
cp -r build/"$FONT" build/"$FONT_GA"
cp -r build/"$FONT" build/"$FONT_G"

ARGS=`./scripts/fontmake_args.sh`

for f in build/COLR_glyphs/*; do
	fn=`basename "$f"`
	cp "$f" build/"$FONT_GA"/glyphs/"$fn";
	if [[ $fn =~ "_guidelines" ]]; then
		cp "$f" build/"$FONT_G"/glyphs/"$fn";
	fi
done

# We combine the glyphs in the font this font will be based on on the glyphs which exist for CPAL purpose.
./scripts/combine_plists.py build/COLR_glyphs/contents.plist build/"$FONT"/glyphs/contents.plist > build/"$FONT_GA"/glyphs/contents.plist
./scripts/fudge_fontinfo.py build/"$FONT_GA" GuidelinesArrows $OS2WEIGHT $NAMEDWEIGHT
# ufonormalizer build/"$FONT_GA"
pypy3 -m fontmake --verbose DEBUG -u build/"$FONT_GA" --output-path "$FONT_GA_OTF" -o otf $ARGS

# We only copied the guidelines so we have to regenerate the contents.plist from the contents.
./scripts/regen_glyphs_plist.py build/"$FONT_G"/glyphs > build/"$FONT_G"/glyphs/contents.plist
./scripts/fudge_fontinfo.py build/"$FONT_G" Guidelines $OS2WEIGHT $NAMEDWEIGHT
# ufonormalizer build/"$FONT_G"
pypy3 -m fontmake --verbose DEBUG -u build/"$FONT_G" --output-path "$FONT_G_OTF" -o otf $ARGS
