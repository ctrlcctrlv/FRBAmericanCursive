# Build all the monoline fonts in dist/
.PHONY: monoline
monoline:
	parallel --bar -a build_data/monoline.tsv --colsep '\t' './scripts/prepare_ufo.py {1} {2} {3} && PRODUCTION=$(PRODUCTION) ./scripts/gen_monoline.sh {1} {2} {3}'

# Makes a single monoline font, Regular weight. For debugging.
.PHONY: debug-font
debug-font:
	./scripts/prepare_ufo.py Regular 35 400
	./scripts/gen_monoline.sh Regular 35 400
