#!/usr/bin/env python3
import csv
import sys
import fontforge

with open("build_data/top_marks") as f:
    top_marks = f.read().strip().split()
    print("@top_marks = [{}];".format(' '.join(top_marks)))

gdefsimple = list()
f = fontforge.open("FRBAmericanCursive.sfd")
for g in f.glyphs():
    if g.glyphname not in top_marks:
        gdefsimple.append(g.glyphname)

print("@GDEFSimple = [{}];".format(" ".join(gdefsimple)))

print("""
table GDEF {
    GlyphClassDef @GDEFSimple,,@top_marks,;
} GDEF;
""")

print("feature mark {")
print("    markClass @top_marks <anchor 0 0> @top;")

with open(sys.argv[1]) as csvf:
    r = csv.reader(csvf, delimiter="\t")
    for row in r:
        (glyph, x, y) = row
        print("    position base {} <anchor {} {}> mark @top;".format(glyph, x, y))

print("} mark;")
