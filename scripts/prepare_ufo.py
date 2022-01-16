#!/usr/bin/env python3
# - massage the UFO metadata (Regular → whatever weight being built)
import shutil
import os, sys
import subprocess
import tempfile
import unicodedata
import csv
from pathlib import Path

import extractor, defcon
import plistlib
from fontTools import ufoLib

# in scripts dir
import build_ccmp

_, namedweight, os2weight = sys.argv
os2weight = int(os2weight)

outname = "build/{}-{}.ufo".format(os.environ["FONTFAMILY"], namedweight)
# This is a rudimentary cache.
preserved = [Path(outname) / "data" / "glyphs.txt", Path(outname) / "data" / "physics.tsv"]
tempfiles = {p: tempfile.NamedTemporaryFile(encoding="utf-8") for p in preserved}
preserved_data = list()
for path in preserved:
    if path.is_file():
        with open(path, 'r', encoding="utf-8") as f:
            data = f.read()
        tempfiles[path].write(data)
    else:
        tempfiles[path].close()
        del tempfiles[path]

try:
    shutil.rmtree(outname)
except OSError: pass

shutil.copytree("build/BUILD.ufo", outname)

ufo = ufoLib.UFOReaderWriter(outname)
build_ccmp.create_and_build_placeholders(ufo)

if glyphstxt_data is not None and len(glyphstxt_data) > 0:
    shutil.copyfile(tempglyphstxt.name, glyphstxt)
