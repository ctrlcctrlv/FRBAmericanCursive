#!/usr/bin/env python3
import plistlib
import sys

(_, outname, namedweight, os2weight) = sys.argv
os2weight = int(os2weight)

plistf = open(outname+"/fontinfo.plist", "rb")
plist = plistlib.load(plistf)
plist["postscriptWeightName"] = namedweight
plist["openTypeOS2WeightClass"] = os2weight
plist["styleName"] = namedweight
plist["styleMapStyleName"] = "bold italic" if os2weight >= 700 else "italic"
plist["postscriptFontName"] = plist["postscriptFontName"].replace("Regular", namedweight)
plistf.close()
plistf = open(outname+"/fontinfo.plist", "wb")
plistlib.dump(plist, plistf)
plistf.close()
