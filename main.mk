SHELL = /bin/bash
.EXPORT_ALL_VARIABLES:
PRODUCTION := $(if $(PRODUCTION),$(PRODUCTION),n)

PYTHON := $(if $(PYTHON),$(PYTHON),python3)
GLIF2SVG := glif2svg-rs
PROCESSING := processing-java
TTFAUTOHINT_FLAGS := -a $(shell cat build_data/$(FONTFAMILY)_ttfautohint-a) -n -W -t -c -p -G 48
AFDKO_ENV_ACTIVATE := /home/fred/Workspace/afdko/afdko_env/bin/activate
MAKE := $(MAKE) -f main.mk

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
