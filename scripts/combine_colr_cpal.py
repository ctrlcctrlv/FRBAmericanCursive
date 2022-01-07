#!/usr/bin/env python3
import plistlib
import sys

(_, ga_font, plainufo) = sys.argv

g_font = ga_font.replace("GuidelinesArrows", "Guidelines")

with open(plainufo+"/glyphs/contents.plist", "rb") as f:
    glyphs = set(plistlib.load(f).keys())

from fontTools.colorLib.builder import buildCOLR, buildCPAL
from fontTools.ttLib.ttFont import TTFont
from fontTools.ttLib.tables.otTables import Paint

with open(ga_font, "rb") as f:
    ga_ttf = TTFont(f)

with open(g_font, "rb") as f:
    g_ttf = TTFont(f)

ga_ttfglyphs = ga_ttf.getGlyphNames()

COLR_GA = {}
COLR_G = {}
for glyph in glyphs:
    if glyph.startswith("__combstroke"):
        COLR_GAv = [(glyph, 1)]
        COLR_Gv = [(glyph, 1)]
    elif not glyph+"_guidelines" in ga_ttfglyphs:
        continue
    else:
        COLR_GAv = [(glyph+"_guidelines", 0), (glyph+"_xheight", 0), (glyph+"_baseline", 2), (glyph, 0xFFFF), (glyph+"_beginnings", 3), (glyph+"_endings", 4), (glyph+"_arrows", 1)]
        COLR_Gv = [(glyph+"_guidelines", 0), (glyph+"_xheight", 0), (glyph+"_baseline", 2), (glyph, 0xFFFF)]

    COLR_GA[glyph] = COLR_GAv
    COLR_G[glyph] = COLR_Gv

C_O_L_R_GA = buildCOLR(COLR_GA)
C_O_L_R_G = buildCOLR(COLR_G)

# guidelines
BABYBLUE = (0, 178, 194)
## baseline guideline
DEEPPURPLE = (0xE9, 0x1E, 0x85)
# glyph
BLACK = (0, 0, 0)
# beginnings
RED = (255, 0, 0)
# endings
BLUE = (0, 0, 255)
CYAN = (0, 255, 255)
# arrows
BURGUNDY = (193, 30, 38)
# misc
YELLOW = (255, 202, 243)
GREY = (50, 50, 50)

palette_GA = [BABYBLUE, BURGUNDY, DEEPPURPLE, CYAN, RED]
palette_G = [BABYBLUE, BURGUNDY, DEEPPURPLE]
CPAL_palette = lambda palette: [(r/255., g/255., b/255., 1.0) for (r,g,b) in palette]
C_P_A_L_GA = buildCPAL([CPAL_palette(palette_GA)])
C_P_A_L_G = buildCPAL([CPAL_palette(palette_G)])

ga_ttf["COLR"] = C_O_L_R_GA
ga_ttf["CPAL"] = C_P_A_L_GA
ga_ttf.save(ga_font)

g_ttf["COLR"] = C_O_L_R_G
g_ttf["CPAL"] = C_P_A_L_G
g_ttf.save(g_font)
