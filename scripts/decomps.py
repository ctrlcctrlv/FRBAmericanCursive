import fontforge
import unicodedata

font = fontforge.open("FRBAmericanCursive.sfd")

for i in range(0xc0, 0x17f+1):
    c = chr(i)
    decomp = [int(e, 16) for e in unicodedata.decomposition(c).split() if e != "<compat>"]
    if not any(["M" in unicodedata.category(chr(u)) for u in decomp]):
        continue
    try:
        decomp_glyphs = [font[font.findEncodingSlot(u)].glyphname for u in decomp]
    except TypeError as _:
        continue
    print("{} (uni{:04X})".format(c, ord(c)), decomp_glyphs)
