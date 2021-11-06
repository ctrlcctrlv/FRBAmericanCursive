#!/usr/bin/env python3
import csv
import sys
from fontTools import ufoLib

_, csv_fn = sys.argv

handled_classes = list()

print("feature mark {")

with open(csv_fn) as csvf:
    r = csv.reader(csvf, delimiter="\t")
    for row in r:
        if len(row) != 4: continue
        (glyph, x, y, mark_class) = row
        if mark_class not in handled_classes:
            print("    markClass @{0}_marks <anchor 0 -350> @{0};".format(mark_class))
            handled_classes.append(mark_class)
        print("    position base {} <anchor {} {}> mark @{};".format(glyph, x, y, mark_class))

print("} mark;")
