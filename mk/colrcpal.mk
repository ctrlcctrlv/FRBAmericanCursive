# COLR/CPAL font generation

PERCENT := %
.PHONY: colrglyphs
colrglyphs:
	if [[ -n '$(SKIP_COLRGLYPHS)' ]]; then exit 0; fi
	set -- `MFEKmetadata $(FONTFAMILY)-SOURCE.ufo arbitrary -k capHeight -k openTypeOS2TypoDescender -k xHeight`
	./scripts/list_glyphs.py $(FONTFAMILY)-SOURCE.ufo | C=$$1 D=$$2 X=$$3 parallel --ctag --linebuffer --bar --jobs 1000$(PERCENT) './scripts/make_COLRglyphs_for_glyph.py {} $(FONTFAMILY)-SOURCE.ufo $$C $$D $$X'

.PHONY: colrglyphs-ufo
colrglyphs-ufo:
	if [[ -n '$(SKIP_COLRGLYPHS_UFO)' ]]; then exit 0; fi
	parallel -u -a build_data/colrcpal_fontlist.tsv --colsep '\t' '
	rm -fr build/$(FONTFAMILY)-{1}.ufo/{COLR_glyphs,arrow_glyphs}
	mkdir -p build/$(FONTFAMILY)-{1}.ufo/{COLR_glyphs,arrow_glyphs}
	MAXLEN=`./scripts/make_arrow_glyph.py MAXLEN`
	[[ -f build_data/arrow_$$MAXLEN.glif ]] || cp `./scripts/make_arrow_glyph.py $$MAXLEN` build_data/arrow_$$MAXLEN.glif;
	grep -rl "<point" $(FONTFAMILY)-SOURCE.ufo/glyphs/*.glif | parallel -I^ --ctag --linebuffer --bar --jobs 250$(PERCENT) '\''./scripts/make_arrows_for_glyph.py ^ build/$(FONTFAMILY)-{1}.ufo/COLR_glyphs/`basename -s.glif ^`_arrows.glif {2}'\''
	'
	#xidel --input-format xml build/arrow_glyphs/*.glif -e '//point[1]/join((replace(replace(file:name($$path), "\.glif$$", ""), "([A-Z])_", "$$1"), round(number(@x)), round(number(@y)), x"stroke{position()}"), '$$'"\t"'')' --silent > build_data/strokes.tsv
	#./scripts/tsv_to_mark.py build_data/strokes.tsv >> fea/mark.fea

# Build the color fonts.
.PHONY: colrcpal
colrcpal:
	if [ ! -d "build/$(FONTFAMILY)_COLR_glyphs" ]; then $(MAKE) colrglyphs colrglyphs-ufo; fi # may have been made by physics
	parallel --bar -a build_data/colrcpal_fontlist.tsv --colsep '\t' '
		$(MAKE) STYLENAME={1} OS2WEIGHT={3} one-colrcpal
	'

.PHONY: one-colrcpal
one-colrcpal:
	if [ ! -d "build/$(FONTFAMILY)_COLR_glyphs" ]; then $(MAKE) colrglyphs colrglyphs-ufo; fi # may have been made by physics
	./scripts/make_combined_without_colr_cpal.sh $(FONTFAMILY)-$(STYLENAME).ufo $(OS2WEIGHT)
	./scripts/combine_colr_cpal.py dist/$(FONTFAMILY)-$(OS2WEIGHT)-GuidelinesArrows$(STYLENAME)_NOVF.otf build/$(FONTFAMILY)-$(STYLENAME).ufo
	if [[ -f build_data/$(FONTFAMILY)_buildVF ]]; then
		./scripts/combine_colr_cpal.py dist/$(FONTFAMILY)-$(OS2WEIGHT)-GuidelinesArrows$(STYLENAME).otf build/$(FONTFAMILY)-$(STYLENAME).ufo
		./scripts/rewrite_feature_substitutions.py dist/$(FONTFAMILY)-$(OS2WEIGHT)-GuidelinesArrows$(STYLENAME).otf
	fi

.PHONY: debug-colrcpal
debug-colrcpal:
	$(MAKE) STYLENAME=Regular OS2WEIGHT=400 one-colrcpal
