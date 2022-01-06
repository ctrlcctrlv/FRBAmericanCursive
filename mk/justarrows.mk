.PHONY: justarrows
justarrows:
	parallel --bar -a build_data/monoline.tsv --colsep '\t' '
		UFO="build/$(FONTFAMILY)-{3}-GuidelinesArrows{1}.ufo"
		JAUFO="build/$(FONTFAMILY)-{3}-JustArrows{1}.ufo"
		rm -fr "$$JAUFO"
		cp -r "$$UFO" "$$JAUFO"
		rm -f "$$JAUFO"/glyphs/*_{baseline,beginnings,endings,guidelines,xheight}.glif
		NOTARROWS=`find "$$JAUFO"/glyphs -not -iname "*_arrows.glif" -and -iname "*.glif"`
		for f in $$NOTARROWS; do
			MFEKpathops CLEAR -i "$$f"
			GLIFNAME=`xidel --silent -e "/glyph/@name" "$$f"`
			BASEGLIFNAME="$${GLIFNAME}_arrows"
			ARROWGLIF=$${f%%.glif}_arrows.glif
			if [[ -f "$$ARROWGLIF" ]]; then
				sed -i "s@<outline \?/>@<outline>\n    <component base=\"$$BASEGLIFNAME\" />\n  </outline>@" "$$f"
			fi
		done
		./scripts/regen_glyphs_plist.py "$$JAUFO"/glyphs
		./scripts/fudge_fontinfo.py "$$JAUFO" "$(FONTFAMILY)" "$(FONTFAMILY_H)" JustArrows{1} {3}
		ARGS=`./scripts/fontmake_args.sh`
		JAOTF="dist/$(FONTFAMILY)-{3}-JustArrows{1}.otf"
		$(PYTHON) -m fontmake $$ARGS -u "$$JAUFO" --output-path "$$JAOTF" -o otf
	'
