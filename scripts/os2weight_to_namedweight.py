#!/usr/bin/env python3
import csv
import sys
import pathlib

def os2weight_to_namedweight(os2weight):
    for row in csv.reader(open(pathlib.Path(__file__).parents[1] / "build_data" / "monoline.tsv", "r"), delimiter="\t"):
        if row[2] == str(os2weight):
            return row[0]
    return None

if __name__ == "__main__":
    (_, os2weight) = sys.argv
    ret = os2weight_to_namedweight(os2weight)
    if ret is None:
        sys.exit(1)
    else:
        print(ret)
