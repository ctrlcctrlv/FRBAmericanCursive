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
        if "${UFO}" in line:
            print(line.replace("${UFO}", includename), file=f, end='')
        else:
            print(line, file=f, end='')
