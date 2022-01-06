.PHONY: regen
regen:
	mkdir -p build dist
	./scripts/regen_glyphs_plist.py $(FONTFAMILY)-SOURCE.ufo/glyphs
	./scripts/build_ccmp.py $(FONTFAMILY)-SOURCE.ufo build/BUILD.ufo > fea/ccmp.fea
	for f in numbers.ufo/glyphs/__combstroke[0123456789].glif; do cp "$$f" build/BUILD.ufo/glyphs/; done
	./scripts/regen_glyphs_plist.py build/BUILD.ufo/glyphs
	make rebuild-marks
	# OpenType GDEF table
	./scripts/make_GDEF.py build/BUILD.ufo > fea/GDEF.fea
	make regen-stroke-count
	make fez-classes

.PHONY: rebuild-marks
rebuild-marks:
	./scripts/tsv_to_mark.py build_data/top.tsv > fea/mark.fea
	./scripts/tsv_to_mark.py build_data/bottom.tsv >> fea/mark.fea
	./scripts/tsv_to_mark.py build_data/viethorn.tsv >> fea/mark.fea
	./scripts/add_marks_from_data.py build/BUILD.ufo top
	./scripts/add_marks_from_data.py build/BUILD.ufo bottom
	./scripts/add_marks_from_data.py build/BUILD.ufo viethorn

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
	rm -rf /tmp/fezinput.ufo
	cp -r $(FONTFAMILY)-SOURCE.ufo/ /tmp/fezinput.ufo
	rm /tmp/fezinput.ufo/features.fea
	fontmake --keep-overlaps -u /tmp/fezinput.ufo -o otf --output-path build/fezinput.otf
	rm -rf /tmp/fezinput.ufo
	fez2fea build/fezinput.otf fea/classes.fez --omit-gdef > fea/classes.fea
