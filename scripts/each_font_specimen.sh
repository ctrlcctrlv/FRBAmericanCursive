#!/bin/bash
rm -f /tmp/eachfontFRBAmericanCursive-*.pdf specimens/FRBAmericanCursive-specimen.pdf
for f in `ls dist`; do
	(cat specimens/eachfont.sil | sed 's/FRBAmericanCursive-500-Medium.otf/'`basename "$f"`'/g') > /tmp/eachfont"$f".sil
	sile /tmp/eachfont"$f".sil
done
pdftk /tmp/eachfontFRBAmericanCursive-*.pdf cat output specimens/FRBAmericanCursive-specimen.pdf
