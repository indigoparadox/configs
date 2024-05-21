#!/bin/bash

OUT_ID="$1"
IN_ID="$2"

if [ -z "$HDMI_MATRIX_GF_URL" ]; then
   echo "HDMI_MATRIX_GF_URL is undefined!"
   exit 1
fi

if [ -z "$OUT_ID" ] || [ -z "$IN_ID" ]; then
   echo "usage: $0 <output_index> <input_index>"
   exit 1
fi

curl -X POST -o /dev/null -s -d "{CMD=OUT0$OUT_ID:0$IN_ID." \
   "$HDMI_MATRIX_GF_URL/cgi-bin/MMX32_Keyvalue.cgi"

