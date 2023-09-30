dist/%.ttf: dist/%.otf
	set -x &&\
	otf2ttf $< $@ &&\
	if [[ -f build_data/$(FONTFAMILY)_hint ]]; then
		ttfautohint $(TTFAUTOHINT_FLAGS) $@ $@_H && mv $@_H $@
	fi &&\
	mv $@ dist/ttf/

.PHONY: echo-ttfautohint-flags
echo-ttfautohint-flags:
	@echo $(TTFAUTOHINT_FLAGS)
