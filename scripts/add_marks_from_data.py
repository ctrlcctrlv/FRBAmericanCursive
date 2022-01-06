#!/usr/bin/env python3

from fontTools import ufoLib
from fontTools.ufoLib.glifLib import glyphNameToFileName
from lxml import etree
import csv
import sys

_, ufo, markclass = sys.argv

# Add anchors for all marks
inpf = open("build_data/{}_marks".format(markclass))
marks = inpf.read().strip().split()
for m in marks:
    glif_fn = ufo+"/glyphs/"+glyphNameToFileName(m, None)
    with open(glif_fn) as f:
        glif = f.read()
    tree = etree.fromstring(glif.encode("utf-8"))
    anchor = etree.Element("anchor")
    anchor.attrib["x"] = "0"
    anchor.attrib["y"] = "0"
    anchor.attrib["name"] = "_{}".format(markclass)
    tree.find("unicode").addnext(anchor)
    with open(glif_fn, "wb+") as f:
        f.write(etree.tostring(tree, pretty_print=True, encoding="utf-8", xml_declaration=True))

csvf = open("build_data/{}.tsv".format(markclass))
r = csv.reader(csvf, delimiter="\t")
for row in r:
    (glyph, x, y, class_) = row
    glif_fn = ufo+"/glyphs/"+glyphNameToFileName(glyph, None)
    with open(glif_fn) as f:
        glif = f.read()
    tree = etree.fromstring(glif.encode("utf-8"))
    anchor = etree.Element("anchor")
    anchor.attrib["x"] = x
    anchor.attrib["y"] = y
    anchor.attrib["name"] = markclass
    u = tree.find("advance").addnext(anchor)
    with open(glif_fn, "wb+") as f:
        f.write(etree.tostring(tree, pretty_print=True, encoding="utf-8", xml_declaration=True))
