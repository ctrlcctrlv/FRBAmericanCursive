#!/bin/bash
OUT=../FRBAC.tar.gz

rm "$OUT" || true
tar czvf "$OUT" -X 'tar -X' .
ls -alh "$OUT"
