# Build all the monoline fonts in dist/
.PHONY: monoline
monoline:
	parallel --bar -a build_data/monoline.tsv --colsep '\t' '
		UFO="build/$(FONTFAMILY)-{1}.ufo"
		./scripts/prepare_ufo.py {1} {3}
		./scripts/fudge_fontinfo.py "$$UFO" "$(FONTFAMILY)" "$(FONTFAMILY_H)" {1} {3}
		PRODUCTION=$(PRODUCTION) ./scripts/gen_monoline.sh {1} {2} {3} $(FONTFAMILY)
	'

# Makes a single monoline font, Regular weight. For debugging.
.PHONY: debug-font
debug-font:
	./scripts/prepare_ufo.py Regular 400
	UFO="build/$(FONTFAMILY)-Regular.ufo"
	./scripts/fudge_fontinfo.py "$$UFO" "$(FONTFAMILY)" "$(FONTFAMILY_H)" Regular 400
	./scripts/gen_monoline.sh Regular 35 400 $(FONTFAMILY)
