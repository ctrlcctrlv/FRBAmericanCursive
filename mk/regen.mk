.PHONY: regen
regen:
	mkdir -p build dist
	./scripts/build_ccmp.py $(FONTFAMILY)-SOURCE.ufo build/BUILD.ufo > fea/ccmp.fea
	for f in numbers.ufo/glyphs/__combstroke[0123456789].glif; do cp "$$f" build/BUILD.ufo/glyphs/; done
	./scripts/regen_glyphs_plist.py build/BUILD.ufo/glyphs
	./scripts/make_GDEF.py build/BUILD.ufo > fea/GDEF.fea
	./scripts/tsv_to_mark.py build_data/top.tsv > fea/mark.fea
	./scripts/stroke_count_fea.sh > fea/strokes.fea

.PHONY: regen-from-deprecated-fontforge-files
regen-from-deprecated-fontforge-files:
	./scripts/regenerate_ufo_glyphs_from_sfd.py
	# Patterns
	fontforge -lang=py -c 'f=fontforge.open("patterns.sfd");f.generate("patterns.ufo")'
	sfdnormalize patterns.sfd patterns_temp.sfd && mv patterns_temp.sfd patterns.sfd

.PHONY: fez-classes
fez-classes:
	rm -rf /tmp/fezinput.ufo
	cp -r $(FONTFAMILY)-SOURCE.ufo/ /tmp/fezinput.ufo
	rm /tmp/fezinput.ufo/features.fea
	fontmake --keep-overlaps -u /tmp/fezinput.ufo -o otf --output-path build/fezinput.otf
	rm -rf /tmp/fezinput.ufo
	fez2fea build/fezinput.otf fea/classes.fez --omit-gdef > fea/classes.fea
