SHELL = /bin/bash
.EXPORT_ALL_VARIABLES:
PRODUCTION := $(if $(PRODUCTION),$(PRODUCTION),n)
#FONTFAMILY := FRBAmericanPrint
#FONTFAMILY_H := FRB American Print
FONTFAMILY := FRBAmericanCursive
FONTFAMILY_H := FRB American Cursive
PYTHON := $(if $(PYTHON),$(PYTHON),python3)
GLIF2SVG := glif2svg-rs
PROCESSING := /home/fred/Downloads/processing-4.0b2/processing-java
TTFAUTOHINT_FLAGS := -a $(shell cat build_data/$(FONTFAMILY)_ttfautohint-a) -n -x 24 -t -c

.PHONY .ONESHELL: all
all:
	$(MAKE) regen
	$(MAKE) monoline
	$(MAKE) patterned
	$(MAKE) physics
	$(MAKE) colrcpal
	$(MAKE) just
	$(MAKE) specimens
	$(MAKE) dist

include mk/*.mk

.PHONY: clean
clean:
	rm -rf build dist
