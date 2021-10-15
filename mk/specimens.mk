# Build specimens.
.PHONY: specimens-harfbuzz
specimens-harfbuzz:
	mkdir -p build/specimens
	cd build/specimens
	for f in ../../dist/*.otf; do hb-view -o `basename "$$f"`.png "$$f" '$(FONTFAMILY_H): Hello!'; done
	convert -append $(FONTFAMILY)-100-Thin.otf.png $(FONTFAMILY)-500-Medium.otf.png $(FONTFAMILY)-800-Extrabold.otf.png $(FONTFAMILY)-700-GuidelinesArrowPathBold.otf.png $(FONTFAMILY)-700-GuidelinesArrowsBold.otf.png $(FONTFAMILY)-500-GuidelinesArrowsDottedMedium.otf.png $(FONTFAMILY)-500-GuidelinesDottedMedium.otf.png $(FONTFAMILY)-1000-GuidelinesUltra.otf.png ../../specimens/hello.png

.PHONY: specimens-sile
specimens-sile:
	./scripts/letter_combos.py > specimens/combos.sil
	sile specimens/combos.sil
	./scripts/each_font_specimen.sh

.PHONY: specimens
specimens:
	make -j2 specimens-sile specimens-harfbuzz
