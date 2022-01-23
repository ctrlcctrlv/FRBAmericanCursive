#!/bin/bash
if [[ $PRODUCTION =~ ^y(es)?$ ]]; then
    ARGS='--optimize-cff 2 --cff-round-tolerance 0.05 --subroutinizer cffsubr --keep-overlaps' # overlaps to be handled by afdko checkoutlinesufo
else
    ARGS='--optimize-cff 0 --cff-round-tolerance 0 --keep-overlaps'
fi
echo "$ARGS"
