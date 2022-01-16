#!/usr/bin/env python3
import csv
import os
import sys
from fontTools import ufoLib
from list_glyphs import list_glyphs

_, ufo_fn = sys.argv

with open("build_data/{}_mark_classes.tsv".format(os.environ["FONTFAMILY"])) as f:
    classes = [r.strip() for r in f.readlines()]

all_marks = list()

def dset(L):
    L = list(dict.fromkeys(L))
    L.sort()
    return L

for cn in classes:
    with open("build_data/{}_marks".format(cn)) as f:
        marks = dset([m.strip() for m in f.read().strip().split() if len(m) > 0])
        print("@{}_marks = [{}];".format(cn, ' '.join(marks)))
        if len(marks) >= 2:
            for mark in marks:
                print("@{}_marks_minus_{} = [{}];".format(cn, mark.replace('.', '_'), ' '.join(dset(set(marks) - set([mark])))))
        all_marks.extend(marks)

gdefsimple = list()
f = ufoLib.UFOReaderWriter(ufo_fn)
sorted_glyphs = list_glyphs(f)
for g, _ in sorted_glyphs.items():
    if g not in all_marks:
        gdefsimple.append(g)

print()
print("@GDEFSimple = [{}];".format(" ".join(gdefsimple)))
print("@GDEFMarks = [{}];".format(" ".join(["@{}_marks".format(cn) for cn in classes])))
print("@GDEFLigat = [];")

strokemarks = ['@stroke{}_marks'.format(i) for i in range(1, 9)]
for i in range(1, 9):
    print("@stroke{0}_marks = [__combstroke{0}];".format(i))

print("""
table GDEF {
    GlyphClassDef @GDEFSimple,@GDEFLigat,@GDEFMarks,;
} GDEF;""")
