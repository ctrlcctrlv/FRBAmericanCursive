#!/usr/bin/env python3

import plistlib
import sys

_, *plists = sys.argv
assert len(plists) > 1

with open(plists[0], "rb") as f:
    first = plistlib.load(f)

for plist in plists[1:]:
    with open(plist, "rb") as f:
        first.update(plistlib.load(f))

print(plistlib.dumps(first).decode("utf-8"))
