#!/usr/bin/env python3
import fontforge
import tempfile
import os
import shutil

tempufodir = tempfile.mkdtemp()
ufoname = tempufodir+os.sep+"FRBAmericanCursive.ufo"

f = fontforge.open("FRBAmericanCursive.sfd")
f.generate(ufoname)

try:
    shutil.rmtree("FRBAmericanCursive-SOURCE.ufo/glyphs")
except OSError: pass

shutil.copytree(ufoname+os.sep+"glyphs", "FRBAmericanCursive-SOURCE.ufo/glyphs")
shutil.rmtree(tempufodir)
