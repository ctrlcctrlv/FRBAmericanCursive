# FRB American Cursive
![](https://raw.githubusercontent.com/ctrlcctrlv/FRBAmericanCursive/main/specimens/hello.png)
* [Specimen](https://raw.githubusercontent.com/ctrlcctrlv/FRBAmericanCursive/main/specimens/FRBAmericanCursive-specimen.pdf)
* [Character map](https://github.com/ctrlcctrlv/FRBAmericanCursive/blob/main/specimens/pr-FRBAmericanCursive-Regular.pdf)

© 2021 Fredrick R. Brennan. Licensed under the GNU GPL v3.

Thanks to: Matthew Blanchard (MFEKstroke), Simon Cozens (FEE)

FRB American Cursive is an extremely technically complex cursive font family that consists of 50+ fonts. It is in the style of a "textbook hand", a font family used primarily for education. However, it can be used anywhere a cursive is called for. I call it an "American" cursive not out of any sense of patriotism, but out of a sense of the history of textbook hands: this font most heavily takes its design inspiration from Zaner–Bloser cursive. However, I also integrated elements of D'Nealian and Palmer Method. What this means is that FRB American Cursive is a traditional American textbook hand which puts a lot of emphasis on the idea that the writer should lift their hand from the page as seldom as possible. Using OpenType Layout, I made it so each glyph has at least 3 versions. Unlike many textbook hands, even educational ones, my font connects capital letters and lowercase letters. It connects some capital letters with eachother where possible as well.

Some styles of FRB American Cursive rely on new font technologies that may not work on all legacy systems. Especially the color fonts may not be supported on all systems. However, FRB American Cursive is a standard OpenType font family. OpenType support is absolutely mandatory *mandatory* for this font: there is no expectation of proper display without OpenType Layout support. The best tested target is HarfBuzz.

FRB American Cursive supports Latin and Cyrillic. Some day I hope it will also support Armenian and Greek.

As far as I know, this is the most technically advanced educational cursive font family in existence. All fonts come from a single FontForge SFD ultimately: `FRBAmericanCursive.sfd`.

## A bit of philosophy…

The fonts are free software. They are free for personal and commercial use. Much ink has been spilled about "the death of cursive" in the US, but few have taken the time to analyze the fact that all of the educational cursive computer fonts are proprietary. (Especially high quality ones, with OpenType substitution to make a flawlessly connecting word.)

## Building

This isn't your grandmother's Fontographer font. It is best to think of it as a software project and a font family combined. Over 500 lines of just my own code make the final font files. So, building is complex. Take a look at `Makefile` first, if you'd wish to take the plunge, it shows which fonts use which scripts.

Like all my fonts except my earliest work, no non-free software was used at any point during development.

### Needed pip packages

* ufo-extractor
* defcon
* beziers.py
* fontFeatures
* fonttools
* afdko

### Needed software

* GNU Parallel
* GNU `bash`, `find`, `make`, and `sed`&dagger;
* MFEKstroke&Dagger; (before v1.2 only used to build a few font features but now used to build every font)
* FontForge (w/Python API)
* [`glifpathlen`](https://github.com/ctrlcctrlv/glifpathlen)&Dagger;
* [`sfdnormalize`](https://github.com/alerque/sfdnormalize)
* [`sfd2ufo`](https://github.com/alif-type/sfdLib)
* Inkscape (for building the color fonts)
* xq (for some SVG stuff, only used in color fonts)

#### For specimens
* SILE
* PDFtk
* ImageMagick
* hb-view (`harfbuzz`)
* ftdump (`freetype2-demos`)

<sub>&dagger; These should be standard on most Linux distributions and on Windows under MSYS2.</sub>
<sub>&Dagger; These are Rust projects and need to be compiled by <kbd>cargo</kbd> and installed into your <kbd>PATH</kbd>.</sub>

### Note on Python interpreter

Right now the Makefiles are expecting you to have `fontmake` installed _through PyPy_. `fontmake` is noticeably faster through PyPy, which matters quite a lot when building ≈70 fonts.

I installed it like this:

```bash
pypy3 -m pip install --user fontmake
```

PyPy may not be convenient for you. If not, just remove it from the Makefile's. Patch welcome to add a Python interpreter flag to the Makefile's, I didn't have time. Note that you need _both_ CPython and PyPy, because FontForge only works via CPython and a lot of scripts early in the build process require the FontForge API. (`make regen` etc.)

### Build process

On `make`, this is the general flow:

#### `make regen`
* The source for all of the final fonts is a single file, `FRBAmericanCursive.sfd`. This file contains all of the actual splines, glyph names, and metrics. Every font is built from this file. `make regen` is the first part of the Makefile, and its purpose is to generate the UFO, `FRBAmericanCursive-SOURCE.ufo`. _However_, this UFO has diverged from how FontForge would write it, so _only the glyphs folder is replaced_. To edit the font OpenType Layout features (`features.fea`) or the font's metadata (`fontinfo.plist`), etc., it is perfectly fine for you to edit the UFO files not inside the `glyphs/` directory, they won't be overwritten by the SFD data upon `make regen`.
#### `make monoline`
* The job of this step is to copy the source UFO to all of the UFO's for the "monoline" fonts, that is to say, the fonts like `FRBAmericanCursive-400-Regular.otf`, `FRBAmericanCursive-900-Black.otf`, etc. It also runs `MFEKstroke-CWS`, a constant width stroker, on each glyph in the input, along with the widths provided in `build_data/monoline.tsv`. It outputs a UFO for each font into `build/` as well, as the next steps need them. `scripts/prepare_ufo.py` runs `scripts/fudge_fontinfo.py` which changes the metadata as appropriate for each font.
#### `make svgs`
* The job of this script is to make SVG files for each glyph that will be used in the color font. So: guidelines (the backgrounds in the <kbd>Guidelines</kbd> fonts), beginnings, and endings. The final step of `make svgs` converts all of these into `.glif` format in a directory called `build/COLR_glyphs`. Perhaps `svgs` is a bit of a misnomer, because one layer never touches SVG: the arrows. They used to be SVG-originated, but since v1.2 now come from two passes of MFEKstroke: first, `MFEKstroke-PAP` (using a single line, offset from the glyph, with a variable length decided by the `scripts/make_arrows_for_glyph.py` script that calls `glifpathlen`), then `MFEKstroke-CWS` with a custom triangle-shaped cap to make an arrow.
#### `make patterned`
* Before we can actually build the color fonts (COLR/CPAL format is what we support), however, we need to make the patterned fonts, because they, especially the dotted fonts, can be useful bases for COLR/CPAL fonts, especially the ones with guidelines. If they don't exist however, `make colrcpal` can't pick them up. So, we generate them all. The process is very similar to `make monoline`, except this time we're exclusively using `MFEKstroke-PAP` instead of `MFEKstroke-CWS`.
#### `make colrcpal`
* Finally, we can build the COLR/CPAL fonts, from all the fonts we already have. We inject the contents of `build/COLR_glyphs` into every UFO font built so far in `build/`, and then build all of them with `fontmake`, _without allowing `fontmake` to handle the color_. We use a custom fontTools script to add the actual COLR/CPAL SFNT tables, called `scripts/combine_colr_cpal.py`.
#### `make specimens`
* Wrapping up, specimen generation is primarily handled by two programs: `hb-view` (from HarfBuzz utilities) and SILE, a Lua typesetter that rivals LuaLaTeX. SILE generates a lot of pages for us, then `pdftk` puts them all together in one document.
#### `make dist`
* The final `make` command of note for distributing a new release is this one. All it does is make WOFF2 files of all the compiled fonts in `dist` and zip them up for you, ready to upload to GitHub's releases page.
