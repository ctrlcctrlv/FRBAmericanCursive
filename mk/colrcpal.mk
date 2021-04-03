# Build all the SVG data we need to build the color version of the font.
.PHONY: svgs
svgs:
	rm -rf build/SVG_{layers,ml}
	mkdir -p build/SVG_{layers,ml}
	./scripts/list_glyphs.py FRBAmericanCursive.sfd | parallel --bar ./scripts/make_multilayer_svg_from_glyph.py {} '>' build/SVG_ml/{}.svg
	find build/SVG_ml -type f | parallel --bar ./scripts/split_svg.sh {}
	find build/SVG_ml/ -iname "*_beginnings.svg" -or -iname "*_endings.svg" -or -iname "*_guidelines.svg" | xargs -I{} mv {} build/SVG_layers/
	find build/SVG_layers/ -iname '*.svg' | parallel -m 'inkscape --batch-process --actions "select-all:all;verb:StrokeToPath;select-all;verb:SelectionUnion;export-plain-svg;" --export-overwrite'
	./scripts/svgs_to_COLRglyphs_dir.py

# This won't work anymore because I manually added the OS2 weights to the .tsv and don't yet have an automatic way to derive them. File will need to be manually updated, which I think is fine.
#build_data/colrcpal_fontlist.tsv:
#	find build -type d -iname '*.ufo' -and -not -iname '*Guidelines*'| sed 's/.*-//;s/\.ufo$$//' > build_data/colrcpal_fontlist.tsv

# Build the color fonts.
.PHONY: colrcpal
colrcpal:
	true
	parallel --bar -a build_data/colrcpal_fontlist.tsv --colsep '\t' '
	./scripts/make_combined_without_colr_cpal.sh FRBAmericanCursive-{1}.ufo {2}
	./scripts/combine_colr_cpal.py dist/FRBAmericanCursive-{2}-GuidelinesArrows{1}.otf build/FRBAmericanCursive-{1}.ufo
	'

# Build one color font for debugging purposes.
.PHONY: debug-colrcpal
debug-colrcpal:
	./scripts/svgs_to_COLRglyphs_dir.py
	./scripts/make_combined_without_colr_cpal.sh FRBAmericanCursive-Regular.ufo 400
	./scripts/combine_colr_cpal.py dist/FRBAmericanCursive-400-GuidelinesArrowsRegular.otf build/FRBAmericanCursive-Regular.ufo
