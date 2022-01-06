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
from lib.glyph import Glyph
from fontTools.ufoLib import glifLib
from fontTools.pens.recordingPen import RecordingPen
from fontParts.fontshell.glyph import RGlyph

radius = 5

_, glifname, font, capheight, desc, xheight = sys.argv
capheight=float(capheight)
desc=float(desc)
xheight=float(xheight)

gliffn = "{}/glyphs/{}".format(font, glifLib.glyphNameToFileName(glifname, None))
builddir = "build/{}_COLR_glyphs/".format(os.environ["FONTFAMILY"])
try:
    os.mkdir(builddir)
except OSError:
    pass

def drawSquare(p, pt):
    p.moveTo((pt.x - (radius / 2), pt.y - (radius / 2)))
    p.lineTo((pt.x + (radius / 2), pt.y - (radius / 2)))
    p.lineTo((pt.x + (radius / 2), pt.y + (radius / 2)))
    p.lineTo((pt.x - (radius / 2), pt.y + (radius / 2)))
    p.closePath()

with open(gliffn) as f:
    glyph = RGlyph()
    xml = f.read()
    glyph._loadFromGLIF(xml, validate=False)
    p = glyph.getPen()
    pp = glyph.getPointPen()
    firsts = [c[0] for c in glyph.contours]
    lasts = [c[-1] for c in glyph.contours]
    glyph.clearContours()

    p.moveTo((0, capheight))
    p.lineTo((glyph.width, capheight))
    p.endPath()
    p.moveTo((0, desc))
    p.lineTo((glyph.width, desc))
    p.endPath()

    glf = builddir+glifLib.glyphNameToFileName(glifname+"_guidelines", None)
    tempf = tempfile.mkstemp(suffix=".glif")[1]
    with open(tempf, "w+") as f:
        print(glyph.dumpToGLIF(), file=f)
    if glyph.width <= 0:
        glyph.clearContours()
        with open(glf, "w+") as f:
            print(glyph.dumpToGLIF(), file=f)
    else:
        subprocess.run("MFEKstroke CWS -i {} -o {} -w 30".format(tempf, glf), **SUBPROCESS_KWARGS)
    glyph.clearContours()

    p.moveTo((0, xheight))
    p.lineTo((glyph.width-30, xheight))
    p.endPath()

    xhf = builddir+glifLib.glyphNameToFileName(glifname+"_xheight", None)
    with open(tempf, "w+") as f:
        print(glyph.dumpToGLIF(), file=f)
    if glyph.width <= 30:
        glyph.clearContours()
        with open(xhf, "w+") as f:
            print(glyph.dumpToGLIF(), file=f)
    else:
        subprocess.run("MFEKstroke PaP --pattern patterns.ufo/glyphs/dot.glif --path {} --out {} -m repeated --sx 0.5 --sy 0.5 --spacing 30 --stretch spacing".format(tempf, xhf), **SUBPROCESS_KWARGS)
    glyph.clearContours()

    p.moveTo((0, 0))
    p.lineTo((glyph.width, 0))
    p.endPath()

    glf = builddir+glifLib.glyphNameToFileName(glifname+"_baseline", None)
    tempf = tempfile.mkstemp()[1]
    with open(tempf, "w+") as f:
        print(glyph.dumpToGLIF(), file=f)
    if glyph.width <= 0:
        glyph.clearContours()
        with open(glf, "w+") as f:
            print(glyph.dumpToGLIF(), file=f)
    else:
        subprocess.run("MFEKstroke CWS -i {} -o {} -w 30".format(tempf, glf), **SUBPROCESS_KWARGS)
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
