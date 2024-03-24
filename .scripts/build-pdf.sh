#!/bin/bash

usage() {
   echo "$0 [-i input-glob] [-o output-pdf]"
   echo
   echo input-glob - A file or group of input image files to process.
   echo output-pdf - What to call the created PDF.
}

convert_pdf_ocr() {
   PDF_OUT="$1"
   shift
   PAGES_GLOB="$@"
   echo $PAGES_GLOB
   PAGES_TEMP="`mktemp -d --suffix=.build-pdf`"
   
   # Verify temp directory.
   if [ -z "$PAGES_TEMP" ]; then
      echo "invalid temp dir!"
      exit 1
   fi

   # Perform OCR on pages.
   IMAGE_LIST=""
   for i in $PAGES_GLOB; do
      IMAGE_BASE="`basename "$i" | sed 's/\.[^.]*$//'`"
      IMAGE_EXT="`basename "$i" | sed 's/.*\.\([^.]*\)/\1/'`"
      echo "processing $IMAGE_BASE..."
      if [ "png" = "$IMAGE_EXT" ]; then
         # Convert and add the image to the image list.
         IMAGE_LIST="$IMAGE_LIST $PAGES_TEMP/$IMAGE_BASE.pdf"
         tesseract -l eng "$i" "$PAGES_TEMP/$IMAGE_BASE" pdf

      elif [ "pdf" = "$IMAGE_EXT" ]; then
         # Directly add the input PDF to the image list for appending.
         IMAGE_LIST="$IMAGE_LIST $i"

      fi
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

      *)
         echo "extraneous element: $1"
         echo "forgot to single-quote glob?"
         exit 1
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

convert_pdf_ocr "$PDF_OUTPUT" "$IMAGE_INPUT"

