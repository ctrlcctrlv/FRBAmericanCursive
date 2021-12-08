#!/usr/bin/env python3
# This script is to be used because the Designspace XML format <rules/> element is incomplete and cannot express the full range of possibilities provided by GSUB.
# So, what we do is, we put the feature that we actually want to trigger when the OPSZ design axis is ≥ 48px into `ss01`. We then compile the font with the `ss01` and a fake FeatureVariations table that just changes `A` to `A.alt`.
# We then run this script to replace our fake lookup (only written to be replaced by us now with this script) with all the lookups triggered by ss01. Ta-da…

import sys
import fontTools.ttLib as tt

(_, otf) = sys.argv

f = tt.TTFont(otf)

lli = []
for e in f["GSUB"].table.FeatureList.FeatureRecord:
  if e.FeatureTag == "ss01":
    lli = e.Feature.LookupListIndex
f["GSUB"].table.FeatureVariations.FeatureVariationRecord[0].FeatureTableSubstitution.SubstitutionRecord[0].Feature.LookupListIndex = lli

f.save(otf)
