#!/usr/bin/env python3
import csv
import os
import sys
from fontTools import ufoLib

_, csv_fn = sys.argv

handled_classes = list()

NUMBERS_OFFSETS={}

with open(os.path.abspath(os.path.join(os.path.dirname(__file__), *("..", "build_data", "numbers_offset.tsv")))) as numbers_tsvf:
    r = csv.reader(numbers_tsvf, delimiter="\t")
    for i, row in enumerate(r): NUMBERS_OFFSETS["stroke{}".format(i)] = (row[0], row[1])

print("feature mark {")

with open(csv_fn) as csvf:
    r = csv.reader(csvf, delimiter="\t")
    for row in r:
        offset_x = 0
        offset_y = 0

        if len(row) == 4:
            (glyph, x, y, mark_class) = row
            anchor_offset_y = 0
        elif len(row) == 5:
            (glyph, x, y, mark_class, anchor_offset_y) = row
        else:
            continue

        (x, y) = (int(x), int(y))

        if mark_class in NUMBERS_OFFSETS:
            (offset_x, offset_y) = [int(i) for i in NUMBERS_OFFSETS[mark_class]]
        else:
            (offset_x, offset_y) = (0, 0)

        if mark_class not in handled_classes:
            print("    markClass @{0}_marks <anchor {1} {2}> @{0};".format(mark_class, 0, anchor_offset_y))
            handled_classes.append(mark_class)
        print("    position base {} <anchor {} {}> mark @{};".format(glyph, x+offset_x, y+offset_y, mark_class))

print("} mark;")
