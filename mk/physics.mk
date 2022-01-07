.PHONY: physics-files-per-ufo
physics-files-per-ufo:
	rm -fr build/$(UFO)/physics_SVGs
	mkdir -p build/$(UFO)/physics_SVGs
	ls build/$(UFO)/glyphs/*.glif | parallel '$(GLIF2SVG) -o build/$(UFO)/physics_SVGs/{/.}.svg {}'
	ls build/$(UFO)/COLR_glyphs/*_arrows.glif | parallel --bar '$(GLIF2SVG) --fontinfo=build/BUILD.ufo/fontinfo.plist -o build/$(UFO)/physics_SVGs/{/.}.svg {}'
	ls build/$(UFO)/arrow_glyphs/*.glif | parallel --bar '$(GLIF2SVG) --fontinfo=build/BUILD.ufo/fontinfo.plist -o build/$(UFO)/physics_SVGs/{/.}_internal.svg {}'

.PHONY: physics-files
physics-files:
	rm -fr build/$(FONTFAMILY)_physics_SVGs
	mkdir -p build/$(FONTFAMILY)_physics_SVGs
	ls build/BUILD.ufo/glyphs/*.glif | parallel --bar '$(GLIF2SVG) -o build/$(FONTFAMILY)_physics_SVGs/{/.}_internal.svg {}'
	parallel --bar -a build_data/monoline.tsv --colsep '\t' 'make UFO=$(FONTFAMILY)-{1}.ufo physics-files-per-ufo'

.PHONY: all-physics-files
all-physics-files:
	make colrglyphs colrglyphs-ufo
	make physics-files

FORCE := $(if $(FORCE),$(FORCE),n)

.PHONY: compile-processing
compile-processing:
ifeq ($(FORCE),y)
	rm -rf /tmp/AnchorPhysics
endif
	$(PROCESSING) --sketch=$$PWD/scripts/AnchorPhysics --output=/tmp/AnchorPhysics --export

.PHONY: processing-physics
processing-physics:
	# $(PROCESSING) --no-java --sketch=../../scripts/AnchorPhysics --run | sed -e "/^Finished\./d" > "$$TEMPTSV";
	JOBS=`wc -l < build_data/monoline.tsv`
	[[ ! -d /tmp/AnchorPhysics ]] && make compile-processing
	cat build_data/monoline$(DEBUG).tsv | sort -r | parallel -u --jobs $$JOBS --colsep '\t' '
	cd build/$(FONTFAMILY)-{1}.ufo;
	TEMPTSV=/tmp/$(FONTFAMILY)-{1}-physics.tsv;
	echo Writing "$$TEMPTSV";
	grep -rl "point" ../../$(FONTFAMILY)-SOURCE.ufo/glyphs/*.glif | xargs basename -a -s.glif | sort > glyphs.txt;
	test -z "$(SKIP_PROCESSING)" && (/tmp/AnchorPhysics/AnchorPhysics | sed -e "/^Finished\./d" > "$$TEMPTSV");
	$(PYTHON) ../../scripts/tsv_to_mark.py "$$TEMPTSV" > strokes_mark.fea;
	'

.PHONY: physics
physics:
	make all-physics-files
	make processing-physics
