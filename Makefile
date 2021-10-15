.EXPORT_ALL_VARIABLES:
PRODUCTION := $(if $(PRODUCTION),$(PRODUCTION),n)
FONTFAMILY := FRBAmericanCursive
FONTFAMILY_H := FRB American Cursive
PYTHON := $(if $(PYTHON),$(PYTHON),python3)

.ONESHELL: all
all:
	make regen
	make monoline
	make patterned
	make colrcpal
	make specimens

include mk/*.mk

.PHONY: dist
dist:
	rm -f $(FONTFAMILY).zip $(FONTFAMILY)\(woff2\).zip
	find dist -iname *.otf | parallel --bar woff2_compress
	zip $(FONTFAMILY).zip dist/*.otf
	zip $(FONTFAMILY)\(woff2\).zip dist/*.woff2
	# Not enough shared tables to be worth it, only `CPAL` and `post`.
	# otf2otc -o dist/$(FONTFAMILY).otc dist/*.otf

.PHONY: clean
	rm -rf build dist
