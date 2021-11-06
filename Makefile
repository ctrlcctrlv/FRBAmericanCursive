SHELL = /bin/bash
.EXPORT_ALL_VARIABLES:
PRODUCTION := $(if $(PRODUCTION),$(PRODUCTION),n)
FONTFAMILY := FRBAmericanCursive
FONTFAMILY_H := FRB American Cursive
PYTHON := $(if $(PYTHON),$(PYTHON),python3)
GLIF2SVG := glif2svg-rs
PROCESSING := /home/fred/Downloads/processing-4.0b2/processing-java

.ONESHELL: all
all:
	make regen
	make monoline
	make physics
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
clean:
	rm -rf build dist
