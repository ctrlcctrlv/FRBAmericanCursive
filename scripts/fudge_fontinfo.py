#!/usr/bin/env python3
import plistlib
import sys

import re

def split_at_cap(namedweight):
    namedweight = re.sub(r"([A-Z])", " \\1", namedweight)
    namedweight = re.sub(r"\s+", r" ", namedweight)
    return namedweight.strip()

if len(sys.argv) == 4:
    (_, outname, namedweight, os2weight) = sys.argv
    namedweight2 = None
elif len(sys.argv) == 5:
    (_, outname, namedweight, os2weight, namedweight2) = sys.argv
    namedweight2 = split_at_cap(namedweight2)

namedweight = split_at_cap(namedweight)

print("Fudging: {} {} {}".format(outname, namedweight, os2weight, namedweight2))
os2weight = int(os2weight)

plistf = open(outname+"/fontinfo.plist", "rb")
plist = plistlib.load(plistf)

if "Regular" not in namedweight and "Bold" not in namedweight:
    plist["postscriptWeightName"] = namedweight
    plist["openTypeOS2WeightClass"] = os2weight
    plist["styleMapStyleName"] = "bold italic" if os2weight == 700 else "italic"
    plist["styleMapFamilyName"] = "{} {}".format(plist["styleMapFamilyName"], namedweight)
    plist["familyName"] = "{} {}".format(plist["familyName"], namedweight)
    plist["styleName"] = "Bold" if os2weight == 700 else "Regular"
else:
    _namedweight = namedweight.replace("Regular", "").replace("Bold", "").rstrip()
    plist["postscriptWeightName"] = _namedweight
    plist["openTypeOS2WeightClass"] = os2weight
    plist["styleMapStyleName"] = "bold italic" if os2weight == 700 else "italic"
    plist["styleMapFamilyName"] = "{} {}".format(plist["styleMapFamilyName"], _namedweight).rstrip()
    plist["familyName"] = "{} {}".format(plist["familyName"], _namedweight).rstrip()
    plist["styleName"] = "Bold" if os2weight == 700 else "Regular"

if namedweight2 is not None:
    plist["postscriptFontName"] = plist["postscriptFontName"].replace("-", "-"+namedweight+namedweight2).replace(" ", "")
    plist["postscriptFullName"] = "{} {} {}".format(plist["postscriptFullName"], namedweight, namedweight2)
else:
    plist["postscriptFontName"] = plist["postscriptFontName"].replace("Regular", namedweight).replace(" ", "")
    plist["postscriptFullName"] = "{} {}".format(plist["postscriptFullName"], namedweight)

plistf.close()
plistf = open(outname+"/fontinfo.plist", "wb+")
plistlib.dump(plist, plistf)
plistf.close()
