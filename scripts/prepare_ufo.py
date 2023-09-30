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

try:
    shutil.rmtree(outname)
except OSError: pass

shutil.copytree("build/BUILD.ufo", outname)

ufo = ufoLib.UFOReaderWriter(outname)
build_ccmp.create_and_build_placeholders(ufo)
