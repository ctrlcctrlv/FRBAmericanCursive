#!/usr/bin/env python3
# Note: This script may return an error concerning the fact that FontForge's UFO features.fea include(..) statements are contrary to spec. They can be safely ignored, this script doesn't manipulate/overwrite OTL features.

import fontforge
import os
import shutil
import sys
import tempfile

import extractor, defcon

(_, namedweight) = sys.argv

origufoname = "build/FRBAmericanCursive-{}.ufo".format(namedweight)

font = fontforge.open(origufoname)
for g in font.glyphs():
    g.simplify(0.1)
    g.correctDirection()

tempufodir = tempfile.mkdtemp()
ufoname = tempufodir+os.sep+"FRBAmericanCursive.ufo"
otfname = tempufodir+os.sep+"FRBAmericanCursive.otf"
# FIXME: If fontforge/fontforge#4327, fontforge/fontforge#4539 are ever fixed, replace this with a f.generate(ufoname)
font.generate(otfname, flags=("opentype","no-hints","no-flex","omit-instructions"))
ufo = defcon.Font()
extractor.extractUFO(otfname, ufo)
ufo.save(ufoname)

try:
    shutil.rmtree(origufoname+"/glyphs")
except OSError: pass

shutil.copytree(ufoname+"/glyphs", origufoname+"/glyphs")
