# This is needed by fontTools.ufoLib, which requires consumers define their own `Glyph` class.
class Glyph:
    name = ""
    width = -1
    height = -1
    unicodes = []
    note = ""
    lib = {}
    image = {}
    guidelines = {}
    anchors = []

    def __repr__(self):
        return "<Glyph {}: {}x{} @{}>".format(self.name, self.width, self.height, ",".join(["U+{:04X}".format(u) for u in self.unicodes]))
