BUILD_DATA := build_data/dotted.tsv

# Build the patterned fonts...
.PHONY .ONESHELL: patterned-dotted
patterned-dotted:
	# Build dotted
	cat $(BUILD_DATA) | parallel --bar --jobs 7 --colsep '\t' '
		GLYPHS=`find $(FONTFAMILY)-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif` 
		ASTERISK='*'
		DASHDESC="0.00000001 "`perl -e "print {2}$${ASTERISK}1.5"`
		#DASHDESC="5 "`perl -e "print {2}$${ASTERISK}1.5"`
		#DASHDESC="{2} {2}"
		STYLENAME=Dotted{1} WIDTH={2} OS2WEIGHT={3} DASHDESC="$$DASHDESC" GLYPHS="$$GLYPHS" CULLAREA=0.30 make patterned-dotted-template
	'

.PHONY .ONESHELL: patterned-dotted-debug
patterned-dotted-debug:
	make BUILD_DATA=build_data/dotted-debug.tsv patterned-dotted

.PHONY .ONESHELL: patterned-dotted-template
patterned-dotted-template:
	rm -rf build/$(FONTFAMILY)-$(STYLENAME).ufo
	cp -r build/$(FONTFAMILY)-`./scripts/os2weight_to_namedweight.py $(OS2WEIGHT)`.ufo build/$(FONTFAMILY)-$(STYLENAME).ufo
	./scripts/fudge_fontinfo.py build/$(FONTFAMILY)-$(STYLENAME).ufo $(STYLENAME) $(OS2WEIGHT)
	CULLAREA=`perl -e 'use Math::Trig; print pi() * (($(WIDTH) / 2.0) ** 2.0) * $(CULLAREA)'`
	CULLWIDTH=`perl -e 'print $(WIDTH) * 0.65'`
	parallel --bar "MFEKstroke DASH -o build/$(FONTFAMILY)-$(STYLENAME).ufo/glyphs/{/} -i $(FONTFAMILY)-SOURCE.ufo/glyphs/{/} -d $(DASHDESC) -w $(WIDTH) -c -W $$CULLWIDTH -a $$CULLAREA -l" <<< "$$GLYPHS"
	ARGS=`./scripts/fontmake_args.sh`
	$(PYTHON) -m fontmake --keep-overlaps --verbose DEBUG -u build/$(FONTFAMILY)-$(STYLENAME).ufo --output-path dist/$(FONTFAMILY)-$(OS2WEIGHT)-$(STYLENAME).otf -o otf $$ARGS && printf '\033[1;31m Generated $(FONTFAMILY)-$(STYLENAME).ufo\033[0m\n'
	>&2 echo 'Built $(FONTFAMILY)-$(STYLENAME) w/ dash desc == `$(DASHDESC)`'

.PHONY .ONESHELL: patterned-apb
patterned-apb:
	GLYPHS=`find $(FONTFAMILY)-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif` 
	make patterned-template STYLENAME=ArrowPathBold OS2WEIGHT=700 MFEKSTROKE_SCALE=0.4 PATTERN=patterns.ufo/glyphs/arrow2.glif GLYPHS="$$GLYPHS"

.PHONY .ONESHELL: patterned-ap
patterned-ap:
	GLYPHS=`find $(FONTFAMILY)-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif` 
	make patterned-template STYLENAME=ArrowPath OS2WEIGHT=400 MFEKSTROKE_SCALE=0.2 PATTERN=patterns.ufo/glyphs/arrow2.glif GLYPHS="$$GLYPHS"

.PHONY .ONESHELL: patterned-template
patterned-template:
	rm -rf build/$(FONTFAMILY)-$(STYLENAME).ufo
	cp -r build/$(FONTFAMILY)-`./scripts/os2weight_to_namedweight.py $(OS2WEIGHT)`.ufo build/$(FONTFAMILY)-$(STYLENAME).ufo
	./scripts/fudge_fontinfo.py build/$(FONTFAMILY)-$(STYLENAME).ufo $(STYLENAME) $(OS2WEIGHT)
	parallel --bar 'MFEKstroke PAP --out build/$(FONTFAMILY)-$(STYLENAME).ufo/glyphs/{/} --path $(FONTFAMILY)-SOURCE.ufo/glyphs/{/} --pattern $(PATTERN) -m repeated --sx $(MFEKSTROKE_SCALE) --sy $(MFEKSTROKE_SCALE) -s 0 --spacing 15 --overdraw 15%% -Q' <<< "$$GLYPHS"
	ARGS=`./scripts/fontmake_args.sh`
	$(PYTHON) -m fontmake --keep-overlaps --verbose DEBUG -u build/$(FONTFAMILY)-$(STYLENAME).ufo --output-path dist/$(FONTFAMILY)-$(OS2WEIGHT)-$(STYLENAME).otf -o otf $$ARGS && printf '\033[1;31m Generated $(FONTFAMILY)-$(STYLENAME).ufo\033[0m\n'

.PHONY: patterned
patterned:
	make -j3 patterned-dotted patterned-apb patterned-ap
