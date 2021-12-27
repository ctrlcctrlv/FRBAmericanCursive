# This won't work anymore because I manually added the OS2 weights to the .tsv and don't yet have an automatic way to derive them. File will need to be manually updated, which I think is fine.
#build_data/colrcpal_fontlist.tsv:
#	find build -type d -iname '*.ufo' -and -not -iname '*Guidelines*'| sed 's/.*-//;s/\.ufo$$//' > build_data/colrcpal_fontlist.tsv

.PHONY: colrglyphs
colrglyphs:
	set -- `MFEKmetadata FRBAmericanCursive-SOURCE.ufo arbitrary -k capHeight -k openTypeOS2TypoDescender -k xHeight`
	./scripts/list_glyphs.py $(FONTFAMILY)-SOURCE.ufo | C=$$1 D=$$2 X=$$3 parallel --bar './scripts/make_COLRglyphs_for_glyph.py {} $(FONTFAMILY)-SOURCE.ufo $$C $$D $$X'

.PHONY: colrglyphs-ufo
colrglyphs-ufo:
	parallel -u -a build_data/colrcpal_fontlist.tsv --colsep '\t' '
	rm -fr build/$(FONTFAMILY)-{1}.ufo/{COLR_glyphs,arrow_glyphs}
	mkdir -p build/$(FONTFAMILY)-{1}.ufo/{COLR_glyphs,arrow_glyphs}
	MAXLEN=`./scripts/make_arrow_glyph.py MAXLEN`
	[[ -f build_data/arrow_$$MAXLEN.glif ]] || cp `./scripts/make_arrow_glyph.py $$MAXLEN` build_data/arrow_$$MAXLEN.glif;
	find $(FONTFAMILY)-SOURCE.ufo/glyphs/ -iname "*.glif" | parallel -I^ --bar '\''./scripts/make_arrows_for_glyph.py ^ build/$(FONTFAMILY)-{1}.ufo/COLR_glyphs/`basename -s.glif ^`_arrows.glif {2}'\''
	'
	#xidel --input-format xml build/arrow_glyphs/*.glif -e '//point[1]/join((replace(replace(file:name($$path), "\.glif$$", ""), "([A-Z])_", "$$1"), round(number(@x)), round(number(@y)), x"stroke{position()}"), '$$'"\t"'')' --silent > build_data/strokes.tsv
	#./scripts/tsv_to_mark.py build_data/strokes.tsv >> fea/mark.fea

# Build the color fonts.
.PHONY: colrcpal
colrcpal:
	if [ ! -d "build/COLR_glyphs" ]; then make colrglyphs colrglyphs-ufo; fi # may have been made by physics
	parallel --bar -a build_data/colrcpal_fontlist.tsv --colsep '\t' '
	./scripts/make_combined_without_colr_cpal.sh $(FONTFAMILY)-{1}.ufo {3}
	./scripts/combine_colr_cpal.py dist/$(FONTFAMILY)-{3}-GuidelinesArrows{1}.otf build/$(FONTFAMILY)-{1}.ufo
	./scripts/combine_colr_cpal.py dist/$(FONTFAMILY)-{3}-GuidelinesArrows{1}_NOVF.otf build/$(FONTFAMILY)-{1}.ufo
	./scripts/rewrite_feature_substitutions.py dist/$(FONTFAMILY)-{3}-GuidelinesArrows{1}.otf
	'

# Build one color font for debugging purposes.
.PHONY: debug-colrcpal
debug-colrcpal:
	if [ ! -d "build/COLR_glyphs" ]; then make colrglyphs colrglyphs-ufo; fi # may have been made by physics
	./scripts/make_combined_without_colr_cpal.sh $(FONTFAMILY)-$(STYLENAME).ufo 400
	./scripts/combine_colr_cpal.py dist/$(FONTFAMILY)-400-GuidelinesArrows$(STYLENAME).otf build/$(FONTFAMILY)-$(STYLENAME).ufo
	./scripts/combine_colr_cpal.py dist/$(FONTFAMILY)-400-GuidelinesArrows$(STYLENAME)_NOVF.otf build/$(FONTFAMILY)-$(STYLENAME).ufo
	./scripts/rewrite_feature_substitutions.py dist/$(FONTFAMILY)-400-GuidelinesArrows$(STYLENAME).otf
