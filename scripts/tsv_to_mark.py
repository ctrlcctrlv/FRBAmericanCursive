#!/usr/bin/env python3
import csv
import io
import os
import sys
from pathlib import Path
from fontTools.feaLib.parser import Parser
from fontTools.feaLib.ast import *

f = io.StringIO("""
include(""" + Path(__file__).parent.parent.as_posix() + """/fea/classes.fea);
include(""" + Path(__file__).parent.parent.as_posix() + """/fea/GDEF.fea);
""")
fea = FeatureFile()
fea.statements.append(Comment("# Warning: Auto-generated file. See scripts/tsv_to_mark.py"))
p = Parser(f, followIncludes=True, includeDir='.')
ff = p.parse()
glyphclasses = [c for c in ff.statements if isinstance(c, GlyphClassDefinition)]
marks = [c for c in glyphclasses if c.name == "GDEFMarks"]
assert len(marks) > 0, "No marks in GDEF.fea?"
all_marks = marks[0].glyphSet()
tails = [c for c in glyphclasses if c.name == "tails"]
if len(tails) > 0:
    all_tails = tails[0].glyphSet()


_, csv_fn = sys.argv
no_filter = "NOFILTER" in os.environ and os.environ["NOFILTER"].strip() == "1"

handled_classes = dict()

NUMBERS_OFFSETS={}

with open(os.path.abspath(os.path.join(os.path.dirname(__file__), *("..", "build_data", "numbers_offset.tsv")))) as numbers_tsvf:
    r = csv.reader(numbers_tsvf, delimiter="\t")
    for i, row in enumerate(r): NUMBERS_OFFSETS["stroke{}".format(i)] = (row[0], row[1])

rules = list()

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
            anchor_offset_y = int(anchor_offset_y)
        else:
            continue

        (x, y) = (int(x), int(y))

        if glyph == "_notdef":
            glyph = ".notdef"

        if mark_class in NUMBERS_OFFSETS:
            (offset_x, offset_y) = [int(i) for i in NUMBERS_OFFSETS[mark_class]]
        else:
            (offset_x, offset_y) = (0, 0)

        if mark_class not in handled_classes:
            mc = MarkClass(mark_class)
            mc.addDefinition( MarkClassDefinition(mc, Anchor(offset_x, anchor_offset_y+offset_y), GlyphClass(next((c for c in glyphclasses if c.name == mark_class+"_marks"), None).glyphSet())) )
            handled_classes[mark_class] = mc
            fea.statements.append(mc)
        if glyph in set(set(all_marks) - set(all_tails)):
            pos = MarkMarkPosStatement(GlyphName(glyph), [(Anchor(x, y), MarkClass(mark_class))])
        elif glyph not in all_tails:
            pos = MarkBasePosStatement(GlyphName(glyph), [(Anchor(x, y), MarkClass(mark_class))])
        else:
            continue
        rules.append(pos)

feature = FeatureBlock("mark")
lookup = LookupBlock("mark_%s" % csv_fn[csv_fn.rindex('/')+1:csv_fn.rindex('.')])
if not no_filter:
    markFilteringSet = GlyphClass([g for g in [c.glyphSet() for c in handled_classes.values()] for g in g ])
else:
    markFilteringSet = None
lookup.statements.append(LookupFlagStatement(value=0, markFilteringSet=markFilteringSet))
lookup.statements += [rule for rule in rules if isinstance(rule, MarkBasePosStatement)]
lookup_mark = LookupBlock("markmk_%s" % csv_fn[csv_fn.rindex('/')+1:csv_fn.rindex('.')])
lookup_mark.statements = [rule for rule in rules if isinstance(rule, MarkMarkPosStatement)]
feature.statements.append(lookup)
if len(lookup_mark.statements) > 0:
    feature.statements.append(lookup_mark)
fea.statements.append(feature)

print(fea.asFea())
