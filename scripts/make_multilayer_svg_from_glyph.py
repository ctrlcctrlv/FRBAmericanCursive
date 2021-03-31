#!/usr/bin/env python3
# (c) 2021 Fredrick R. Brennan, heavily based on dotty-svg.py by Simon Cozens, MIT licensed: https://gist.github.com/simoncozens/e06e945994153210afba1684c70b2744

from beziers.path import BezierPath
from beziers.cubicbezier import CubicBezier
from beziers.path.representations.fontparts import FontParts
from fontParts.world import OpenFont
from beziers.point import Point

import sys

dotradius   = 5
dotspacing  = 8
drawarrows  = True
arrowvector = Point(0,15)
fontpath    = "FRBAmericanCursive-SOURCE.ufo"
glyphname   = sys.argv[1]
height      = 650
vmargin     = 350

font = OpenFont(fontpath)
paths = FontParts.fromFontpartsGlyph(font[glyphname])
width = font[glyphname].width

print("""<?xml version="1.0" standalone="no"?>
<svg width="%dpx" height="%dpx" xmlns="http://www.w3.org/2000/svg" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape">
<defs>
    <marker id="arrowhead" viewBox="0 0 10 10" refX="3" refY="5"
        markerWidth="6" markerHeight="6" orient="auto">
      <path d="M 0 0 L 10 5 L 0 10 z" />
    </marker>
  </defs>""" % (width, height + vmargin))
def pt2svg(pt): return "%i %i " % (pt.x, height-pt.y)
def path2svg(segs):
  svgpath = "M " + pt2svg(segs[0].start)
  for j in range(0,len(segs)):
    if segs[j].order == 2:
      svgpath = svgpath + " L "
    elif  segs[j].order == 3:
      svgpath = svgpath + " Q "
    elif  segs[j].order == 4:
      svgpath = svgpath + " C "
    svgpath += ", ".join([ pt2svg(x) for x in segs[j][1:] ])
  # if paths[i].closed: # It isn't.
    # svgpath += "Z"
  return svgpath

def subdivide(path):
    return BezierPath.fromSegments([item for sl in [s.splitAtTime(0.5) for s in path.asSegments()] for item in sl])

print('<g inkscape:label="Guidelines" inkscape:groupmode="layer" id="guidelines">')
# origin
print('<path d="M 0 {h} L {} {h}" stroke="#00b2c2" stroke-width="5" fill="none"/>\n'.format(width, h=height))
# cap height
print('<path d="M 0 {h} L {} {h}" stroke="#00b2c2" stroke-width="5" fill="none"/>\n'.format(width, h=height-540))
# x-height
print('<path d="M 0 {h} L {} {h}" stroke="#00b2c2" stroke-width="5" stroke-dasharray="5,12" fill="none"/>\n'.format(width, h=height-264))
# descender
print('<path d="M 0 {h} L {} {h}" stroke="#00b2c2" stroke-width="5" fill="none"/>\n'.format(width, h=height+291))
print('</g>')

"""
print('<g inkscape:label="Arrows" inkscape:groupmode="layer" id="arrows">')
floating_single_point_idxs = []
for i in range(0,len(paths)):
  arrowP = paths[i].clone()
  arrowP = subdivide(subdivide(arrowP))
  arrowP = arrowP.offset(Point(15,15))
  #arrowP = arrowP.smooth()
  lens = [a.length for a in arrowP.asSegments()]

  nth_seg = 0
  nth_seg_len = 0
  nth_seg_remainder = 0
  sum_segs = 0

  for l in lens:
      sum_segs += l
      nth_seg += 1
      if sum_segs >= 150:
          old_len = sum_segs - l
          nth_seg_len = l
          A = 1-((sum_segs-150)/150)
          if A > 0 and A < 1:
              nth_seg_remainder = A
          else:
              nth_seg_remainder = 150/(sum_segs-150)
          break

  if sum_segs == 0: # contour has no points
      floating_single_point_idxs.append(i)
      continue
  segs = arrowP.asSegments()[:nth_seg]
  nth_segb = arrowP.asSegments()[nth_seg-1]
  nth_seg_left, _ = nth_segb.splitAtTime(nth_seg_remainder)
  segs[nth_seg-1] = nth_seg_left

  arrowSeg = (arrowP.asSegments())[0]
  s = arrowSeg.start

  print('<!--<text x="%s" y="%s" style="font-weight:bold">%i</text>-->' % (s.x+5.0,height-(s.y+5.0),1+i))
  print('<path d="%s" stroke="black" stroke-width="10" fill="none" marker-end="url(#arrowhead)"/>\n' % path2svg(segs))

print('</g>')

for idx in reversed(floating_single_point_idxs):
    paths.pop(idx)
"""

print('<g inkscape:label="Path" inkscape:groupmode="layer" id="path">')
for i in range(0,len(paths)):
  segs = paths[i].asSegments()
  print('<path d="%s" stroke="black" stroke-width="5" fill="none"/>\n' % path2svg(segs))
print('</g>')

print('<g inkscape:label="Beginnings" inkscape:groupmode="layer" id="beginnings">')
for i in range(0,len(paths)):
  s = paths[i].asSegments()[0]
  print('<circle cx="{}" cy="{}" r="{}" fill="red"/>'.format(s.start.x, height-s.start.y, dotradius))
print('</g>')

print('<g inkscape:label="Endings" inkscape:groupmode="layer" id="endings">')
for i in range(0,len(paths)):
  segs = paths[i].asSegments()
  lp = segs[-1]
  print('<circle cx="{}" cy="{}" r="{}" fill="blue"/>'.format(lp.end.x, height-lp.end.y, dotradius))
print('</g>')

print("</svg>\n")

