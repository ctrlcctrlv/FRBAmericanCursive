#!/usr/bin/env python3

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
fea.statements.append(Comment("# Warning: Auto-generated file. See scripts/tails_fea.py"))
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

ccmp = FeatureBlock("ccmp")
for t in sorted(set(all_tails)):
    for m in sorted(set(all_marks)):
        ss1 = SingleSubstStatement([GlyphName(t)], [GlyphName(m)], [], [], False)
        ss2 = SingleSubstStatement([GlyphName(m)], [GlyphName(t)], [], [], False)
        lt = t.replace('.', '__')
        lm = m.replace('.', '__')
        l1 = LookupBlock("{}_{}_ccmp".format(lt,lm))
        l2 = LookupBlock("{}_{}_ccmp".format(lm,lt))
        l1.statements = [ss1]
        l2.statements = [ss2]
        fea.statements.append(l1)
        fea.statements.append(l2)
        ccmp.statements.append(ChainContextSubstStatement([], [GlyphName(t), GlyphName(m)], [], [l1, l2])) 

fea.statements.append(ccmp)
print(fea.asFea())
