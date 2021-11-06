.PHONY: physics-files-per-ufo
physics-files-per-ufo:
	rm -r build/$(UFO)/physics_SVGs
	mkdir -p build/$(UFO)/physics_SVGs
	ls build/$(UFO)/glyphs/*.glif | parallel '$(GLIF2SVG) -o build/$(UFO)/physics_SVGs/{/.}.svg {}'
	ls build/$(UFO)/COLR_glyphs/*_arrows.glif | parallel --bar '$(GLIF2SVG) --fontinfo=build/BUILD.ufo/fontinfo.plist -o build/$(UFO)/physics_SVGs/{/.}.svg {}'
	ls build/$(UFO)/arrow_glyphs/*.glif | parallel --bar '$(GLIF2SVG) --fontinfo=build/BUILD.ufo/fontinfo.plist -o build/$(UFO)/physics_SVGs/{/.}_internal.svg {}'

.PHONY: physics-files
physics-files:
	rm -r build/physics_SVGs
	mkdir -p build/physics_SVGs
	ls build/BUILD.ufo/glyphs/*.glif | parallel --bar '$(GLIF2SVG) -o build/physics_SVGs/{/.}_internal.svg {}'
	parallel --bar -a build_data/monoline.tsv --colsep '\t' 'make UFO=$(FONTFAMILY)-{1}.ufo physics-files-per-ufo'

.PHONY: all-physics-files
all-physics-files:
	make colrglyphs colrglyphs-ufo
	make physics-files

.PHONY: compile-processing
compile-processing:
	$(PROCESSING) --sketch=$$PWD/scripts/AnchorPhysics --output=/tmp/AnchorPhysics --export

.PHONY: processing-physics
processing-physics:
	# $(PROCESSING) --no-java --sketch=../../scripts/AnchorPhysics --run | sed -e "/^Finished\./d" > "$$TEMPTSV";
	JOBS=`wc -l < build_data/monoline.tsv`
	[[ ! -d /tmp/AnchorPhysics ]] && make compile-processing
	cat build_data/monoline$(DEBUG).tsv | sort -r | parallel -u --jobs $$JOBS --colsep '\t' '
	cd build/$(FONTFAMILY)-{1}.ufo;
	TEMPTSV=`mktemp --suffix=.tsv`;
	echo Writing "$$TEMPTSV";
	find ../../$(FONTFAMILY)-SOURCE.ufo/glyphs/ -type f -iname "*.glif" -and -not -iname "space.glif" -printf "%f\\n" | xargs basename -a -s.glif | sort > glyphs.txt;
	/tmp/AnchorPhysics/AnchorPhysics | sed -e "/^Finished\./d" > "$$TEMPTSV";
	$(PYTHON) ../../scripts/tsv_to_mark.py "$$TEMPTSV" > strokes_mark.fea;
	'

.PHONY: physics
physics:
	make all-physics-files
	make processing-physics
