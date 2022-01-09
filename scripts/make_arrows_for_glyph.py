#!/usr/bin/env python3

from xml.etree.ElementTree import ElementTree

import os
import shutil
import sys

import subprocess
import tempfile

import make_arrow_glyph

if len(sys.argv) == 2:
    (_, gliffn) = sys.argv
    finalfn = None
    target_size = -25
elif len(sys.argv) == 4:
    (_, gliffn, finalfn, target_size_i) = sys.argv
    target_size = float(target_size_i) / 2.0 - 12.5
    target_size = -target_size;
else:
    raise NotImplementedError

print("Making arrows for {} {} {}".format(gliffn, finalfn, target_size), file=sys.stderr)

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
    fn = tempfile.mkstemp(suffix=".glif")[1]
    with open(fn, "wb+") as f:
        dom.write(f)
    split_glifs.append(fn)

split_glif_lengths = list()

for glif in split_glifs:
    length = subprocess.run(["MFEKmetadata", glif, "glyphpathlen"], capture_output=True).stdout
    split_glif_lengths.append(float(length))

# Then we need to make arrow glyphs for each contour length
arrow_glyphs = list()

for length in split_glif_lengths:
    if length-70 > make_arrow_glyph.MAXLEN:
        arrow_glyphs.append("build_data/arrow_{}.glif".format(make_arrow_glyph.MAXLEN))
    else:
        arrow_glyphs.append( make_arrow_glyph.run(length-70) )

# Then we need to call MFEKstroke
output_arrows = list()
for i, arrow in enumerate(arrow_glyphs):
    out = subprocess.run(["MFEKstroke", "PAP", "-m", "single", "--pattern", arrow, "--path", split_glifs[i], "--out", split_glifs[i]+"_arrow", "--noffset={}".format(target_size), "--toffset=-5", "-s", "4", "--sx", "0.5", "--sy", "0.5"])
    output_arrows.append(split_glifs[i]+"_arrow")

# Then we need to join all the glif files
outfile = gliffn.split(os.sep)[-1]
outfile_cws = outfile[:outfile.rindex(".")]+"_cws.glif"
#outpath = "build" + os.sep + "arrow_glyphs" + os.sep + outfile
outpath = finalfn.replace("COLR", "arrow")
outpath_cws = tempfile.mkstemp()[1]

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

out = subprocess.run(["MFEKstroke", "CWS", "-i", outpath, "-w", "20", "-o", outpath_cws, "-s", "square", "-e", "patterns.ufo/glyphs/arrowhead.glif"])

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
[os.unlink(fn) for fn in arrow_glyphs if "build_data" not in fn]
[os.unlink(fn) for fn in output_arrows]
