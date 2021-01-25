import xml.etree.ElementTree as ET
import sys
tree = ET.parse(sys.argv[1])
root = tree.getroot()

for g in root.iter():
    if not 'style' in g.attrib: continue
    if 'stroke:none' in g.attrib['style']:
        g.clear()
    elif 'stroke-width:1' in g.attrib['style']:
        g.attrib['style'] = 'stroke:none'

ET.dump(root)
