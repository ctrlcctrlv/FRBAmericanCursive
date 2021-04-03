# Regenerates some feature files, pulls glyphs out of SFD and puts them into UFO. Always use after you edit glyphs in SFD.
.PHONY: regen
regen:
	mkdir -p build dist
	./scripts/tsv_to_mark.py build_data/top.tsv > fea/mark.fea
	./scripts/build_ccmp.py > fea/ccmp.fea
	./scripts/regenerate_ufo_glyphs_from_sfd.py
	# Patterns
	fontforge -lang=py -c 'f=fontforge.open("patterns.sfd");f.generate("patterns.ufo")'
	sfdnormalize patterns.sfd patterns_temp.sfd && mv patterns_temp.sfd patterns.sfd

# Regenerate the OpenType classes used in the feature files. You need this if you add glyphs to the SFD and want them to be shaped properly based on their names.
.PHONY: fee-classes
fee-classes:
	fee2fea dist/FRBAmericanCursive-1000-Ultra.otf fea/classes.fee --omit-gdef > fea/classes.fea
