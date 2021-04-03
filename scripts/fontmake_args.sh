#!/bin/bash
if [[ $PRODUCTION =~ "y" ]]; then
	ARGS='--keep-overlaps --optimize-cff 0 --cff-round-tolerance 0'
else
	ARGS='--optimize-cff 0 --cff-round-tolerance 0'
	# --overlaps-backend pathops'
fi
echo "$ARGS"
