#!/usr/bin/env python3
import plistlib
import sys

import re

from os2weight_to_namedweight import os2weight_to_namedweight

def split_at_cap(namedweight):
    namedweight = re.sub(r"([A-Z])", " \\1", namedweight)
    namedweight = re.sub(r"\s+", r" ", namedweight)
    return namedweight.strip()

(_, outname, familyname, familyname_h, namedweight, os2weight) = sys.argv

realweight = os2weight_to_namedweight(os2weight)

namedweight_h = split_at_cap(namedweight)

print("Fudging: {} {} {}".format(outname, namedweight, os2weight, realweight))
os2weight = int(os2weight)

plistf = open(outname+"/fontinfo.plist", "rb")
plist = plistlib.load(plistf)

plist["postscriptWeightName"] = namedweight
plist["openTypeOS2WeightClass"] = os2weight
plist["styleMapStyleName"] = "Bold Italic" if os2weight >= 700 else "Italic"
smname = " "+namedweight_h.replace(realweight+" ", "").replace(realweight, "") if os2weight == 400 or os2weight == 700 else " "+namedweight_h
smname = smname.strip()
plist["styleMapFamilyName"] = "{}{}".format(familyname_h, smname)
plist["familyName"] = "{}{}".format(familyname_h, smname)
plist["styleName"] = namedweight_h
plist["postscriptFontName"] = familyname + "-" + namedweight
plist["postscriptFullName"] = familyname_h + " " + namedweight_h
plist["postscriptWeightName"] = realweight
plist["openTypeNamePreferredFamilyName"] = familyname_h
plist["openTypeNamePreferredSubfamilyName"] = namedweight_h

plistf.close()
plistf = open(outname+"/fontinfo.plist", "wb+")
plistlib.dump(plist, plistf)
plistf.close()
