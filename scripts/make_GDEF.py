#!/usr/bin/env python3
import csv
import sys
from fontTools import ufoLib
from list_glyphs import list_glyphs

_, ufo_fn = sys.argv

with open("build_data/top_marks") as f:
    top_marks = f.read().strip().split()
    print("@top_marks = [{}];".format(' '.join(top_marks)))

gdefsimple = list()
strokemarks = ['@stroke{}_marks'.format(i) for i in range(0, 10)]
for i in range(0, 10):
    print("@stroke{0}_marks = [__combstroke{0}];".format(i))
f = ufoLib.UFOReaderWriter(ufo_fn)
sorted_glyphs = list_glyphs(f)
for g, _ in sorted_glyphs.items():
    if g.startswith("__combstroke") or ".0len" in g:
        continue
    if g not in top_marks:
        gdefsimple.append(g)

print("@stroke_marks = [{}];".format(" ".join(strokemarks)))
print("@GDEFSimple = [{}];".format(" ".join(gdefsimple)))

print("""
table GDEF {
    GlyphClassDef @GDEFSimple,,[@top_marks @stroke_marks quotesingle.0len quoteleft.0len],;
} GDEF;
""")
