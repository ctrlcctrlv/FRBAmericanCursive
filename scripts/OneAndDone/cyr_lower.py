import fontforge as ff

f = ff.activeFont()

with open('cyr_lower.txt') as xf:
  cyrl = xf.read().splitlines()

for i in range(0x430, 0x44F+1):
  f.createChar(i, cyrl.pop(0))