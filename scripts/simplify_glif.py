#!/usr/bin/env python3

import shutil
import os.path
import subprocess
import sys
import tempfile

(_, gliffn, simplify_accuracy) = sys.argv

from xml.etree.ElementTree import ElementTree

with open(gliffn, "rb") as xml:
    tree = ElementTree(file=xml)
    root = tree.getroot()

advance = root.find("advance")

if advance is not None:
    width = advance.attrib["width"] or 0
else:
    width = 0

import fontforge

f = fontforge.font()
g = f.createChar(-1, "glif")
g.importOutlines(gliffn)
g.simplify(float(simplify_accuracy))
g.width = int(width)
# Can't just export as glif - FontForge UFO glif export has issues.
#(_, tempout) = tempfile.mkstemp(suffix=".glif")
#g.export(tempout)
(_, tempsfd) = tempfile.mkstemp(suffix=".sfd")
f.save(tempsfd)
tempufo = tempfile.mkdtemp(suffix=".ufo")

tempglif = "{}/glyphs/glif.glif".format(tempufo)

# If the simplify fails it's not that big of a deal, just keep the complex version.
if os.path.isfile(tempglif) and os.path.getsize(tempglif) > 0:
    subprocess.run(["sfd2ufo", "--minimal", tempsfd, tempufo])
    shutil.move(tempglif, gliffn)
