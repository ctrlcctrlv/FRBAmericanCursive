#!/usr/bin/env python3
import sys, os
if os.getenv('APPENDPYPATH'):
    sys.path.append(os.getenv('APPENDPYPATH'))
assert len(sys.argv) == 2
from fontTools import ufoLib
f = ufoLib.UFOReader(sys.argv[1])
print('\n'.join(['{}'.format('\n'.join(c)) for _, c in f.getCharacterMapping().items()]))
