#!/usr/bin/env python3
# (c) 2021 Fredrick R. Brennan
SUBPROCESS_KWARGS = {"shell": True, "executable": "/bin/bash"}

import os
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
from glyph import Glyph
from fontTools.ufoLib import glifLib
from fontTools.pens.recordingPen import RecordingPen
from fontParts.fontshell.glyph import RGlyph

radius = 5

_, glifname, font = sys.argv

gliffn = "{}/glyphs/{}".format(font, glifLib.glyphNameToFileName(glifname, None))
plist = open("{}/fontinfo.plist".format(font)).read().encode("utf-8")
fontinfo = plistlib.loads(plist)
builddir = "build/COLR_glyphs/"
try:
    os.mkdir(builddir)
except OSError:
    pass

def drawSquare(p, pt):
    p.moveTo((pt.x - (radius / 2), pt.y - (radius / 2)))
    p.lineTo((pt.x + (radius / 2), pt.y - (radius / 2)))
    p.lineTo((pt.x + (radius / 2), pt.y + (radius / 2)))
    p.closePath()

with open(gliffn) as f:
    glyph = RGlyph()
    xml = f.read()
    glyph._loadFromGLIF(xml)
    p = glyph.getPen()
    pp = glyph.getPointPen()
    firsts = [c[0] for c in glyph.contours]
    lasts = [c[-1] for c in glyph.contours]
    glyph.clearContours()
    p.moveTo((0, 0))
    p.lineTo((glyph.width, 0))
    p.closePath()
    p.moveTo((0, fontinfo["capHeight"]))
    p.lineTo((glyph.width, fontinfo["capHeight"]))
    p.closePath()
    p.moveTo((0, -fontinfo["openTypeOS2TypoDescender"]))
    p.lineTo((glyph.width, -fontinfo["openTypeOS2TypoDescender"]))
    p.closePath()

    glf = builddir+glifLib.glyphNameToFileName(glifname+"_guidelines", None)
    tempf = tempfile.mkstemp()[1]
    with open(tempf, "w+") as f:
        print(glyph.dumpToGLIF(), file=f)
    if glyph.width == 0:
        shutil.copyfile(tempf, glf)
    else:
        subprocess.run("MFEKstroke CWS -i {} -o {} -w 30".format(tempf, glf), **SUBPROCESS_KWARGS)
    glyph.clearContours()

    p.moveTo((0, fontinfo["xHeight"]))
    p.lineTo((glyph.width, fontinfo["xHeight"]))
    p.closePath()

    xhf = builddir+glifLib.glyphNameToFileName(glifname+"_xheight", None)
    with open(tempf, "w+") as f:
        print(glyph.dumpToGLIF(), file=f)
    if glyph.width == 0:
        shutil.copyfile(tempf, glf)
    else:
        subprocess.run("MFEKstroke PAP --pattern patterns.ufo/glyphs/dot.glif --path {} --out {} -m repeated --sx 0.1 --sy 0.1 --spacing 30 -s 3 --simplify false".format(tempf, xhf), **SUBPROCESS_KWARGS)
    glyph.clearContours()

    for pt in firsts:
        drawSquare(p, pt[0])

    with open(builddir+glifLib.glyphNameToFileName(glifname+"_beginnings", None), "w+") as f:
        print(glyph.dumpToGLIF(), file=f)
    glyph.clearContours()

    for pt in lasts:
        drawSquare(p, pt[-1])

    with open(builddir+glifLib.glyphNameToFileName(glifname+"_endings", None), "w+") as f:
        print(glyph.dumpToGLIF(), file=f)
    glyph.clearContours()

print(glifname)
subprocess.run(r"""python3 ./scripts/make_arrows_for_glyph.py {} {}""".format(gliffn, builddir+glifLib.glyphNameToFileName(glifname+"_arrows", None)), **SUBPROCESS_KWARGS)
