#!/usr/bin/env python3
from xml.etree.ElementTree import ElementTree

import sys
import tempfile

(_, reqlen) = sys.argv
reqlen = float(reqlen)

MAXLEN = 300

with open("patterns.ufo/glyphs/line.glif") as f:
    dom = ElementTree(file=f)

for c in dom.getroot().find("outline").findall("contour"):
    for p in c.findall("point"):
        if p.get("name") not in ['B', 'T']: continue
        x = float(p.get("x"))
        y = float(p.get("y"))
        moveby = min(reqlen, MAXLEN)
        x = x-moveby
        p.set("x", str(x))

    (_, tfn) = tempfile.mkstemp(suffix=".glif")
    tf = open(tfn, "wb+")
    dom.write(tf)
    print(tfn)
