#!/bin/bash
rm -f /tmp/eachfont${FONTFAMILY}-*.pdf specimens/${FONTFAMILY}-specimen.pdf

echo ${FONTFAMILY_H}

find dist -type f -iname "${FONTFAMILY}*_NOVF.otf" | sort -V | parallel --jobs 200% --bar "
    export OS2WEIGHT=\`./scripts/os2weight_of_font.py {}\`
    export WEIGHT=\`./scripts/os2weight_to_namedweight.py \$OS2WEIGHT\`
    export STYLE=\`ftdump -n {}|rg '(family:|style:)'|awk 'BEGIN {FS=\"              \"} {print \$2}'|awk 'BEGIN {FS=\"\\n\"; RS=\"\"} {print \$1\$2}'\`
	(sed \"s/&&FONT&&/{/}/g; s/&&FONTFAMILY&&/${FONTFAMILY}/g; s/&&FONTFAMILY_H&&/${FONTFAMILY_H}/g; s/&&OS2WEIGHT&&/\$OS2WEIGHT/g; s/&&WEIGHT&&/\$WEIGHT/g; s/&&PAGE&&/{#}/g; s/&&STYLE&&/\$STYLE/\" < specimens/eachfont.sil) > /tmp/eachfont{/}.sil &&
	sile /tmp/eachfont{/}.sil
"

pdftk `ls /tmp/eachfont${FONTFAMILY}-*.pdf|sort -V` cat output specimens/${FONTFAMILY}-specimen.pdf
