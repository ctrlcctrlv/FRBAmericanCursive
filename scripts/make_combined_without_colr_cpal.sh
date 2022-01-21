#!/bin/bash

PYTHON="${PYTHON:-python3}"
if [[ $OTF_EXT =~ ".otf" ]]; then
    OTF_SIMPLE="otf";
    OTF_VARIABLE="variable-cff2";
elif  [[ $OTF_EXT =~ ".ttf" ]]; then
    OTF_SIMPLE="ttf";
    OTF_VARIABLE="variable";
fi
FONT=$1
OS2WEIGHT=$2
NAMEDWEIGHT=`echo $FONT | sed 's/\.ufo$//; s/.*-//'`
FONT_GA=${FONT/-/-$OS2WEIGHT-GuidelinesArrows}
FONT_GA_OTF=${FONT_GA%%.ufo}${OTF_EXT}
FONT_GA_OTF=dist/`basename "${FONT_GA_OTF}"`
FONT_G=${FONT/-/-$OS2WEIGHT-Guidelines}
FONT_G_OTF=${FONT_G%%.ufo}${OTF_EXT}
FONT_G_OTF=dist/`basename "${FONT_G_OTF}"`
rm -rf build/"$FONT_GA" "$FONT_GA_OTF" build/"$FONT_G" "$FONT_G_OTF"
cp -r build/"$FONT" build/"$FONT_GA"
cp -r build/"$FONT" build/"$FONT_G"

ARGS=`./scripts/fontmake_args.sh`

for f in build/{"$FONTFAMILY"_COLR_glyphs,"$FONT"/COLR_glyphs}/*; do
	fn=`basename "$f"`
	cp "$f" build/"$FONT_GA"/glyphs/"$fn";
	if [[ $fn =~ "_guidelines" || $fn =~ "_xheight" || $fn =~ "_baseline" ]]; then
		cp "$f" build/"$FONT_G"/glyphs/"$fn";
	fi
done

<<'###BLOCK-COMMENT'
set -x
for f in build/"$FONT_GA"/glyphs/*.glif; do
    fn=`basename -s.glif "$f"`
	if [[ $fn =~ "_guidelines" || $fn =~ "_xheight" || $fn =~ "_baseline" || $fn =~ "_beginnings" || $fn =~ "_endings" || $fn =~ "_arrows" ]]; then
        continue
    fi
    cp "$f" build/"$FONT_GA"/glyphs/"$fn".G_U_I_D_E_L_I_N_E_S_.glif
done

./scripts/regen_glyphs_plist.py build/"$FONT_GA"/glyphs

TEMPFEA=`mktemp --suffix .fea`
make UFO=build/"$FONT_GA" FEZ=fea/COLR_ss03.fez FEA="$TEMPFEA" fez-source
cat "$TEMPFEA" >> build/"$FONT_GA"/features.fea
set +x
###BLOCK-COMMENT

function make_combined() {
	FONT="$1"
	OTF="$2"
	NAME_PREPEND="$3"
	OTF_NOVF="dist/`basename ${OTF} ${OTF_EXT}`_NOVF$OTF_EXT"
	echo "Writing to $FONT $OTF"
	./scripts/regen_glyphs_plist.py build/"$FONT"/glyphs
	./scripts/fudge_fontinfo.py build/"$FONT" "$FONTFAMILY" "$FONTFAMILY_H" "${NAME_PREPEND}${NAMEDWEIGHT}" "$OS2WEIGHT"
	# ufonormalizer build/"$FONT"
	$PYTHON -m fontmake --verbose DEBUG -u "build/$FONT" --output-path "$OTF_NOVF" -o $OTF_SIMPLE $ARGS
    if [[ -f build_data/"$FONTFAMILY"_buildVF ]]; then
        DESIGNSPACE=`mktemp --suffix=.designspace`
        xidel --xml --xquery 'transform(/, function($e){if (name($e) = "source") then <source filename="'$PWD/build/$FONT'">{$e/@* except $e/@filename, $e/*}</source> else $e})' build_data/FRBAC.designspace > "$DESIGNSPACE"
        $PYTHON -m fontmake --verbose DEBUG -m "$DESIGNSPACE" --output-path "$OTF" -o $OTF_VARIABLE $ARGS
        rm "$DESIGNSPACE"
    fi
}
make_combined $FONT_GA $FONT_GA_OTF GuidelinesArrows
make_combined $FONT_G $FONT_G_OTF Guidelines
