#!/usr/bin/env python3
'''
Create a lib.plist file in a given UFO, based on the information
in glyphs/contents.plist (alphabetical order).

(c) 2020 Frank Grießhammer (https://github.com/adobe-type-tools/afdko/issues/1130#issuecomment-623180851)
'''

import os
import argparse
import plistlib

parser = argparse.ArgumentParser(
    description=__doc__)

parser.add_argument(
    'ufos',
    action='store',
    nargs='+',
    metavar='UFO',
    help='input UFO(s)')

args = parser.parse_args()

for ufo_path in args.ufos:
    contents_path = os.path.join(ufo_path, 'glyphs', 'contents.plist')
    lib_path = os.path.join(ufo_path, 'lib.plist')
    with open(contents_path, 'rb') as pl_file:
        contents_dict = plistlib.load(pl_file)

    glyph_names = sorted(contents_dict.keys())
    lib_dict = {}
    lib_dict['public.glyphOrder'] = glyph_names
    with open(lib_path, 'wb') as pl_file:
        plistlib.dump(lib_dict, pl_file)
