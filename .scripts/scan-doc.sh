#!/bin/bash

if [ -n "$1" ]; then
   DUPLEX_MODE="$1"
else
   DUPLEX_MODE="Front"
fi

if [ -z "$SCAN_DOC_DEV" ]; then
   echo "\$SCAN_DOC_DEV not set!"
   exit 1
fi

/usr/bin/scanimage -b --format png -d "$SCAN_DOC_DEV" \
   --source "ADF $DUPLEX_MODE" --resolution 300 --mode Lineart

