#!/bin/bash
if [ -z $1 ]; then
	WEIGHT=Regular
else
	WEIGHT=$1
fi

if [ -z $PRODUCTION ]; then
	ARGS='--keep-overlaps --optimize-cff 1 --cff-round-tolerance 0'
else
	ARGS='--optimize-cff 1 --cff-round-tolerance 0'
fi

fontmake --verbose DEBUG -u build/FRBAmericanCursive-"$1".ufo --output-path dist/FRBAmericanCursive-"$2"-"$1".otf -o otf $ARGS
