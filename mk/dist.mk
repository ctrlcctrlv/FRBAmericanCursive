export 7Z_ARGS := -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on
export ZIP_ARGS := -n woff2 -j

.PHONY .ONESHELL: dist
dist:
	$(MAKE) -j2 dist-ttc dist-woff2
	$(MAKE) dist-pack

dist/%.woff2.zip:
	rm -f $@ ; zip $(ZIP_ARGS) -r $@ `find dist/woff2 -iname '$(FONTFAMILY)*'`

dist/%.ttc.7z:
	rm -f $@ ; 7z a $(7Z_ARGS) $@ `find dist/ttc -iname '$(FONTFAMILY)*'`

.PHONY: dist-pack
dist-pack:
	$(MAKE) dist/$(FONTFAMILY).woff2.zip
	$(MAKE) dist/$(FONTFAMILY).ttc.7z

.PHONY: dist-woff2
dist-woff2:
	@mkdir -p dist/woff2 || true
	find dist -iname '$(FONTFAMILY)*.otf' | parallel --ctag --linebuffer 'woff2_compress {} && mv {.}.woff2 dist/woff2/'

.PHONY: dist-ttc
dist-ttc:
	@mkdir -p dist/ttc || true
	parallel --ctag --linebuffer < scripts/dist/ttc.sh
