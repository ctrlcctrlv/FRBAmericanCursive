# Build all the monoline fonts in dist/
.PHONY: monoline
monoline:
	parallel --tag --ctag --linebuffer --bar -a build_data/monoline$(MONOLINE_SUFFIX).tsv --colsep '\t' '
		UFO="build/$(FONTFAMILY)-{1}.ufo"
		./scripts/prepare_ufo.py {1} {3}
		cp fea/$(FONTFAMILY)_features.fea "$$UFO"/features.fea
		./scripts/reset_features_include_path.py "$$UFO" $(FONTFAMILY)-{1}.ufo
		./scripts/fudge_fontinfo.py "$$UFO" "$(FONTFAMILY)" "$(FONTFAMILY_H)" {1} {3}
		PRODUCTION=$(PRODUCTION) ./scripts/gen_monoline.sh {1} {2} {3} $(FONTFAMILY)
	'

# Makes a single monoline font, Regular weight. For debugging.
.PHONY: debug-font
debug-font:
	$(MAKE) MONOLINE_SUFFIX=_debug monoline
