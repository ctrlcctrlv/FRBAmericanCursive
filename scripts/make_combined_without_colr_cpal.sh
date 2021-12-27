#!/bin/bash

PYTHON="${PYTHON:-python3}"
FONT=$1
OS2WEIGHT=$2
NAMEDWEIGHT=`echo $FONT | sed 's/\.ufo$//; s/.*-//'`
FONT_GA=${FONT/-/-$OS2WEIGHT-GuidelinesArrows}
FONT_GA_OTF=${FONT_GA%%.ufo}.otf
FONT_GA_OTF=dist/`basename "${FONT_GA_OTF}"`
FONT_G=${FONT/-/-$OS2WEIGHT-Guidelines}
FONT_G_OTF=${FONT_G%%.ufo}.otf
FONT_G_OTF=dist/`basename "${FONT_G_OTF}"`
rm -rf build/"$FONT_GA" "$FONT_GA_OTF" build/"$FONT_G" "$FONT_G_OTF"
cp -r build/"$FONT" build/"$FONT_GA"
cp -r build/"$FONT" build/"$FONT_G"

ARGS=`./scripts/fontmake_args.sh`

for f in build/{COLR_glyphs,"$FONT"/COLR_glyphs}/*; do
	fn=`basename "$f"`
	cp "$f" build/"$FONT_GA"/glyphs/"$fn";
	if [[ $fn =~ "_guidelines" || $fn =~ "_xheight" || $fn =~ "_baseline" ]]; then
		cp "$f" build/"$FONT_G"/glyphs/"$fn";
	fi
done

function make_combined() {
	FONT=$1
	OTF=$2
	OTF_NOVF=${OTF%%.otf}_NOVF.otf
	DESIGNSPACE=`mktemp --suffix=.designspace`
	echo Writing to $FONT $OTF
	./scripts/regen_glyphs_plist.py build/"$FONT"/glyphs
	./scripts/fudge_fontinfo.py build/"$FONT" GuidelinesArrows"$NAMEDWEIGHT" "$OS2WEIGHT"
	xidel --xml --xquery 'transform(/, function($e){if (name($e) = "source") then <source filename="'$PWD/build/$FONT'">{$e/@* except $e/@filename, $e/*}</source> else $e})' build_data/FRBAC.designspace > "$DESIGNSPACE"
	# ufonormalizer build/"$FONT"
	$PYTHON -m fontmake --keep-overlaps --verbose DEBUG -u "build/$FONT" --output-path "$OTF_NOVF" -o otf $ARGS
	$PYTHON -m fontmake --keep-overlaps --verbose DEBUG -m "$DESIGNSPACE" --output-path "$OTF" -o variable-cff2 $ARGS
	rm "$DESIGNSPACE"
}
make_combined $FONT_GA $FONT_GA_OTF
make_combined $FONT_G $FONT_G_OTF
