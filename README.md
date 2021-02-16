# FRB American Cursive

© 2021 Fredrick R. Brennan. Licensed under the GNU GPL v3.

Thanks to: Matthew Blanchard (MFEKstroke), Simon Cozens (FEE, beziers.py)

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
* GNU find
* GNU make
* FontForge (w/Python API)
* MFEK/stroke (for building the dotted fonts and fonts with arrows for outlines)
* Inkscape (for building the color fonts)
* xq (for some SVG stuff, only used in color fonts)
* SILE (for specimen generation)
* ImageMagick (for specimen generation)
