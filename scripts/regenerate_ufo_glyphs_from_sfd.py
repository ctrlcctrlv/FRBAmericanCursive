#!/usr/bin/env python3
# THIS SCRIPT IS DEPRECATED…EDIT .glif FILES DIRECTLY WITH MFEKglif
import fontforge
import tempfile
import os
import shutil

fontfamily = os.environ["FONTFAMILY"]

tempufodir = tempfile.mkdtemp()
ufoname = tempufodir+os.sep+fontfamily+".ufo"

f = fontforge.open(fontfamily+".sfd")
f.generate(ufoname)

try:
    shutil.rmtree(fontfamily+"-SOURCE.ufo/glyphs")
except OSError: pass

shutil.copytree(ufoname+os.sep+"glyphs", fontfamily+"-SOURCE.ufo/glyphs")
shutil.rmtree(tempufodir)
