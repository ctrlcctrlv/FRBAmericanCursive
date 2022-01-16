.PHONY: regen
regen:
	mkdir -p build dist
	./scripts/regen_glyphs_plist.py $(FONTFAMILY)-SOURCE.ufo/glyphs
	./scripts/build_ccmp.py $(FONTFAMILY)-SOURCE.ufo build/BUILD.ufo > fea/ccmp.fea
	for f in numbers.ufo/glyphs/__combstroke[12345678]*.glif; do cp "$$f" build/BUILD.ufo/glyphs/; done
	./scripts/regen_glyphs_plist.py build/BUILD.ufo/glyphs
	find build/BUILD.ufo/glyphs/*.glif | parallel --bar "MFEKpathops REFIGURE -i {}"
	make rebuild-marks
	# OpenType GDEF table
	./scripts/make_GDEF.py build/BUILD.ufo > fea/GDEF.fea
	make regen-stroke-count
	make fez-classes

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
	make FEZ=fea/classes.fez FEA=fea/classes.fea fez-source

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
