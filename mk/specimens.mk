# Build specimens.
.PHONY: specimens-harfbuzz
specimens-harfbuzz:
	mkdir -p build/specimens
	cd build/specimens
	for f in ../../dist/*.otf; do hb-view -o `basename "$$f"`.png "$$f" '$(FONTFAMILY_H): Hello!'; done
	convert -append $(FONTFAMILY)-100-Thin.otf.png $(FONTFAMILY)-500-Medium.otf.png $(FONTFAMILY)-800-Extrabold.otf.png $(FONTFAMILY)-700-GuidelinesArrowsBold_NOVF.otf.png $(FONTFAMILY)-500-GuidelinesArrowsDashedMedium_NOVF.otf.png $(FONTFAMILY)-500-GuidelinesDashedMedium_NOVF.otf.png $(FONTFAMILY)-200-GuidelinesArrowsDashedExtralight_NOVF.otf.png $(FONTFAMILY)-1000-GuidelinesUltra_NOVF.otf.png ../../specimens/$(FONTFAMILY)-hello.png

.PHONY: specimens-sile
specimens-sile:
	make -j2 specimens-sile-combos specimens-sile-wholefont

.PHONY: specimens-sile-combos
specimens-sile-combos:
	./scripts/letter_combos.py > specimens/combos.sil
	sile specimens/combos.sil

.PHONY: specimens-sile-wholefont
specimens-sile-wholefont:
	./scripts/each_font_specimen.sh

.PHONY: specimens
specimens:
	make -j2 specimens-sile specimens-harfbuzz
