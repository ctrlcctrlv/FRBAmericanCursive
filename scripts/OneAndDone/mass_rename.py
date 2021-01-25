import fontforge as ff

f=fontforge.activeFont()

for i in range(321,321+32):
  j=f.findEncodingSlot(0x410+(i-321))
  f[i].glyphname = f[j].glyphname+".rlow"