.ONESHELL: all
all:
	make regen
	make monoline
	make svgs
	make patterned
	make colrcpal
	make specimens
	#
	find dist -type f|parallel --bar python3 -m cffsubr -o {}_cffsubr {}
	find dist -type f -iname "*.otf"|parallel --bar mv {}_cffsubr {}
	rm -f FRBAmericanCursive.zip
	zip FRBAmericanCursive.zip dist/*

# Regenerates some feature files, pulls glyphs out of SFD and puts them into UFO. Always use after you edit glyphs in SFD.
.PHONY: regen
regen:
	mkdir -p build
	./scripts/tsv_to_mark.py build_data/top.tsv > fea/mark.fea
	./scripts/build_ccmp.py > fea/ccmp.fea
	./scripts/regenerate_ufo_glyphs_from_sfd.py

# Build all the monoline fonts in dist/
.PHONY: monoline
monoline:
	parallel --bar -a build_data/monoline.tsv --colsep '\t' './scripts/gen_weight.py {1} {2} {3} && PRODUCTION=y ./scripts/gen_monoline.sh {1} {3}'

# Regenerate the OpenType classes used in the feature files. You need this if you add glyphs to the SFD and want them to be shaped properly based on their names.
.PHONY: fee-classes
fee-classes:
	fee2fea dist/FRBAmericanCursive-1000-Ultra.otf fea/classes.fee --omit-gdef > fea/classes.fea

# Makes a single monoline font, Regular weight. For debugging.
.PHONY: debug-font
debug-font:
	make regen
	./scripts/gen_weight.py Regular 35 400
	./scripts/gen_monoline.sh Regular 400

# Build all the SVG data we need to build the color version of the font.
.PHONY: svgs
svgs:
	rm -rf build/SVG_{layers,ml}
	mkdir -p build/SVG_{layers,ml}
	./scripts/list_glyphs.py FRBAmericanCursive.sfd | parallel --bar ./scripts/make_multilayer_svg_from_glyph.py {} '>' build/SVG_ml/{}.svg
	find build/SVG_ml -type f | parallel --bar ./scripts/split_svg.sh {}
	find build/SVG_ml/ -iname "*_arrows.svg" -or -iname "*_beginnings.svg" -or -iname "*_endings.svg" -or -iname "*_guidelines.svg" -or -iname "*_path.svg" | xargs -I{} mv {} build/SVG_layers/
	inkscape --batch-process --actions "select-all:all;verb:StrokeToPath;select-all;verb:SelectionUnion;export-plain-svg;" --export-overwrite build/SVG_layers/*

# Build the color fonts.
.PHONY: colrcpal
colrcpal:
	./scripts/svgs_to_COLRglyphs_dir.py
	find . -iwholename ./build/FRBAmericanCursive-'*'.ufo -type d -not -iwholename '*glyphs*'|sed 's@./build/FRBAmericanCursive-@@'|sed 's/\.ufo$$//' | parallel --bar '
	./scripts/make_combined_without_colr_cpal.sh FRBAmericanCursive-{}.ufo
	./scripts/combine_colr_cpal.py dist/FRBAmericanCursive-GuidelinesArrows{}.otf build/FRBAmericanCursive-{}.ufo
	'

# Build the patterned fonts...
.PHONY .ONESHELL: patterned-dotted
patterned-dotted:
	# Build dotted
	cat build_data/dotted.tsv | parallel --colsep '\t' '
		GLYPHS=`find FRBAmericanCursive-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif`
		rm -rf build/FRBAmericanCursive-Dotted{1}.ufo
		cp -r build/FRBAmericanCursive-{1}.ufo build/FRBAmericanCursive-Dotted{1}.ufo
		./scripts/fudge_fontinfo.py build/FRBAmericanCursive-Dotted{1}.ufo Dotted{1} 400
		parallel --basenamereplace ,, --bar MFEKstroke --out build/FRBAmericanCursive-Dotted{1}.ufo/glyphs/,, --path FRBAmericanCursive-SOURCE.ufo/glyphs/,, --pattern patterns.ufo/glyphs/dot.glif -m repeated --sx {2} --sy {2} -s 1 --spacing 15 --stretch true <<< "$$GLYPHS"
		./scripts/gen_monoline.sh Dotted{1} {3}
	'

.PHONY .ONESHELL: patterned-apb
patterned-apb:
	# Build arrow path
	rm -rf build/FRBAmericanCursive-ArrowPathBold.ufo
	cp -r build/FRBAmericanCursive-Regular.ufo build/FRBAmericanCursive-ArrowPathBold.ufo
	./scripts/fudge_fontinfo.py build/FRBAmericanCursive-ArrowPathBold.ufo ArrowPathBold 400
	parallel --bar MFEKstroke --out build/FRBAmericanCursive-ArrowPathBold.ufo/glyphs/{/} --path FRBAmericanCursive-SOURCE.ufo/glyphs/{/} --pattern patterns.ufo/glyphs/arrow2.glif -m repeated --sx 0.4 --sy 0.4 -s 1 --spacing 15 --stretch true <<< "$$GLYPHS"
	./scripts/gen_monoline.sh ArrowPathBold 700

.PHONY .ONESHELL: patterned-ap
patterned-ap:
	rm -rf build/FRBAmericanCursive-ArrowPath.ufo
	cp -r build/FRBAmericanCursive-Regular.ufo build/FRBAmericanCursive-ArrowPath.ufo
	./scripts/fudge_fontinfo.py build/FRBAmericanCursive-ArrowPath.ufo ArrowPath 400
	parallel --bar MFEKstroke --out build/FRBAmericanCursive-ArrowPath.ufo/glyphs/{/} --path FRBAmericanCursive-SOURCE.ufo/glyphs/{/} --pattern patterns.ufo/glyphs/arrow2.glif -m repeated --sx 0.2 --sy 0.2 -s 1 --spacing 15 --stretch true <<< "$$GLYPHS"
	./scripts/gen_monoline.sh ArrowPath 400

# Currently not used.
.PHONY .ONESHELL: patterned-pencil
patterned-pencil:
	GLYPHS=`find FRBAmericanCursive-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif`
	rm -rf build/FRBAmericanCursive-Pencil.ufo
	cp -r build/FRBAmericanCursive-Regular.ufo build/FRBAmericanCursive-Pencil.ufo
	./scripts/fudge_fontinfo.py build/FRBAmericanCursive-Pencil.ufo Pencil 400
	parallel --bar MFEKstroke --out build/FRBAmericanCursive-Pencil.ufo/glyphs/{/} --path FRBAmericanCursive-SOURCE.ufo/glyphs/{/} --pattern patterns.ufo/glyphs/pencil.glif -m repeated --sx 0.4 --sy 0.4 -s 3 --stretch true <<< "$$GLYPHS"
	./scripts/correct_direction_and_simplify.py Pencil
	./scripts/gen_monoline.sh Pencil 400

.PHONY .ONESHELL: patterned-guidance
patterned-guidance:
	# Build guidance
	# This kludge fixes MFEK/stroke#8 (GitHub)
	GLYPHS=`find FRBAmericanCursive-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif -not -name t.high.glif -not -name cyr_hard_sign.finahigh.glif`
	rm -rf build/FRBAmericanCursive-Guidance.ufo
	cp -r build/FRBAmericanCursive-Regular.ufo build/FRBAmericanCursive-Guidance.ufo
	./scripts/fudge_fontinfo.py build/FRBAmericanCursive-Guidance.ufo Guidance 400
	parallel --bar MFEKstroke --out build/FRBAmericanCursive-Guidance.ufo/glyphs/{/} --path FRBAmericanCursive-SOURCE.ufo/glyphs/{/} --pattern patterns.ufo/glyphs/arrow.glif -m repeated --sx 0.1 --sy 0.1 -s 3 --simplify true --stretch true <<< "$$GLYPHS"
	parallel --bar MFEKstroke --out build/FRBAmericanCursive-Guidance.ufo/glyphs/{/} --path FRBAmericanCursive-SOURCE.ufo/glyphs/{/} --pattern patterns.ufo/glyphs/arrow.glif -m repeated --sx 0.1 --sy 0.1 -s 3 --simplify false --stretch true <<< `printf "t.high.glif\ncyr_hard_sign.finahigh.glif"`
	./scripts/correct_direction_and_simplify.py Guidance
	./scripts/gen_monoline.sh Guidance 400

.PHONY: patterned
patterned:
	GLYPHS=`find FRBAmericanCursive-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif` make -j4 patterned-guidance patterned-apb patterned-ap patterned-dotted

# Build specimens.
.PHONY: specimens
specimens:
	./scripts/letter_combos.py > specimens/combos.sil
	sile specimens/combos.sil
	./scripts/each_font_specimen.sh
	for f in dist/*; do hb-view -o /tmp/`basename "$$f"`.png "$$f" 'FRB American Cursive: Hello!'; done
	convert -append /tmp/FRBAmericanCursive-100-Thin.otf.png /tmp/FRBAmericanCursive-500-Medium.otf.png /tmp/FRBAmericanCursive-800-Extrabold.otf.png /tmp/FRBAmericanCursive-GuidelinesArrowPathBold.otf.png /tmp/FRBAmericanCursive-GuidelinesArrowsArrowPathBold.otf.png /tmp/FRBAmericanCursive-GuidelinesArrowsDottedMedium.otf.png /tmp/FRBAmericanCursive-GuidelinesDottedMedium.otf.png /tmp/FRBAmericanCursive-GuidelinesUltra.otf.png /tmp/FRBAmericanCursive-GuidelinesGuidance.otf.png specimens/hello.png
