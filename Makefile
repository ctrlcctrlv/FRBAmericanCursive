PRODUCTION := $(if $(PRODUCTION),$(PRODUCTION),n)

.ONESHELL: all
all:
	make regen
	make monoline
	make svgs
	make patterned
	make colrcpal
	make specimens

include mk/*.mk

.PHONY: dist
dist:
	rm -f FRBAmericanCursive.zip FRBAmericanCursive\(woff2\).zip
	find dist -iname *.otf | parallel --bar woff2_compress
	zip FRBAmericanCursive.zip dist/*.otf
	zip FRBAmericanCursive\(woff2\).zip dist/*.woff2
	# Not enough shared tables to be worth it, only `CPAL` and `post`.
	# otf2otc -o dist/FRBAmericanCursive.otc dist/*.otf

.PHONY: clean
	rm -rf build dist
