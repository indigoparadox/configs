#!/bin/bash

usage() {
   echo "$0 <page extension> <output.pdf>"
   echo
   echo "page extension - Filename extension for pages (e.g. .png)"
}

OUTPUT="$2"
if [ -z "$OUTPUT" ]; then
   OUTPUT="output.pdf"
fi
if [ -f "$OUTPUT" ]; then
   echo "output file exists!"
   echo
   usage
   exit 1
fi

PAGE_EXT="$1"
if [ -z "$PAGE_EXT" ]; then
   usage
   exit 1
fi

# Perform OCR on pages.
IMAGE_LIST=""
for i in *$PAGE_EXT; do
   if [ "*$PAGE_EXT" = "$i" ]; then
      break
   fi
   IMAGE_BASE="`basename "$i" "$PAGE_EXT"`"
   IMAGE_LIST="$IMAGE_LIST $IMAGE_BASE.pdf"
   echo "processing $IMAGE_BASE..."
   tesseract -l eng "$i" "$IMAGE_BASE" pdf
done

echo "images processed: $IMAGE_LIST"

if [ -z "$IMAGE_LIST" ]; then
   echo "no images found!"
   exit 1
fi

# Unite pages into one.
pdfunite $IMAGE_LIST $OUTPUT

