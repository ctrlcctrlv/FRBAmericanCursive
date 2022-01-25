# FRB American Cursive
<!--![](https://raw.githubusercontent.com/ctrlcctrlv/FRBAmericanCursive/main/specimens/hello.png)-->

* **[Download the fonts](https://github.com/ctrlcctrlv/FRBAmericanCursive/archive/refs/heads/main.zip)** (fonts are in `dist/` directory of `main.zip`)
<!--* [Specimen](https://raw.githubusercontent.com/ctrlcctrlv/FRBAmericanCursive/main/specimens/FRBAmericanCursive-specimen.pdf)
* [Character map](https://github.com/ctrlcctrlv/FRBAmericanCursive/blob/main/specimens/pr-FRBAmericanCursive-Regular.pdf)-->

© 2021 Fredrick R. Brennan. Licensed under the GNU GPL v3.

Thanks to: Matthew Blanchard (MFEKstroke), Simon Cozens (FEE)

FRB American Cursive is an extremely technically complex cursive font family that consists of 50+ fonts. It is in the style of a "textbook hand", a font family used primarily for education. However, it can be used anywhere a cursive is called for. I call it an "American" cursive not out of any sense of patriotism, but out of a sense of the history of textbook hands: this font most heavily takes its design inspiration from Zaner–Bloser cursive. However, I also integrated elements of D'Nealian and Palmer Method. What this means is that FRB American Cursive is a traditional American textbook hand which puts a lot of emphasis on the idea that the writer should lift their hand from the page as seldom as possible. Using OpenType Layout, I made it so each glyph has at least 3 versions. Unlike many textbook hands, even educational ones, my font connects capital letters and lowercase letters. It connects some capital letters with eachother where possible as well.

Some styles of FRB American Cursive rely on new font technologies that may not work on all legacy systems. Especially the color fonts may not be supported on all systems. However, FRB American Cursive is a standard OpenType font family. OpenType support is absolutely mandatory *mandatory* for this font: there is no expectation of proper display without OpenType Layout support. The best tested target is HarfBuzz.

FRB American Cursive supports Latin and Cyrillic. Some day I hope it will also support Armenian and Greek.

As far as I know, this is the most technically advanced educational cursive font family in existence. All fonts come from a single FontForge SFD ultimately: `FRBAmericanCursive.sfd`.

## A bit of philosophy…

The fonts are free software. They are free for personal and commercial use. Much ink has been spilled about "the death of cursive" in the US, but few have taken the time to analyze the fact that all of the educational cursive computer fonts are proprietary. (Especially high quality ones, with OpenType substitution to make a flawlessly connecting word.)

## Notes on proprietary software
### Adobe product advisory

Several Adobe products, among them Illustrator CC and InDesign CC, as of December 2021 require manual intervention to get the fonts to display properly.

The screenshot below, via user @mouad1990, shows how to fix this problem. **This is a bug in Adobe's software, no change to the font itself is possible to fix this unfortunately.** Earlier Adobe products, such as Illustrator CS5 and below, may not work at all.

![](https://raw.githubusercontent.com/ctrlcctrlv/FRBAmericanCursive/v2/doc/indesign_composer.png)

### Other proprietary software

Much proprietary software is known to have unsolvable issues with these fonts. The OpenType standards these fonts use are not new, yet in the interests of profit, as they are most often used for what the tech industry calls “complex scripts”, support is lacking or non-existent for OpenType. When it exists, sometimes it is enabled only for the aforementioned scripts so that companies can charge money for “advanced” font rendering. For example, even in Windows 10, neither Microsoft Paint nor Windows’ WordPad can render the fonts correctly. **Only Microsoft can fix this issue.** Pressure must begin to be put to bear on Microsoft, Apple, etc. to fix their products so that they follow the specifications.

FRB American Cursive is only officially supported when used with HarfBuzz, the standard shaper on GNU/Linux, and FreeType, the standard font rasterizer on GNU/Linux. HarfBuzz may also be found in both the Firefox and Chrome web browsers on all platforms. **All rendering outside of FreeType+HarfBuzz is best effort. Issues only affecting proprietary shapers/rasterizers will not be fixed if they will degrade the experience of FreeType+HarfBuzz users. Investigation of issues outside FreeType+HarfBuzz falls to users.**

GIMP uses FreeType+HarfBuzz on all platforms, and is the recommended way to rasterize the fonts.

## Building

This isn't your grandmother's Fontographer font. It is best to think of it as a software project and a font family combined. Over 500 lines of just my own code make the final font files. So, building is complex. Take a look at `Makefile` first, if you'd wish to take the plunge, it shows which fonts use which scripts.

Like all my fonts except my earliest work, no non-free software was used at any point during development.

Warning: FRB American Cursive generates *a lot* of files during compilation. On my machine, these files required a combined 1.3GB of space. You have been warned.

### Needed pip (Python 3 PyPI) packages

* ufo-extractor
* defcon
* fez-language
* fonttools
* afdko

### Needed software

* GNU Parallel
* GNU `bash`, `find`, `make`, and `sed`&dagger;
* MFEKmetadata&Dagger; (used to build arrows)
* MFEKstroke&Dagger; (before v1.2 only used to build a few font features but now used to build every font)
* MFEKglif&Dagger; (to edit glyphs)
* [Xidel](https://github.com/benibela/xidel)

#### For specimens
* SILE
* PDFtk
* ImageMagick
* hb-view (`harfbuzz`)
* ftdump (`freetype2-demos`)

#### For physics
FRB American Cursive v2 optionally requires a physics simulator to figure out the correct placement of its stroke numbers. This saves a lot of time for the designer, but can be a bit cumbersome to set up, so building is possible without it. v2 uses the Java version of [Processing](https://processing.org/) plus [toxiclibs](https://toxiclibs.org) as its physics engine; you'll also need to install [geomerative](http://www.ricardmarxer.com/geomerative/geomerative-39.zip) to `sketchbook/libraries`. This might change in future releases. For your convenince, my entire Processing `sketchbook/` directory can be downloaded from [ctrlcctrlv/FRBAmericanCursive-processing-sketchbook](https://github.com/ctrlcctrlv/FRBAmericanCursive-processing-sketchbook).

<sub>&dagger; These should be standard on most Linux distributions and on Windows under MSYS2.</sub>
<sub>&Dagger; These are Rust projects and need to be compiled by <kbd>cargo</kbd> and installed into your <kbd>PATH</kbd>.</sub>

### Build process

On `make`, this is the general flow:

#### `make regen`
* The source for all of the final fonts is a single file, `FRBAmericanCursive.sfd`. This file contains all of the actual splines, glyph names, and metrics. Every font is built from this file. `make regen` is the first part of the Makefile, and its purpose is to generate the UFO, `FRBAmericanCursive-SOURCE.ufo`. _However_, this UFO has diverged from how FontForge would write it, so _only the glyphs folder is replaced_. To edit the font OpenType Layout features (`features.fea`) or the font's metadata (`fontinfo.plist`), etc., it is perfectly fine for you to edit the UFO files not inside the `glyphs/` directory, they won't be overwritten by the SFD data upon `make regen`.
#### `make monoline`
* The job of this step is to copy the source UFO to all of the UFO's for the "monoline" fonts, that is to say, the fonts like `FRBAmericanCursive-400-Regular.otf`, `FRBAmericanCursive-900-Black.otf`, etc. It also runs `MFEKstroke-CWS`, a constant width stroker, on each glyph in the input, along with the widths provided in `build_data/monoline.tsv`. It outputs a UFO for each font into `build/` as well, as the next steps need them. `scripts/prepare_ufo.py` runs `scripts/fudge_fontinfo.py` which changes the metadata as appropriate for each font.
#### `make patterned`
* Before we can actually build the color fonts (COLR/CPAL format is what we support), however, we need to make the patterned fonts, because they, especially the dotted fonts, can be useful bases for COLR/CPAL fonts, especially the ones with guidelines. If they don't exist however, `make colrcpal` can't pick them up. So, we generate them all. The process is very similar to `make monoline`, except this time we're exclusively using `MFEKstroke-PAP` instead of `MFEKstroke-CWS`.
#### `make physics`
* (Optional) The particle physics engine available in toxiclibs is used to place the numbers. You'll need [Processing](https://processing.org/) to build this step, and if not installed, should be skipped.
#### `make colrcpal`
* First we build all the glyphs that will be used in the color font. So: guidelines (the backgrounds in the <kbd>Guidelines</kbd> fonts), beginnings, and endings. Arrows since v1.2 come from two passes of MFEKstroke: first, `MFEKstroke-PAP` (using a single line, offset from the glyph, with a variable length decided by the `scripts/make_arrows_for_glyph.py` script that calls `glifpathlen`), then `MFEKstroke-CWS` with a custom triangle-shaped cap to make an arrow.
* Finally, we can build the COLR/CPAL fonts, from all the fonts we already have. We inject the contents of `build/COLR_glyphs` into every UFO font built so far in `build/`, and then build all of them with `fontmake`, _without allowing `fontmake` to handle the color_. We use a custom fontTools script to add the actual COLR/CPAL SFNT tables, called `scripts/combine_colr_cpal.py`.
#### `make specimens`
* Wrapping up, specimen generation is primarily handled by two programs: `hb-view` (from HarfBuzz utilities) and SILE, a Lua typesetter that rivals LuaLaTeX. SILE generates a lot of pages for us, then `pdftk` puts them all together in one document.
#### `make dist`
* The final `make` command of note for distributing a new release is this one. All it does is make WOFF2 files of all the compiled fonts in `dist` and zip them up for you, ready to upload to GitHub's releases page.
