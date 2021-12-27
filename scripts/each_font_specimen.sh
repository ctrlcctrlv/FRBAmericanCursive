#!/bin/bash
rm -f /tmp/eachfont${FONTFAMILY}-*.pdf specimens/${FONTFAMILY}-specimen.pdf

echo ${FONTFAMILY_H}

find dist -type f -iname "*_NOVF.otf" | sort -V | parallel --jobs 200% --bar "
	export STYLE=\`ftdump -n {}|grep family|head -n1|sed \"s/.*${FONTFAMILY_H} *//;s/\s+$//\"\` &&
	(sed \"s/&&FONT&&/{/}/g; s/&&PAGE&&/{#}/g; s/&&STYLE&&/\$STYLE/\" < specimens/eachfont.sil) > /tmp/eachfont{/}.sil &&
	sile /tmp/eachfont{/}.sil
"

pdftk `ls /tmp/eachfont${FONTFAMILY}-*.pdf|sort -V` cat output specimens/${FONTFAMILY}-specimen.pdf
