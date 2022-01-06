#!/usr/bin/env python3

import sys

from fontTools.ttLib.ttFont import TTFont

(_, otf) = sys.argv

font = TTFont(otf)

print(font["OS/2"].usWeightClass)
