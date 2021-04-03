#!/bin/bash
rm -f /tmp/eachfontFRBAmericanCursive-*.pdf specimens/FRBAmericanCursive-specimen.pdf

find dist -type f -iname "*.otf" | parallel --bar '
	export STYLE=`ftdump -n {}|grep family|head -n1|sed "s/.*FRB American Cursive *//;s/\s+$//"` &&
	(sed "s/&&FONT&&/{/}/g; s/&&STYLE&&/$STYLE/" < specimens/eachfont.sil) > /tmp/eachfont{/}.sil &&
	sile /tmp/eachfont{/}.sil
'

pdftk `ls /tmp/eachfontFRBAmericanCursive-*.pdf|sort -V` cat output specimens/FRBAmericanCursive-specimen.pdf
