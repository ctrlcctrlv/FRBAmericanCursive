#!/bin/bash
otf2otc -o dist/ttc/${FONTFAMILY}-Monoline.ttc $(cat build_data/monoline.tsv | awk '{print $1}' | xargs -I{} echo -n dist/${FONTFAMILY}-*-{}.otf' ')
otf2otc -o dist/ttc/${FONTFAMILY}-Patterned.ttc $(cat build_data/dotted.tsv | awk '{print $1}' | xargs -I{} echo -n dist/${FONTFAMILY}-*-{}.otf' ')
otf2otc -o dist/ttc/${FONTFAMILY}-ColorGuidelines.ttc $(cat build_data/colrcpal_fontlist.tsv | awk '{print $1}' | xargs -I{} echo -n dist/${FONTFAMILY}-*-Guidelines{}.otf' ')
otf2otc -o dist/ttc/${FONTFAMILY}-ColorGuidelinesArrows.ttc $(cat build_data/colrcpal_fontlist.tsv | awk '{print $1}' | xargs -I{} echo -n dist/${FONTFAMILY}-*-GuidelinesArrows{}.otf' ')
otf2otc -o dist/ttc/${FONTFAMILY}-ColorGuidelinesNonVariable.ttc $(cat build_data/colrcpal_fontlist.tsv | awk '{print $1}' | xargs -I{} echo -n dist/${FONTFAMILY}-*-Guidelines{}_NOVF.otf' ')
otf2otc -o dist/ttc/${FONTFAMILY}-ColorGuidelinesArrowsNonVariable.ttc $(cat build_data/colrcpal_fontlist.tsv | awk '{print $1}' | xargs -I{} echo -n dist/${FONTFAMILY}-*-GuidelinesArrows{}_NOVF.otf' ')
otf2otc -o dist/ttc/${FONTFAMILY}-JustOneLayer.ttc dist/${FONTFAMILY}-*-Just*.otf
