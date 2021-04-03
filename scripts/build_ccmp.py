#!/usr/bin/env python3
import unicodedata
import fontforge

# Find glyphs in this range with at least one combining character, create characters for them with systematic uniXXXX names
CCMP_REPLACEMENTS = {"i": "dotlessi", "j": "dotlessj"}
def ccmp_placeholders(f):
    placeholders = dict()
    for i in range(0xc0, 0x17f+1):
        c = chr(i)
        decomp = [int(e, 16) for e in unicodedata.decomposition(c).split() if e != "<compat>"]
        if not any(["M" in unicodedata.category(chr(u)) for u in decomp]):
            continue
        try:
            decomp_glyphs = [f[f.findEncodingSlot(u)].glyphname for u in decomp]
        except TypeError as _:
            continue
        decomp_glyphs = [CCMP_REPLACEMENTS[gn] if gn in CCMP_REPLACEMENTS else gn for gn in decomp_glyphs]
        placeholders[i] = decomp_glyphs
    return placeholders

def create_and_build_placeholders(f):
    for i, L in ccmp_placeholders(f).items():
        f.createChar(i, "uni{:04X}".format(i))
        g = f[f.findEncodingSlot(i)]
        # This is a cursive font, so it's okay (even preferred) to draw ď as d + ◌̌
        g.width = 1000

if __name__ == "__main__":
    f = fontforge.open("FRBAmericanCursive.sfd")
    print("feature ccmp {")
    print("    lookup ccmp_placeholders {")
    for (i, vals) in ccmp_placeholders(f).items():
        print((" "*8)+"sub uni{:04X} by {};".format(i, " ".join(vals)))
    print("    } ccmp_placeholders;")
    print("} ccmp;")
    f.close()
