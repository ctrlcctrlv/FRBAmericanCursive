#!/usr/bin/env python3
# This script does the following:
# - from the base SFD, stroke all glyphs
# - output it as an OTF due to fontforge/fontforge#4327, fontforge/fontforge#4539
# - use extractor to turn the OTF into UFO
# - massage the UFO metadata (Regular → whatever weight being built)

import fontforge
import shutil
import os, sys
import tempfile
import unicodedata
import csv

import extractor, defcon

import plistlib

# in scripts dir
import build_ccmp

_, namedweight, strokewidth, os2weight = sys.argv
os2weight = int(os2weight)

tempufodir = tempfile.mkdtemp()
ufoname = tempufodir+os.sep+"FRBAmericanCursive.ufo"
otfname = tempufodir+os.sep+"FRBAmericanCursive.otf"
outname = "build/FRBAmericanCursive-{}.ufo".format(namedweight)

try:
    shutil.rmtree(outname)
except OSError: pass

shutil.copytree("FRBAmericanCursive-SOURCE.ufo", outname)

f = fontforge.open("FRBAmericanCursive.sfd")
f.selection.all()
# No magic here in terms of building the list. They looked wrong without it, manual verification.
removeOverlap = lambda gn: "none" if gn not in ["section", "ampersand", "dollar", "cyr_ER.rlow", "cent", "Ccedilla", "Ccedilla.rlow", "eth", "eth.high", "eth.low"] else "layer"
# Don't remove internal contour for combining ring above
removeInternal = lambda gn: False if gn in ["uni030A"] else True
if int(strokewidth) != 0:
    for g in f.glyphs():
        print("Stroking {}".format(g.glyphname), file=sys.stderr)
        g.stroke("circular", int(strokewidth), "round", "round", simplify=False, removeoverlap=removeOverlap(g.glyphname), removeinternal=removeInternal(g.glyphname), accuracy=0.10)
    f.correctDirection()

# Add anchors for all marks
with open("build_data/top_marks") as topf:
    topmarks = topf.read().strip().split()
    for m in topmarks:
        f[m].addAnchorPoint("top", "mark", 0, 0)

# Add anchors for certain bases
with open("build_data/top.tsv") as csvf:
    r = csv.reader(csvf, delimiter="\t")
    for row in r:
        (glyph, x, y) = row
        f[glyph].addAnchorPoint("top", "base", int(x), int(y))

build_ccmp.create_and_build_placeholders(f)

# FIXME: If fontforge/fontforge#4327, fontforge/fontforge#4539 are ever fixed, replace this with a f.generate(ufoname)
f.generate(otfname, flags=("opentype","no-hints","no-flex","omit-instructions"))
ufo = defcon.Font()
extractor.extractUFO(otfname, ufo)
ufo.save(ufoname)

try:
    shutil.rmtree(outname+"/glyphs")
except OSError: pass

shutil.copytree(ufoname+os.sep+"glyphs", outname+"/glyphs")
shutil.rmtree(tempufodir)

plistf = open(outname+"/fontinfo.plist", "rb")
plist = plistlib.load(plistf)
plist["postscriptWeightName"] = namedweight
plist["openTypeOS2WeightClass"] = os2weight
plist["styleName"] = namedweight
plist["styleMapStyleName"] = "bold italic" if os2weight >= 700 else "italic"
plist["postscriptFontName"] = plist["postscriptFontName"].replace("Regular", namedweight)
plistf.close()
plistf = open(outname+"/fontinfo.plist", "wb")
plistlib.dump(plist, plistf)
plistf.close()
