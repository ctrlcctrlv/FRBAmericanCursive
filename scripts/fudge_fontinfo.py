#!/usr/bin/env python3
import plistlib
import os, sys

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
if os.environ["REGULAR_IS_ITALIC"].strip() == "1":
    plist["styleMapStyleName"] = "bold italic" if os2weight >= 700 else "italic"
elif os.environ["REGULAR_IS_ITALIC"].strip() == "0":
    plist["styleMapStyleName"] = "bold" if os2weight >= 700 else "regular"
else:
    raise ValueError("REGULAR_IS_ITALIC not 0/1")
smname = namedweight_h.replace(realweight+" ", "").replace(realweight, "") if os2weight == 400 or os2weight == 700 else namedweight_h
plist["styleMapFamilyName"] = "{} {}".format(familyname_h, smname).strip()
plist["familyName"] = "{} {}".format(familyname_h, smname).strip()
plist["styleName"] = namedweight_h
plist["postscriptFontName"] = familyname + "-" + namedweight
plist["postscriptFullName"] = familyname_h + " " + namedweight_h
plist["postscriptWeightName"] = realweight
plist["openTypeNamePreferredFamilyName"] = familyname_h.strip()
sfname = namedweight_h.replace(realweight, "") if os2weight == 400 else namedweight_h
if len(sfname.strip()) == 0:
    sfname = realweight
plist["openTypeNamePreferredSubfamilyName"] = sfname.strip()

plistf.close()
plistf = open(outname+"/fontinfo.plist", "wb+")
plistlib.dump(plist, plistf)
plistf.close()
