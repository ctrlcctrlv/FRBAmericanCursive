#!/usr/bin/env python3
import itertools
import unicodedata
from fontTools import ufoLib
import sys, shutil

# Find glyphs in this range with at least one combining character, create characters for them with systematic uniXXXX names
CCMP_REPLACEMENTS = {"i": "dotlessi", "j": "dotlessj"}
KNOWN_GOOD = """ÁáÀàẢảÃãẠạĂăẮắẰằẲẳẴẵẶặÂâẤấẦầẨẩẪẫẬậĐđÉéÈèẺẻẼẽẸẹÊêẾếỀềỂểỄễỆệÍíÌìỈỉĨĩỊịÓóÒòỎỏÕõỌọÔôỐốỒồỔổỖỗỘộƠơỚớỜờỞởỠỡỢợÚúÙùỦủŨũỤụƯưỨứỪừỬửỮữỰựÝýỲỳỶỷỸỹỴỵ"""
def ccmp_placeholders(f):
    placeholders = dict()
    for i in set( [ord(c) for c in KNOWN_GOOD] + list(range(0xc0, 0x17f+1))+list(range(0x1a0, 0x1b0+1)) ):
        c = chr(i)
        decomp = [int(e, 16) for e in unicodedata.decomposition(c).split() if e != "<compat>"]
        inner_d = [[int(e, 16) for e in unicodedata.decomposition(chr(d)).split()] for d in decomp]
        decomp2 = list(itertools.chain(*[e if len(e) > 0 else [decomp[i]] for i, e in enumerate(inner_d)]))
        #decomp2 = [int(e, 16) for e in list(itertools.chain(*[unicodedata.decomposition(chr(d)).split() for d in decomp])) if e != "<compat>"]
        if any(["M" in unicodedata.category(chr(u)) for u in decomp2]):
            decomp = decomp2
        elif not any(["M" in unicodedata.category(chr(u)) for u in decomp]):
            continue
        try:
            cm = f.getCharacterMapping()
            decomp_glyphs = [cm[u][0] for u in decomp]
        except:
            continue
        decomp_glyphs = [CCMP_REPLACEMENTS[gn] if (gn in CCMP_REPLACEMENTS and not "underdotcomb" in decomp_glyphs) else gn for gn in decomp_glyphs]
        placeholders[i] = decomp_glyphs
    return placeholders

def create_and_build_placeholders(f):
    gs = f.getGlyphSet()
    Glyph = gs.glyphClass
    placeholders = ccmp_placeholders(f)
    for i, L in placeholders.items():
        g = Glyph(glyphName="uni{:04X}".format(i), glyphSet=gs)
        g.width = 1000
        g.unicodes = [i]
        gs.writeGlyph("uni{:04X}".format(i), g)
    gs.writeContents()
    return placeholders

if __name__ == "__main__":
    _, ufodir, outdir = sys.argv

    if ufodir != outdir:
        try:
            shutil.rmtree(outdir)
        except OSError: pass

    shutil.copytree(ufodir, outdir)
    ufo = ufoLib.UFOReaderWriter(outdir)
    placeholders = create_and_build_placeholders(ufo)
    print("feature ccmp {")
    print("    lookup ccmp_placeholders {")
    print("        lookupflag 0;")
    for (i, vals) in placeholders.items():
        print((" "*8)+"sub uni{:04X} by {};".format(i, " ".join(vals)))
    print("    } ccmp_placeholders;")
    print("} ccmp;")
