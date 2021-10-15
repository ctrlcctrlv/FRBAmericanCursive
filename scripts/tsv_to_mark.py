#!/usr/bin/env python3
import csv
import sys
from fontTools import ufoLib

_, csv_fn, ufo_fn = sys.argv

with open("build_data/top_marks") as f:
    top_marks = f.read().strip().split()
    print("@top_marks = [{}];".format(' '.join(top_marks)))

gdefsimple = list()
f = ufoLib.UFOReaderWriter(ufo_fn)
for _, g in f.getCharacterMapping().items():
    for gg in g:
        if gg not in top_marks:
            gdefsimple.append(gg)

print("@GDEFSimple = [{}];".format(" ".join(gdefsimple)))

print("""
table GDEF {
    GlyphClassDef @GDEFSimple,,@top_marks,;
} GDEF;
""")

print("feature mark {")
print("    markClass @top_marks <anchor 0 0> @top;")

with open(csv_fn) as csvf:
    r = csv.reader(csvf, delimiter="\t")
    for row in r:
        (glyph, x, y) = row
        print("    position base {} <anchor {} {}> mark @top;".format(glyph, x, y))

print("} mark;")
