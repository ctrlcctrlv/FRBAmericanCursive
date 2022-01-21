# ☞ MFEKstroke DASH mode is used to generate dashed and dotted glyphs. If working on a new font, you may want to control the args in `scripts/patterned_args.sh`.

BUILD_DATA := build_data/dotted.tsv
WIDTH_MINIMUM := 50.0

.PHONY .ONESHELL: patterned-dotted
patterned-dotted:
	DASHLEN=0 PREPENDNAME=Dotted $(MAKE) patterned-dotted-dashed

.PHONY .ONESHELL: patterned-dashed
patterned-dashed:
	DASHLEN=20 PREPENDNAME=Dashed $(MAKE) patterned-dotted-dashed

# Build the patterned fonts...
.PHONY .ONESHELL: patterned-dotted-dashed
patterned-dotted-dashed:
	# Build dotted or dashed
	cat $(BUILD_DATA) | parallel --tag --ctag --linebuffer --bar --jobs 7 --colsep '\t' '
		GLYPHS=`find $(FONTFAMILY)-SOURCE.ufo/glyphs/ -type f -iname '*.glif' -and -not -name space.glif` 
		ASTERISK='*'
		WIDTHADJ=`perl -e "\\$$calc = {2}$${ASTERISK}1.5; \\$$calc = (\\$$calc >= $(WIDTH_MINIMUM) ? \\$$calc : $(WIDTH_MINIMUM)); print \\"\\$$calc\\";"`
		CULLAREA=`perl -e "print ({2} >= $(WIDTH_MINIMUM) ? 0.25 : 0.5);"`
		DASHDESC="$(DASHLEN) $$WIDTHADJ"
		#DASHDESC="{2} {2}"
		STYLENAME=$(PREPENDNAME){1} WIDTH={2} CULLWIDTH=$$WIDTHADJ OS2WEIGHT={3} DASHDESC="$$DASHDESC" GLYPHS="$$GLYPHS" CULLAREA=$$CULLAREA $(MAKE) patterned-dotted-template
	'

.PHONY .ONESHELL: patterned-dotted-debug
patterned-dotted-debug:
	$(MAKE) BUILD_DATA=build_data/dotted-debug.tsv patterned-dotted

.PHONY .ONESHELL: patterned-dotted-template
patterned-dotted-template:
	UFO="build/$(FONTFAMILY)-$(STYLENAME).ufo"
	rm -rf "$$UFO"
	cp -r build/$(FONTFAMILY)-`./scripts/os2weight_to_namedweight.py $(OS2WEIGHT)`.ufo "$$UFO"
	./scripts/fudge_fontinfo.py "$$UFO" "$(FONTFAMILY)" "$(FONTFAMILY_H)" $(STYLENAME) $(OS2WEIGHT)
	CULLAREA=`perl -e 'use Math::Trig; print pi() * (($(WIDTH) / 2.0) ** 2.0) * $(CULLAREA)'`
	CULLWIDTHADJ=`perl -e 'print ($(WIDTH_MINIMUM) * 0.9) + ($(WIDTH) >= $(WIDTH_MINIMUM) ? 0 : ($(WIDTH_MINIMUM) - $(WIDTH)) * 2.0)'`
	patterned_ARGS=$$(eval "echo `./scripts/patterned_args.sh`")
	parallel --ctag --linebuffer "MFEKstroke DASH -o $$UFO/glyphs/{/} -i $(FONTFAMILY)-SOURCE.ufo/glyphs/{/} -d $(DASHDESC) -w $(WIDTH) $$patterned_ARGS" <<< "$$GLYPHS"
	fontmake_ARGS=`./scripts/fontmake_args.sh`
	$(PYTHON) -m fontmake --verbose DEBUG -u "$$UFO" --output-path dist/$(FONTFAMILY)-$(OS2WEIGHT)-$(STYLENAME).otf -o otf $$fontmake_ARGS && printf '\033[1;31m Generated '"$$UFO"'\033[0m w/ dash desc == `$(DASHDESC)`'"$$patterned_ARGS"'\n'

.PHONY .ONESHELL: patterned-apb
patterned-apb:
	GLYPHS=`find $(FONTFAMILY)-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif` 
	$(MAKE) patterned-template STYLENAME=ArrowPathBold OS2WEIGHT=700 MFEKSTROKE_SCALE=0.4 PATTERN=patterns.ufo/glyphs/arrow2.glif GLYPHS="$$GLYPHS"

.PHONY .ONESHELL: patterned-ap
patterned-ap:
	GLYPHS=`find $(FONTFAMILY)-SOURCE.ufo/glyphs/ -type f -not -name contents.plist -not -name space.glif` 
	$(MAKE) patterned-template STYLENAME=ArrowPath OS2WEIGHT=400 MFEKSTROKE_SCALE=0.2 PATTERN=patterns.ufo/glyphs/arrow2.glif GLYPHS="$$GLYPHS"

.PHONY .ONESHELL: patterned-template
patterned-template:
	UFO="build/$(FONTFAMILY)-$(STYLENAME).ufo"
	rm -rf "$$UFO"
	cp -r build/$(FONTFAMILY)-`./scripts/os2weight_to_namedweight.py $(OS2WEIGHT)`.ufo "$$UFO"
	./scripts/fudge_fontinfo.py "$$UFO" "$(FONTFAMILY)" "$(FONTFAMILY_H)" $(STYLENAME) $(OS2WEIGHT)
	parallel --bar 'MFEKstroke PAP --out build/$(FONTFAMILY)-$(STYLENAME).ufo/glyphs/{/} --path $(FONTFAMILY)-SOURCE.ufo/glyphs/{/} --pattern $(PATTERN) -m repeated --sx $(MFEKSTROKE_SCALE) --sy $(MFEKSTROKE_SCALE) -s 0 --spacing 15 --overdraw 15%% -Q' <<< "$$GLYPHS"
	ARGS=`./scripts/fontmake_args.sh`
	$(PYTHON) -m fontmake --keep-overlaps --verbose DEBUG -u build/$(FONTFAMILY)-$(STYLENAME).ufo --output-path dist/$(FONTFAMILY)-$(OS2WEIGHT)-$(STYLENAME).otf -o otf $$ARGS && printf '\033[1;31m Generated $(FONTFAMILY)-$(STYLENAME).ufo\033[0m\n'

.PHONY: patterned
patterned:
	$(MAKE) -j4 patterned-dotted patterned-dashed # patterned-apb patterned-ap
