#!/usr/bin/env python3
import glob
import re
import shutil
import subprocess

import fontforge

from fontTools.svgLib import SVGPath

files = glob.glob("build/SVG_layers/*")
svgs_re = "build/SVG_layers/.*_(beginnings|endings|guidelines).svg"
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

SUBPROCESS_KWARGS = {"shell": True, "executable": "/bin/bash"}
# This draws the arrows with two passes of MFEKstroke. The other elements of the color fonts are SVG-generated, and already exist in COLR_glyphs.
subprocess.run(r"""find FRBAmericanCursive-SOURCE.ufo/glyphs/ -iname "*.glif" | parallel --bar ./scripts/make_arrows_for_glyph.py {} build/COLR_glyphs/'{= s/(.*)\./\1_arrows./; s@^.*/@@; =}'""", **SUBPROCESS_KWARGS)
# This exposed bugs in FontForge's UFO glif output so has to be disabled for now until I can follow them up...if that's worth doing.
subprocess.run(r"""find build/COLR_glyphs/ -iname "*.glif" -and -iname "*_arrows*" | parallel --bar ./scripts/simplify_glif.py {} 3.0""", **SUBPROCESS_KWARGS)
# This is needed because the script that generates the arrows doesn't modify contents.plist. We rebuild it from glob.glob(...)
subprocess.run("./scripts/regen_glyphs_plist.py build/COLR_glyphs > build/COLR_glyphs/contents.plist", **SUBPROCESS_KWARGS)
