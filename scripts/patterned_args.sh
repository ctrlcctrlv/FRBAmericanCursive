#!/bin/bash

if [[ "$FONTFAMILY" =~ ^FRBAmericanCursive$ ]]; then
    echo '-c -W $CULLWIDTHADJ -a $CULLAREA -l'
elif [[ "$FONTFAMILY" =~ ^FRBAmericanPrint$ ]]; then
    echo '-c -W $CULLWIDTHADJ -a $CULLAREA -l'
fi
