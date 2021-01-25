#!/bin/bash

SVG=$1
SVG_base=${SVG%%.svg}

IDs=`xq -r '.svg.g[]."@id"' < "$1"`

for ID in $IDs; do
	>&2 echo $ID …;
	xq --xml-output 'del(.svg.g[]|select(."@id"!="'"$ID"'"))' < "$1" > "$SVG_base"_"$ID".svg
done
