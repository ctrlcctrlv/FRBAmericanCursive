#!/usr/bin/env python3
import plistlib
import sys

(_, font, plainufo) = sys.argv
with open(plainufo+"/glyphs/contents.plist", "rb") as f:
    glyphs = set(plistlib.load(f).keys())

from fontTools.colorLib.builder import buildCOLR, buildCPAL
from fontTools.ttLib.ttFont import TTFont
with open(font, "rb") as f:
    ttf = TTFont(f)
ttfglyphs = ttf.getGlyphNames()

COLR_GA = {}
COLR_G = {}
for glyph in glyphs:
    if not glyph+"_guidelines" in ttfglyphs: continue
    COLR_GAv = [(glyph+"_guidelines", 0), (glyph, 1), (glyph+"_beginnings", 2), (glyph+"_endings", 3), (glyph+"_arrows", 4)]
    COLR_Gv = [(glyph+"_guidelines", 0), (glyph, 1)]

    COLR_GA[glyph] = COLR_GAv
    COLR_G[glyph] = COLR_Gv

C_O_L_R_GA = buildCOLR(COLR_GA)
C_O_L_R_G = buildCOLR(COLR_G)

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

palette = [BABYBLUE, BLACK, RED, CYAN, RED]
CPAL_palette = [(r/255., g/255., b/255., 1.0) for (r,g,b) in palette]
C_P_A_L_ = buildCPAL([CPAL_palette])

ttf["COLR"] = C_O_L_R_GA
ttf["CPAL"] = C_P_A_L_
ttf.save(font)

ttf["COLR"] = C_O_L_R_G
ttf.save(font.replace("GuidelinesArrows", "Guidelines"))
