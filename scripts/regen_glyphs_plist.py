#!/usr/bin/env python3

import glob
import os
import sys

(_, glyphsdir) = sys.argv

import plistlib
import re

glyphs = dict()

for f in glob.glob(glyphsdir+"/*.glif"):
    f = f[f.rindex(os.sep)+1:]
    ff = f.removesuffix(".glif")
    m = re.sub(r"([A-Z])_", r"\1", ff)
    if m == "_notdef":
        m = ".notdef"
    glyphs[m] = f

with open(glyphsdir+"/contents.plist", "w+b") as fp:
    plistlib.dump(glyphs, fp)
