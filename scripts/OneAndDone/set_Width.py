# Set width of all glyphs to their last point's X position. Good for a cursive.
import fontforge as ff

f = ff.activeFont()

for g in f.glyphs():
  lp = ff.point()
  for c in g.layers["Fore"]:
    for p in c:
      lp.x=p.x
  
  g.width=lp.x
