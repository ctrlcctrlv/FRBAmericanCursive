# Build the patterned fonts...
.PHONY .ONESHELL: patterned-dotted
patterned-dotted:
	# Build dotted
	cat build_data/dotted.tsv | parallel --colsep '\t' '
		GLYPHS=`find FRBAmericanCursive-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif` 
		make patterned-template STYLENAME=Dotted{1} OS2WEIGHT={3} MFEKSTROKE_SCALE={2} PATTERN=patterns.ufo/glyphs/dot.glif GLYPHS="$$GLYPHS"
	'

.PHONY .ONESHELL: patterned-apb
patterned-apb:
	GLYPHS=`find FRBAmericanCursive-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif` 
	make patterned-template STYLENAME=ArrowPathBold OS2WEIGHT=700 MFEKSTROKE_SCALE=0.4 PATTERN=patterns.ufo/glyphs/arrow2.glif GLYPHS="$$GLYPHS"

.PHONY .ONESHELL: patterned-ap
patterned-ap:
	GLYPHS=`find FRBAmericanCursive-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif` 
	make patterned-template STYLENAME=ArrowPath OS2WEIGHT=400 MFEKSTROKE_SCALE=0.2 PATTERN=patterns.ufo/glyphs/arrow2.glif GLYPHS="$$GLYPHS"

.PHONY .ONESHELL: patterned-template
patterned-template:
	rm -rf build/FRBAmericanCursive-$(STYLENAME).ufo
	cp -r build/FRBAmericanCursive-Regular.ufo build/FRBAmericanCursive-$(STYLENAME).ufo
	./scripts/fudge_fontinfo.py build/FRBAmericanCursive-$(STYLENAME).ufo $(STYLENAME) $(OS2WEIGHT)
	parallel --bar 'MFEKstroke PAP --out build/FRBAmericanCursive-$(STYLENAME).ufo/glyphs/{/} --path FRBAmericanCursive-SOURCE.ufo/glyphs/{/} --pattern $(PATTERN) -m repeated --sx $(MFEKSTROKE_SCALE) --sy $(MFEKSTROKE_SCALE) -s 1 --spacing 15 --stretch true' <<< "$$GLYPHS"
	ARGS=`./scripts/fontmake_args.sh`
	pypy3 -m fontmake --verbose DEBUG -u build/FRBAmericanCursive-$(STYLENAME).ufo --output-path dist/FRBAmericanCursive-$(OS2WEIGHT)-$(STYLENAME).otf -o otf $$ARGS

.PHONY .ONESHELL: patterned-guidance
patterned-guidance:
	# Build guidance
	# This kludge fixes MFEK/stroke#8 (GitHub)
	GLYPHS=`find FRBAmericanCursive-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif -not -name t.high.glif -not -name cyr_hard_sign.finahigh.glif`
	rm -rf build/FRBAmericanCursive-Guidance.ufo
	cp -r build/FRBAmericanCursive-Regular.ufo build/FRBAmericanCursive-Guidance.ufo
	./scripts/fudge_fontinfo.py build/FRBAmericanCursive-Guidance.ufo Guidance 400
	parallel --bar MFEKstroke PAP --out build/FRBAmericanCursive-Guidance.ufo/glyphs/{/} --path FRBAmericanCursive-SOURCE.ufo/glyphs/{/} --pattern patterns.ufo/glyphs/arrow.glif -m repeated --sx 0.1 --sy 0.1 -s 3 --simplify true --stretch true <<< "$$GLYPHS"
	parallel --bar MFEKstroke PAP --out build/FRBAmericanCursive-Guidance.ufo/glyphs/{/} --path FRBAmericanCursive-SOURCE.ufo/glyphs/{/} --pattern patterns.ufo/glyphs/arrow.glif -m repeated --sx 0.1 --sy 0.1 -s 3 --simplify false --stretch true <<< `printf "t.high.glif\ncyr_hard_sign.finahigh.glif"`
	./scripts/correct_direction_and_simplify.py Guidance
	ARGS=`./scripts/fontmake_args.sh`
	pypy3 -m fontmake --verbose DEBUG -u build/FRBAmericanCursive-Guidance.ufo --output-path dist/FRBAmericanCursive-400-Guidance.otf -o otf $$ARGS

.PHONY: patterned
patterned:
	make -j4 patterned-guidance patterned-apb patterned-ap patterned-dotted
