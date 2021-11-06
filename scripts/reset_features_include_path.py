#!/usr/bin/env python3

import sys

if len(sys.argv) == 2:
    (_, outname) = sys.argv
    includename = outname
elif len(sys.argv) == 3:
    (_, outname, includename) = sys.argv
else:
    raise NotImplementedError

with open(outname+"/features.fea", "r") as f:
    lines = f.readlines()
with open(outname+"/features.fea", "w+") as f:
    for line in lines:
        if "#strokes_mark.fea" in line:
            print("include("+includename+"/strokes_mark.fea); #strokes_mark.fea", file=f)
        else:
            print(line, file=f)
