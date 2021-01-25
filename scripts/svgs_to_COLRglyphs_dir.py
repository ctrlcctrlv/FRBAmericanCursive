#!/usr/bin/env python3
import glob
import re
import shutil

import fontforge

from fontTools.svgLib import SVGPath

files = glob.glob("build/SVG_layers/*")
svgs_re = "build/SVG_layers/.*_(arrows|beginnings|endings|guidelines).svg"
glyph_name_re = "([a-zA-Z0-9_\.-]+)\.svg$"

f = fontforge.font()
f.ascent = 650
f.descent = 350

for svg in files:
    if re.match(svgs_re, svg):
        gr = re.search(glyph_name_re, svg)
        if not gr: continue
        g = f.createChar(-1, gr.group(1))
        g.importOutlines(svg, scale=False, simplify=False)
        with open(svg, "rb") as svgf:
            outline = SVGPath.fromstring(svgf.read())
        width = int(outline.root.get("width").replace("px",""))
        g.width = width

try:
    shutil.rmtree("build/COLR_glyphs")
except OSError: pass
f.generate("build/COLRGlyphs.ufo")
shutil.copytree("build/COLRGlyphs.ufo/glyphs", "build/COLR_glyphs")
shutil.rmtree("build/COLRGlyphs.ufo")
