#!/usr/bin/env python3
# This script does the following:
# - massage the UFO metadata (Regular → whatever weight being built)

import shutil
import os, sys
import subprocess
import tempfile
import unicodedata
import csv

import extractor, defcon

import plistlib

# in scripts dir
import build_ccmp

from fontTools import ufoLib

_, namedweight, strokewidth, os2weight = sys.argv
os2weight = int(os2weight)

outname = "build/{}-{}.ufo".format(os.environ["FONTFAMILY"], namedweight)

try:
    shutil.rmtree(outname)
except OSError: pass

shutil.copytree("build/BUILD.ufo", outname)

ufo = ufoLib.UFOReaderWriter(outname)
build_ccmp.create_and_build_placeholders(ufo)

subprocess.run("./scripts/add_marks_from_data.py {}".format(outname), shell=True, executable="/bin/bash")
subprocess.run("./scripts/fudge_fontinfo.py {} {} {}".format(outname, namedweight, str(os2weight)), shell=True, executable="/bin/bash")
shutil.copy("fea/features.fea", outname+"/features.fea")
subprocess.run("./scripts/reset_features_include_path.py {} {}".format(outname, outname.split("/")[1]), shell=True, executable="/bin/bash")
