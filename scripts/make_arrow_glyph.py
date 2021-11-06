#!/usr/bin/env python3
from xml.etree.ElementTree import ElementTree

import sys
import tempfile

MAXLEN = 300

def run(reqlen):
    reqlen = float(reqlen)
    with open("patterns.ufo/glyphs/line.glif", encoding="utf8") as f:
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
        return tfn

if __name__ == "__main__":
    (_, reqlen) = sys.argv
    if reqlen == "MAXLEN":
        print(MAXLEN)
    else:
        print(run(reqlen))
