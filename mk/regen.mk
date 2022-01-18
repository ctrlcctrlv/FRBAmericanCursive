.PHONY: regen
regen:
	mkdir -p build dist
	$(MAKE) UFO=$(FONTFAMILY)-SOURCE.ufo glifjson2glif
	cp $(FONTFAMILY)-SOURCE.ufo/metainfo.plist build/BUILD.ufo/metainfo.plist
	MFEKmetadata $(FONTFAMILY)-SOURCE.ufo write_metainfo
	MFEKmetadata build/BUILD.ufo write_metainfo
	./scripts/build_ccmp.py $(FONTFAMILY)-SOURCE.ufo build/BUILD.ufo > fea/ccmp.fea
	for f in numbers.ufo/glyphs/__combstroke[123456789]*.glif; do cp "$$f" build/BUILD.ufo/glyphs/; done
	./scripts/regen_glyphs_plist.py build/BUILD.ufo/glyphs
	$(MAKE) rebuild-marks
	# OpenType GDEF table
	$(MAKE) rebuild-gdef
	$(MAKE) UFO=build/BUILD.ufo glif-refigure
	$(MAKE) regen-stroke-count
	$(MAKE) fez-classes

.PHONY: rebuild-gdef
rebuild-gdef:
	./scripts/make_GDEF.py build/BUILD.ufo > fea/GDEF.fea

.PHONY: glif-refigure
glif-refigure:
	if [[ -z '$(UFO)' ]]; then UFO='$(UFO)'; else UFO=$(FONTFAMILY)-SOURCE.ufo; fi
	find "$$UFO"/glyphs/ -iname '*.glif' | parallel --bar "MFEKpathops REFIGURE -i {}"

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

.PHONY: regen-stroke-count
regen-stroke-count:
	./scripts/stroke_count_fea.sh > fea/strokes.fea

.PHONY: regen-patterns-and-numbers-from-fontforge-files
regen-patterns-and-numbers-from-fontforge-files:
	# Patterns
	fontforge -lang=py -c 'f=fontforge.open("patterns.sfd");f.generate("patterns.ufo")'
	sfdnormalize patterns.sfd patterns_temp.sfd && mv patterns_temp.sfd patterns.sfd
	# Numbers
	fontforge -lang=py -c 'f=fontforge.open("numbers.sfd");f.generate("numbers.ufo")'
	sfdnormalize numbers.sfd numbers_temp.sfd && mv numbers_temp.sfd numbers.sfd

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
