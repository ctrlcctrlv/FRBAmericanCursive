#!/usr/bin/env python3
import sys

(_, remove) = sys.argv

COLR_types = ["arrows", "baseline", "beginnings", "endings", "guidelines", "xheight"]
COLR_types = filter(lambda s: s != remove, COLR_types)
COLR_types = list(COLR_types)

print(",".join(COLR_types), end='')
