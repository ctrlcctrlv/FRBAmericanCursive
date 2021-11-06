#!/usr/bin/env python3
import csv
import sys

(_, os2weight) = sys.argv

for row in csv.reader(open("build_data/monoline.tsv", "r"), delimiter="\t"):
    if row[2] == os2weight:
        print(row[0])
        sys.exit(0)

sys.exit(1)
