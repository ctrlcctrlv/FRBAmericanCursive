#!/usr/bin/env python3
import csv
import os
import sys
from fontTools import ufoLib
from list_glyphs import list_glyphs

from fontTools.feaLib.ast import *

_, ufo_fn = sys.argv

fea = FeatureFile()
fea_minus = FeatureFile()
fea_stroke = FeatureFile()

with open("build_data/{}_mark_classes.tsv".format(os.environ["FONTFAMILY"])) as f:
    classes = [r.strip() for r in f.readlines()]

all_marks = list()
tails = list()

def dset(L):
    L = list(dict.fromkeys(L))
    L.sort()
    return L

strokemarks = ['stroke{}_marks'.format(i) for i in range(1, 10)]
combstrokes = [GlyphName('__combstroke{}'.format(i)) for i in range(1, 10)]
for (i, _) in enumerate(strokemarks):
    fea_stroke.statements.append(GlyphClassDefinition(strokemarks[i], GlyphClass([combstrokes[i]])))
    fea_stroke.statements.append(GlyphClassDefinition(strokemarks[i]+"_all", GlyphClass([combstrokes[i], combstrokes[i].glyph+".big"])))

fea.statements.extend(fea_stroke.statements)

classes_gcd = list()
for cn in classes:
    with open("build_data/{}_marks".format(cn)) as f:
        if cn != "stroke":
            marks_gn = [GlyphName(m.strip()) for m in f.read().strip().split() if len(m) > 0]
            marks = GlyphClass(marks_gn)
            gcd = [GlyphClassDefinition(cn+"_marks", marks)]
        else:
            marks = GlyphClass(combstrokes)
            gcd = [GlyphClassDefinition("stroke_marks", GlyphClass(combstrokes)), GlyphClassDefinition("stroke_marks_all", GlyphClass([GlyphName("@stroke_marks")]+[GlyphName(c.glyph+".big") for c in combstrokes]))]

        fea.statements.extend(gcd)
            
        if len(marks.glyphSet()) >= 2:
            for mark in marks.glyphSet():
                markok = mark.glyph.replace('.', '_').replace('@','')
                fea_minus.statements.append(GlyphClassDefinition(cn+"_marks_minus_"+markok, GlyphClass(sorted(set([g.glyph for g in marks.glyphSet()]) - set([mark.glyph])))))
        all_marks.extend(list(marks.glyphSet()))
        classes_gcd.extend(gcd)

fea.statements.append(Comment("\nBegin minus classes\n"))
fea.statements.extend(fea_minus.statements)
fea.statements.append(Comment("\nEnd minus classes\n"))

all_marks_gn = [g.glyph for g in all_marks]
gdefsimple = list()
by_encoding = list()
f = ufoLib.UFOReaderWriter(ufo_fn)
sorted_glyphs = list_glyphs(f)
for g, _ in sorted_glyphs.items():
    g = GlyphName(g)
    if g.glyph not in all_marks_gn and not g.glyph.startswith("tail."):
        if g.glyph.startswith("uni") and len(g.glyph) <= len("uniFFFFFF"):
            by_encoding.append(g)
        else:
            gdefsimple.append(g)
    elif g.glyph.startswith("tail."):
        tails.append(g)

tails_gcd = GlyphClassDefinition("tails", GlyphClass(tails))
fea.statements.append(tails_gcd)
by_encoding_gcd = GlyphClassDefinition("by_encoding", GlyphClass(by_encoding))
fea.statements.append(by_encoding_gcd)
fea.statements.append(Comment("Begin GDEF classes"))
fealen = len(fea.statements)
fea.statements.append(GlyphClassDefinition("GDEFSimple", GlyphClass([GlyphName(g) for g in sorted([g.glyph for g in gdefsimple])+[GlyphName("@by_encoding")]])))
fea.statements.append(GlyphClassDefinition("GDEFMarks", GlyphClass([GlyphName("@"+gcd.name) for gcd in classes_gcd])))
fea.statements.append(GlyphClassDefinition("GDEFLigat", GlyphClass([GlyphName("@tails")])))
fea.statements.append(GlyphClassDefinition("GDEFComponent", GlyphClass([])))
fea.statements.append(Comment("End GDEF classes"))
for cn in sorted(classes):
    classesm = set(classes) - set([cn])
    fea.statements.append(GlyphClassDefinition("GDEFMarks_minus_"+cn, GlyphClass([GlyphName("@"+cn+"_marks") for cn in sorted(classesm)])))

gdef = TableBlock("GDEF")
gdef.statements = [
GlyphClassDefStatement(*[GlyphName("@"+gcd.name) for gcd in fea.statements[fealen:fealen+4]])
]

fea.statements.append(gdef)

print(fea.asFea())
