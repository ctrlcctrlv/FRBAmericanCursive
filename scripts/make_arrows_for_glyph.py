#!/usr/bin/env python3

from xml.etree.ElementTree import ElementTree

import os
import shutil
import sys

import subprocess
import tempfile

if len(sys.argv) == 2:
    (_, gliffn) = sys.argv
    finalfn = None
elif len(sys.argv) == 3:
    (_, gliffn, finalfn) = sys.argv
else:
    raise NotImplementedError

# First we need to split the glyph into its constituent contours
with open(gliffn, "rb") as f:
    dom = ElementTree(file=f)
    root = dom.getroot()

if root.find("outline") is None:
    if finalfn is None:
        sys.exit(0)
    else:
        shutil.copyfile(gliffn, finalfn)
        sys.exit(0)

contours = root.find("outline").findall("contour")

split_glifs = list()

for i, contour in enumerate(contours):
    root.find("outline").clear()
    root.find("outline").append(contour)
    fn = os.sep+"tmp"+os.sep+gliffn.split(os.sep)[-1]+str(i)
    with open(fn, "wb+") as f:
        dom.write(f)
    split_glifs.append(fn)

# Then we need to measure the contours. Using glifpathlen: https://github.com/ctrlcctrlv/glifpathlen
split_glif_lengths = list()

for glif in split_glifs:
    length = subprocess.run(["glifpathlen", glif], capture_output=True).stdout
    split_glif_lengths.append(float(length))

# Then we need to make arrow glyphs for each contour length
arrow_glyphs = list()

for length in split_glif_lengths:
    arrowglif = subprocess.run(["python3", "./scripts/make_arrow_glyph.py", str(length-70)], capture_output=True)
    stdout = arrowglif.stdout
    arrow_glyphs.append(stdout.decode("utf-8").strip())

# Then we need to call MFEKstroke
output_arrows = list()
for i, arrow in enumerate(arrow_glyphs):
    out = subprocess.run(["MFEKstroke", "PAP", "-m", "single", "--pattern", arrow, "--path", split_glifs[i], "--out", split_glifs[i]+"_arrow", "--noffset=-50", "--toffset=-5", "-s", "4", "--sx", "0.5", "--sy", "0.5"])
    output_arrows.append(split_glifs[i]+"_arrow")

# Then we need to join all the glif files
gliffnb = gliffn.split(os.sep)[-1]
outfile = gliffnb[:gliffnb.rindex(".")]+"_arrows.glif"
outfile_cws = outfile[:outfile.rindex(".")]+"_cws.glif"
outpath = os.sep + "tmp" + os.sep + outfile
outpath_cws = os.sep + "tmp" + os.sep + outfile_cws

with open(output_arrows[0], "rb") as af:
    dom = ElementTree(file=af)
    root = dom.getroot()

for arrow in output_arrows[1:]:
    with open(arrow, "rb") as af:
        adom = ElementTree(file=af)
        aroot = adom.getroot()

    contours = aroot.find("outline").findall("contour")
    root.find("outline").extend(contours)

with open(outpath, "wb+") as f:
    dom.write(f)

out = subprocess.run(["MFEKstroke", "cws", "-i", outpath, "-w", "30", "-o", outpath_cws, "-s", "square", "-e", "patterns.ufo/glyphs/arrowhead.glif"])

if finalfn is not None:
    shutil.copyfile(outpath_cws, finalfn)
    os.unlink(outpath_cws)
else:
    print(outpath_cws)

#print(contours)
#print(split_glifs)
#print(arrow_glyphs)
#print(output_arrows)
#print(split_glif_lengths)
[os.unlink(fn) for fn in split_glifs]
[os.unlink(fn) for fn in arrow_glyphs]
[os.unlink(fn) for fn in output_arrows]
os.unlink(outpath)
