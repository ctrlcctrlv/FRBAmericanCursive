#!/usr/bin/env python3

import glob
import os
import sys

(_, glyphsdir) = sys.argv

import plistlib
import re

glyphs = dict()

for f in glob.glob(glyphsdir+"/*"):
    f = f[f.rindex(os.sep)+1:]
    if f == "contents.plist": continue
    ff = f.removesuffix(".glif")
    m = re.sub(r"([A-Z])_", r"\1", ff)
    glyphs[m] = f

print(plistlib.dumps(glyphs).decode("utf-8"))
