#!/bin/bash

./scripts/stroke_count_fea.py < <(xidel --input-format xml ${FONTFAMILY}-SOURCE.ufo/glyphs/*.glif -e 'string-join((/glyph/@name, '$'"\t"'', count(//point[1])))' --silent)

cat << EOF

feature ss01 {
  featureNames {
    name "Enable stroke order numbers";
  };
  lookup combstroke;
} ss01;

feature ss02 {
  featureNames {
    name "Disable stroke numbers, even if enabled due to OPSZ";
  };
  # sub __combstroke0 by NULL;
  sub __combstroke1 by NULL;
  sub __combstroke2 by NULL;
  sub __combstroke3 by NULL;
  sub __combstroke4 by NULL;
  sub __combstroke5 by NULL;
  sub __combstroke6 by NULL;
  sub __combstroke7 by NULL;
  sub __combstroke8 by NULL;
  # sub __combstroke9 by NULL;
} ss02;
# 
# conditionset big {
#   opsz 48 48;
# } big;
# 
# variation rvrn big {
#   lookup combstroke;
# } rvrn;
EOF
