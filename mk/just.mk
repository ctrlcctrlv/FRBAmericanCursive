.PHONY: just
just:
	(for f in baseline beginnings endings guidelines xheight; do echo $$f; done) | parallel 'make REMOVE={} DEBUG=_debug just_each'
	make REMOVE=arrows just_each

.PHONY: just_each
just_each:
	parallel --bar -a build_data/monoline$(DEBUG).tsv --colsep '\t' '
		UFO="build/$(FONTFAMILY)-{3}-GuidelinesArrows{1}.ufo"
		FN_EL=`echo $(REMOVE) | awk "{\\$$1=toupper(substr(\\$$1,0,1))substr(\\$$1,2)}1"`
		JAUFO="build/$(FONTFAMILY)-{3}-Just$${FN_EL}{1}.ufo"
		rm -fr "$$JAUFO"
		cp -r "$$UFO" "$$JAUFO"
		rm -f "$$JAUFO"/glyphs/*_{$(shell ./scripts/COLR_filter.py $(REMOVE))}.glif
		NOTARROWS=`find "$$JAUFO"/glyphs -not -iname "*_$(REMOVE).glif" -and -iname "*.glif"`
		for f in $$NOTARROWS; do
			MFEKpathops CLEAR -i "$$f"
			GLIFNAME=`xidel --silent -e "/glyph/@name" "$$f"`
			BASEGLIFNAME="$${GLIFNAME}_$(REMOVE)"
			ARROWGLIF=$${f%%.glif}_$(REMOVE).glif
			if [[ -f "$$ARROWGLIF" ]]; then
				sed -i "s@<outline \?/>@<outline>\n    <component base=\"$$BASEGLIFNAME\" />\n  </outline>@" "$$f"
			fi
		done
		./scripts/regen_glyphs_plist.py "$$JAUFO"/glyphs
		./scripts/fudge_fontinfo.py "$$JAUFO" "$(FONTFAMILY)" "$(FONTFAMILY_H)" Just$${FN_EL}{1} {3}
		ARGS=`./scripts/fontmake_args.sh`
		JAOTF="dist/$(FONTFAMILY)-{3}-Just$${FN_EL}{1}.otf"
		$(PYTHON) -m fontmake $$ARGS -u "$$JAUFO" --output-path "$$JAOTF" -o otf
	'
