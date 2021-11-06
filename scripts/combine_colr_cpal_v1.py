#!/usr/bin/env python3
import plistlib
import sys

(_, ga_font, plainufo) = sys.argv

g_font = ga_font.replace("GuidelinesArrows", "Guidelines")

with open(plainufo+"/glyphs/contents.plist", "rb") as f:
    glyphs = set(plistlib.load(f).keys())

from fontTools.colorLib.builder import buildCOLR, buildCPAL, LayerListBuilder
from fontTools.ttLib.ttFont import TTFont
from fontTools.ttLib.tables.otTables import Paint, PaintFormat

builder = LayerListBuilder()

with open(ga_font, "rb") as f:
    ga_ttf = TTFont(f)

with open(g_font, "rb") as f:
    g_ttf = TTFont(f)

ga_ttfglyphs = ga_ttf.getGlyphNames()

def buildCOLRv1Solid(glyph, idx):
    return (PaintFormat.PaintGlyph, (PaintFormat.PaintSolid, idx), glyph)

def buildCOLRv1ColrLayers(d):
    return {k: (PaintFormat.PaintColrLayers, v) for k, v in d.items()}

COLR_GA = {}
COLR_G = {}
for glyph in glyphs:
    if glyph.startswith("__combstroke"):
        COLR_GAv = [buildCOLRv1Solid(glyph, 1)]
        COLR_Gv = [buildCOLRv1Solid(glyph, 1)]
    elif not glyph+"_guidelines" in ga_ttfglyphs:
        continue
    else:
        COLR_GAv = [buildCOLRv1Solid(glyph+"_guidelines", 0), buildCOLRv1Solid(glyph+"_xheight", 0), buildCOLRv1Solid(glyph, 0xFFFF), buildCOLRv1Solid(glyph+"_beginnings", 1), buildCOLRv1Solid(glyph+"_endings", 2), buildCOLRv1Solid(glyph+"_arrows", 1)]
        COLR_Gv = [buildCOLRv1Solid(glyph+"_guidelines", 0), buildCOLRv1Solid(glyph+"_xheight", 0), buildCOLRv1Solid(glyph, 0xFFFF)]

    COLR_GA[glyph] = COLR_GAv
    COLR_G[glyph] = COLR_Gv

C_O_L_R_GA = buildCOLR(buildCOLRv1ColrLayers(COLR_GA))
C_O_L_R_G = buildCOLR(buildCOLRv1ColrLayers(COLR_G))

# guidelines
BABYBLUE = (0, 178, 194)
# glyph
BLACK = (0, 0, 0)
# beginnings
RED = (255, 0, 0)
# endings
BLUE = (0, 0, 255)
CYAN = (0, 255, 255)
# arrows
YELLOW = (255, 202, 243)
GREY = (50, 50, 50)

palette = [BABYBLUE, RED, CYAN]
CPAL_palette = [(r/255., g/255., b/255., 1.0) for (r,g,b) in palette]
C_P_A_L_ = buildCPAL([CPAL_palette])

ga_ttf["COLR"] = C_O_L_R_GA
ga_ttf["CPAL"] = C_P_A_L_
ga_ttf.save(ga_font)

g_ttf["COLR"] = C_O_L_R_G
g_ttf["CPAL"] = C_P_A_L_
g_ttf.save(g_font)
