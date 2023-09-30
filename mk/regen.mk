.PHONY: regen
regen:
	mkdir -p build dist
	$(MAKE) UFO=$(FONTFAMILY)-SOURCE.ufo glifjson2glif
	$(MAKE) rebuild-ccmp
	# OpenType GDEF table
	$(MAKE) rebuild-gdef
	$(MAKE) rebuild-marks
	$(MAKE) rebuild-stroke-count
	$(MAKE) fez-classes
	$(MAKE) rebuild-tailsfea

.PHONY: rebuild-ccmp
rebuild-ccmp:
	./scripts/build_ccmp.py $(FONTFAMILY)-SOURCE.ufo build/BUILD.ufo > fea/ccmp.fea
	for f in numbers.ufo/glyphs/__combstroke[123456789]*.glif; do cp "$$f" build/BUILD.ufo/glyphs/; done
	for f in numbers.ufo/glyphs/*.glif; do glif2svg-rs -M "$$f" "$${f$(PERCENT)$(PERCENT).glif}.svg"; done
	./scripts/regen_glyphs_plist.py build/BUILD.ufo/glyphs

.PHONY: rebuild-gdef
rebuild-gdef:
	./scripts/make_GDEF.py build/BUILD.ufo > fea/GDEF.fea

.PHONY: rebuild-tailsfea
rebuild-tailsfea:
	./scripts/tails_fea.py > fea/tails.fea

.PHONY: glif-refigure
glif-refigure:
	if [[ -z '$(UFO)' ]]; then UFO='$(UFO)'; else UFO=$(FONTFAMILY)-SOURCE.ufo; fi
	if [[ -z '$(QUIET)' ]]; then BAR='--ctag --linebuffer --bar'; else BAR=''; fi
	find "$$UFO"/glyphs/ -iname '*.glif' | parallel $$BAR "MFEKpathops REFIGURE -1 -i {}"

.PHONY: glifjson2glif
glifjson2glif:
	if [[ -n '$(UFO)' ]]; then UFO='$(UFO)'; else UFO=$(FONTFAMILY)-SOURCE.ufo; fi
	rm "$$UFO"/glyphs/*.glif
	find "$$UFO"/glyphs/ -iname '*.glifjson' | parallel --bar "RUST_LOG=error MFEKglif --flatten --no-contour-ops {}"

.PHONY: rebuild-marks
rebuild-marks:
	rm -f fea/mark.fea
	touch mark.fea
	for class in `cat build_data/$(FONTFAMILY)_mark_classes.tsv`; do
		if [[ ! -f build_data/$$class.tsv ]]; then continue; fi
		./scripts/tsv_to_mark.py build_data/$$class.tsv >> fea/mark.fea
		./scripts/add_marks_from_data.py build/BUILD.ufo $$class
	done

.PHONY: rebuild-stroke-count
rebuild-stroke-count:
	./scripts/stroke_count_fea.sh > fea/strokes.fea

.PHONY: fez-classes
fez-classes:
	$(MAKE) FEZ=fea/classes.fez FEA=fea/classes.fea fez-source

.ONESHELL .PHONY: fez-source
fez-source:
	if [[ -z '$(UFO)' ]]; then
		UFO='$(FONTFAMILY)-SOURCE.ufo'
	else
		UFO='$(UFO)'
	fi
	TEMPUFO=`mktemp -u -d --suffix _fezinput.ufo`
	TEMPOTF=`mktemp --suffix _fezinput.otf`
	cp -r "$$UFO" "$$TEMPUFO"
	rm "$$TEMPUFO"/features.fea
	fontmake --verbose DEBUG -S --keep-overlaps -u "$$TEMPUFO" -o otf --output-path "$$TEMPOTF"
	rm -rf "$$TEMPUFO"
	fez2fea "$$TEMPOTF" '$(FEZ)' --omit-gdef > '$(FEA)'
	rm "$$TEMPOTF"
