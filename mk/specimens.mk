# Build specimens.
.PHONY: specimens-harfbuzz
specimens-harfbuzz:
	mkdir -p build/specimens
	cd build/specimens
	for f in ../../dist/*.otf; do hb-view -o `basename "$$f"`.png "$$f" 'FRB American Cursive: Hello!'; done
	convert -append FRBAmericanCursive-100-Thin.otf.png FRBAmericanCursive-500-Medium.otf.png FRBAmericanCursive-800-Extrabold.otf.png FRBAmericanCursive-700-GuidelinesArrowPathBold.otf.png FRBAmericanCursive-700-GuidelinesArrowsBold.otf.png FRBAmericanCursive-500-GuidelinesArrowsDottedMedium.otf.png FRBAmericanCursive-500-GuidelinesDottedMedium.otf.png FRBAmericanCursive-1000-GuidelinesUltra.otf.png FRBAmericanCursive-400-GuidelinesGuidance.otf.png ../../specimens/hello.png

.PHONY: specimens-sile
specimens-sile:
	./scripts/letter_combos.py > specimens/combos.sil
	sile specimens/combos.sil
	./scripts/each_font_specimen.sh

.PHONY: specimens
specimens:
	make -j2 specimens-sile specimens-harfbuzz
