#!/usr/bin/env python3
import csv
import io
import os
import sys
from pathlib import Path
from fontTools.feaLib.parser import Parser
from fontTools.feaLib.ast import *

IGNORE_LIGATURES=0x4

f = io.StringIO("""
include(""" + Path(__file__).parent.parent.as_posix() + """/fea/classes.fea);
include(""" + Path(__file__).parent.parent.as_posix() + """/fea/GDEF.fea);
""")
fea = FeatureFile()
fea.statements.append(Comment("# Warning: Auto-generated file. See scripts/tsv_to_mark.py"))
p = Parser(f, followIncludes=True, includeDir='.')
ff = p.parse()
glyphclasses = [c for c in ff.statements if isinstance(c, GlyphClassDefinition)]
glyphclasses_d = {c.name: c.glyphSet() for c in ff.statements if isinstance(c, GlyphClassDefinition)}
marks = [c for c in glyphclasses if c.name == "GDEFMarks"]
assert len(marks) > 0, "No marks in GDEF.fea?"
all_marks = marks[0].glyphSet()
stroke_marks = [c for c in glyphclasses if c.name == "stroke_marks"]
assert len(marks) > 0, "No stroke_marks in classes.fea?"
all_stroke_marks = stroke_marks[0].glyphSet()
tails = [c for c in glyphclasses if c.name == "tails"]
if len(tails) > 0:
    all_tails = tails[0].glyphSet()


_, csv_fn = sys.argv

handled_classes = dict()

NUMBERS_OFFSETS={}

with open(os.path.abspath(os.path.join(os.path.dirname(__file__), *("..", "build_data", "numbers_offset.tsv")))) as numbers_tsvf:
    r = csv.reader(numbers_tsvf, delimiter="\t")
    for i, row in enumerate(r): NUMBERS_OFFSETS["stroke{}".format(i)] = (row[0], row[1])

rules = dict()
rules_glyphs = dict()

all_mark_classes_in_tsv = dict()

maxlen = dict()

int_to_mc = lambda i: "stroke{}".format(i)
mc_to_int = lambda mc: int("".join(filter(str.isdigit, mc)))
prev_mc = lambda mc: "stroke{}".format(mc_to_int(mc)-1)
next_mc = lambda mc: "stroke{}".format(mc_to_int(mc)+1)

with open(csv_fn) as csvf:
    r = csv.reader(csvf, delimiter="\t")
    for row in r:
        if len(row) < 4: continue
        mc = row[3]
        glyph = row[0]
        if mc not in all_mark_classes_in_tsv:
            all_mark_classes_in_tsv[mc] = list()
        all_mark_classes_in_tsv[mc].append(glyph)
        if "stroke" in mc:
            if glyph not in maxlen or mc_to_int(mc) > maxlen[glyph]:
                maxlen[glyph] = mc_to_int(mc)

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
            pos = MarkMarkPosStatement(GlyphName(glyph), [(Anchor(x, y), MarkClass(mc)) for mc in list(all_mark_classes_in_tsv.keys())])
            if not mark_class in rules_glyphs:
                rules_glyphs[mark_class] = list()
            rules_glyphs[mark_class].append(glyph)
        elif glyph not in all_tails:
            pos = MarkBasePosStatement(GlyphName(glyph), [(Anchor(x, y), MarkClass(mark_class))])
        else:
            continue
        if not mark_class in rules:
            rules[mark_class] = list()
        rules[mark_class].append(pos)

feature = FeatureBlock("mark")
featuremkmk = FeatureBlock("mark")
lookup_filename_root = csv_fn[csv_fn.rindex('/')+1:csv_fn.rindex('.')]
if len(handled_classes) == 1:
    lookup_names_append = {k: lookup_filename_root for k in handled_classes.keys()}
else:
    lookup_names_append = {k: "{}_{}".format(lookup_filename_root, c.name) for k, c in handled_classes.items()}
lookups = {k: LookupBlock("mark_"+lookup_names_append[k]) for k, c in handled_classes.items()}
lookups_mark = {k: LookupBlock("markmk_"+lookup_names_append[k]) for k, c in handled_classes.items()}
for k, hcv in handled_classes.items():
    markFilteringSet = GlyphClass(hcv.glyphSet())
    lookups[k].statements.append(LookupFlagStatement(value=IGNORE_LIGATURES, markFilteringSet=markFilteringSet))
    lookups[k].statements += [rule for rule in rules[k] if isinstance(rule, MarkBasePosStatement)]
    feature.statements.append(lookups[k])
for k, hcv in handled_classes.items():
    if k in rules_glyphs:
        lmgc = list(all_stroke_marks)+rules_glyphs[k]
    else:
        lmgc = all_stroke_marks
    if "stroke" in k:
        lmgc = sorted(set(lmgc))[mc_to_int(k):]
    lookups_mark[k].statements.append(LookupFlagStatement(value=IGNORE_LIGATURES, markFilteringSet=GlyphClass(lmgc)))
    lookups_mark[k].statements += [rule for rule in rules[k] if isinstance(rule, MarkMarkPosStatement)]
    if len(lookups_mark[k].statements) > 1:
        featuremkmk.statements.append(lookups_mark[k])
    elif "stroke" in k:
        lookups_mark[k].statements = [lookups_mark[k].statements[0]]+lookups_mark[next_mc(int_to_mc((mc_to_int(k)%2)))].statements[1:]
        featuremkmk.statements.append(lookups_mark[k])
featuremkmk.statements = reversed(featuremkmk.statements)
fea.statements.append(featuremkmk)
fea.statements.append(feature)

print(fea.asFea())
