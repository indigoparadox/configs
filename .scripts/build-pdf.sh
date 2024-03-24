#!/bin/bash

usage() {
   echo "$0 [-i input-glob] [-o output-pdf]"
   echo
   echo input-glob - A file or group of input image files to process.
   echo output-pdf - What to call the created PDF.
}

convert_png() {
   PNG_IN="$1"
   PDF_OUT="$2"
   gs -dSAFER -r600 -sDEVICE=pngalpha -o "$PNG_IN" "$PDF_OUT"
}

convert_pdf_ocr() {
   PAGES_GLOB="$1"
   PAGES_TEMP="`mktemp -d --suffix=.build-pdf`"
   PDF_OUT="$2"
   
   # Verify temp directory.
   if [ -z "$PAGES_TEMP" ]; then
      echo "invalid temp dir!"
      exit 1
   fi

   # Perform OCR on pages.
   IMAGE_LIST=""
   for i in $PAGES_GLOB; do
      IMAGE_BASE="`basename "$i" | sed 's/\.[^.]*$//'`"
      IMAGE_LIST="$IMAGE_LIST $PAGES_TEMP/$IMAGE_BASE.pdf"
      echo "processing $IMAGE_BASE..."
      tesseract -l eng "$i" "$PAGES_TEMP/$IMAGE_BASE" pdf
   done

   if [ -z "$IMAGE_LIST" ]; then
      echo "no images produced!"
      exit 1
   fi

   echo "images processed: $IMAGE_LIST"

   # Create output PDF.
   pdfunite $IMAGE_LIST $PDF_OUT && rm $IMAGE_LIST

   # Cleanup.
   rm -rfv "$PAGES_TEMP"
}

PDF_OUTPUT=""
IMAGE_INPUT=""
while [ "$1" ]; do
   case "$1" in
      -i)
         shift
         IMAGE_INPUT="$1"
         ;;

      -o)
         shift
         PDF_OUTPUT="$1"
         ;;
   esac
   shift
done

if [ -z "$IMAGE_INPUT" ]; then
   echo "no input images specified!"
   echo
   usage
   exit 1
fi

if [ -z "$PDF_OUTPUT" ]; then
   PDF_OUTPUT="output.pdf"
   echo "no output file specified; using $PDF_OUTPUT"
fi

if [ -f "$PDF_OUTPUT" ]; then
   echo "output file exists!"
   echo
   usage
   exit 1
fi

convert_pdf_ocr "$IMAGE_INPUT" "$PDF_OUTPUT"

