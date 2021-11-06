#!/usr/bin/env python3
import sys, os
from fontTools import ufoLib

def list_glyphs(f):
    return {k: v for k, v in sorted(f.getGlyphSet().getUnicodes().items(), key=lambda v: (v[1][0] if len(v[1]) > 0 else 0x10FFFF+1, v[0]))}

if __name__ == "__main__":
    f = ufoLib.UFOReader(sys.argv[1])
    if os.getenv('APPENDPYPATH'):
        sys.path.append(os.getenv('APPENDPYPATH'))
    assert len(sys.argv) == 2
    print('\n'.join(list_glyphs(f).keys()))
