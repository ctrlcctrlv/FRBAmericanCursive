SHELL = /bin/bash
.EXPORT_ALL_VARIABLES:
PRODUCTION := $(if $(PRODUCTION),$(PRODUCTION),n)

#FONTFAMILY := FRBAmericanPrint
#FONTFAMILY_H := FRB American Print
#REGULAR_IS_ITALIC := 0

FONTFAMILY := FRBAmericanCursive
FONTFAMILY_H := FRB American Cursive
REGULAR_IS_ITALIC := 1

PYTHON := $(if $(PYTHON),$(PYTHON),python3)
GLIF2SVG := glif2svg-rs
PROCESSING := /home/fred/Downloads/processing-4.0b2/processing-java
TTFAUTOHINT_FLAGS := -a $(shell cat build_data/$(FONTFAMILY)_ttfautohint-a) -n -W -t -c -p -G 48
AFDKO_ENV_ACTIVATE := /home/fred/Workspace/afdko/afdko_env/bin/activate

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
