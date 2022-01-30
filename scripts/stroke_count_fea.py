#!/usr/bin/env python3
import io
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
glyphclasses_d = {c.name: c.glyphSet() for c in ff.statements if isinstance(c, GlyphClassDefinition)}
marks = [c for c in glyphclasses if c.name == "GDEFMarks"]
assert len(marks) > 0, "No marks in GDEF.fea?"
tails = [c for c in glyphclasses if c.name == "tails"]
assert len(tails) > 0, "No tails in GDEF.fea?"
simple = [c for c in glyphclasses if c.name == "GDEFSimple"]
assert len(simple) > 0, "No simple in GDEF.fea?"
all_marks = marks[0].glyphSet()
all_tails = tails[0].glyphSet()
all_simple = simple[0].glyphSet()
lookup = LookupBlock("combstroke")
try:
    while (line := input()):
        print(line, file=sys.stderr)
        glif, count = line.split()
        if int(count) == 0:
            continue
        if glif in all_tails:
            continue
        if glif in all_marks:
            lookup.statements.append(MultipleSubstStatement([], GlyphName(glif), [], [GlyphName(glif)]+[GlyphName("__combstroke"+str(2)) for i in range(2, 3)]))
        else:
            lookup.statements.append(MultipleSubstStatement([], GlyphName(glif), [], [GlyphName(glif)]+[GlyphName("__combstroke"+str(i)) for i in range(1, int(count)+1)]))
except EOFError: pass
print(lookup.asFea())
