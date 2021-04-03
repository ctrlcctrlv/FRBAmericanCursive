# Build specimens.
.PHONY: specimens
specimens:
	./scripts/letter_combos.py > specimens/combos.sil
	sile specimens/combos.sil
	./scripts/each_font_specimen.sh
	for f in dist/*; do hb-view -o /tmp/`basename "$$f"`.png "$$f" 'FRB American Cursive: Hello!'; done
	convert -append /tmp/FRBAmericanCursive-100-Thin.otf.png /tmp/FRBAmericanCursive-500-Medium.otf.png /tmp/FRBAmericanCursive-800-Extrabold.otf.png /tmp/FRBAmericanCursive-GuidelinesArrowPathBold.otf.png /tmp/FRBAmericanCursive-GuidelinesArrowsBold.otf.png /tmp/FRBAmericanCursive-GuidelinesArrowsDottedMedium.otf.png /tmp/FRBAmericanCursive-GuidelinesDottedMedium.otf.png /tmp/FRBAmericanCursive-GuidelinesUltra.otf.png /tmp/FRBAmericanCursive-GuidelinesGuidance.otf.png specimens/hello.png
