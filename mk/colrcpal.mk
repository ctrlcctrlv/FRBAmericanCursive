# This won't work anymore because I manually added the OS2 weights to the .tsv and don't yet have an automatic way to derive them. File will need to be manually updated, which I think is fine.
#build_data/colrcpal_fontlist.tsv:
#	find build -type d -iname '*.ufo' -and -not -iname '*Guidelines*'| sed 's/.*-//;s/\.ufo$$//' > build_data/colrcpal_fontlist.tsv

# Build the color fonts.
.PHONY: colrcpal
colrcpal:
	./scripts/list_glyphs.py $(FONTFAMILY)-SOURCE.ufo | parallel --bar ./scripts/make_COLRglyphs_for_glyph.py {} $(FONTFAMILY)-SOURCE.ufo
	parallel --bar -a build_data/colrcpal_fontlist.tsv --colsep '\t' '
	./scripts/make_combined_without_colr_cpal.sh $(FONTFAMILY)-{1}.ufo {2}
	./scripts/combine_colr_cpal.py dist/$(FONTFAMILY)-{2}-GuidelinesArrows{1}.otf build/$(FONTFAMILY)-{1}.ufo
	'

# Build one color font for debugging purposes.
.PHONY: debug-colrcpal
debug-colrcpal:
	MFEKmetadata $(FONTFAMILY)-SOURCE.ufo glyphs | awk '{print $$1;}' | parallel --bar ./scripts/make_COLRglyphs_for_glyph.py {} $(FONTFAMILY)-SOURCE.ufo
	./scripts/make_combined_without_colr_cpal.sh $(FONTFAMILY)-Regular.ufo 400
	./scripts/combine_colr_cpal.py dist/$(FONTFAMILY)-400-GuidelinesArrowsRegular.otf build/$(FONTFAMILY)-Regular.ufo
