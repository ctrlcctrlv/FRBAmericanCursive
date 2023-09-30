# This is a non-standard OpenType table meant to tell rasterizers how to rasterize.

from fontTools.misc import sstruct
from fontTools.ttLib.tables import DefaultTable

XOLR_FORMAT = """
    > # big endian
    version:     L
    flags:       L
"""

class table_X_O_L_R_(DefaultTable.DefaultTable):
    def __init__(self, flags=0):
        DefaultTable.DefaultTable.__init__(self, None)
        self.data = {"flags":flags}

    def compile(self, *args, **kwargs):
        headerSize = sstruct.calcsize(XOLR_FORMAT)
        dataOffset = headerSize + sstruct.calcsize(XOLR_FORMAT)
        header = sstruct.pack(XOLR_FORMAT, {
                "version": 0,
                "flags": self.data["flags"],
        })
        return header

    def decompile(self, data, *args, **kwargs):
        headerSize = sstruct.calcsize(XOLR_FORMAT)
        header = sstruct.unpack(XOLR_FORMAT, data[0 : headerSize])
        if header["version"] != 0:
            raise TTLibError("unsupported 'XOLR' version %d" %
                             header["version"])
        self.data["flags"] = header["flags"]
