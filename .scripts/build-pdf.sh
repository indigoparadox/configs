#!/bin/bash

# The following variables must be defined in the environment prior to use:
#
# - SCAN_DOC_DEV: SANE scanner device from which to scan PDFs.

usage() {
   echo "$0 [-i input-glob] [-o output-pdf] [-s] [-d duplex] [-c]"
   echo
   echo input-glob - A file or group of input image files to process.
   echo output-pdf - What to call the created PDF.
   echo -s - Select scanner as input.
   echo duplex - Can be Front, Back, or Duplex.
   echo -c - Enabled color scanning.
}

convert_pdf_ocr() {
   SCAN_IM_FORMAT="$1"
   shift
   PAGES_RESOLUTION="$1"
   shift
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
      if [ "png" = "$IMAGE_EXT" ] || \
         [ "pbm" = "$IMAGE_EXT" ] || \
         [ "tiff" = "$IMAGE_EXT" ]
      then
         # Convert and add the image to the image list.
         IMAGE_LIST="$IMAGE_LIST $PAGES_TEMP/$IMAGE_BASE.pdf"

         echo "deskewing $i..."
         SKEW_ANGLE="`${IMAGE_EXT}_findskew "$i" 2>/dev/null`"
         if [ -n "$SKEW_ANGLE" ]; then
            echo "skew angle is: $SKEW_ANGLE"
            SKEW_ANGLE="`echo -1*$SKEW_ANGLE | bc`"
            echo "deskew angle is: $SKEW_ANGLE"
            convert "$i" -rotate "$SKEW_ANGLE" \
               "$PAGES_TEMP/$IMAGE_BASE.$SCAN_IM_FORMAT"

         else
            # TODO: Just copy to intermediate dir.
            echo "deskewing failed for $IMAGE_BASE.$IMAGE_EXT"
            cp -v "$i" "$PAGES_TEMP/$IMAGE_BASE.$SCAN_IM_FORMAT"
         fi

         echo "detecting text for $i..."
         tesseract -l eng "$PAGES_TEMP/$IMAGE_BASE.$SCAN_IM_FORMAT" "$PAGES_TEMP/$IMAGE_BASE" pdf

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

function scan_input_doc() {
   SCAN_DUPLEX="$1"
   SCAN_RESOLUTION="$2"
   SCAN_MODE="$3"
   SCAN_FILENAME="$4"
   SCAN_IM_FORMAT="$5"

   if [ -z "$SCAN_DOC_DEV" ]; then
      echo "\$SCAN_DOC_DEV not set!"
      exit 1
   fi

   if ! /usr/bin/scanimage --batch="$SCAN_FILENAME" --format $SCAN_IM_FORMAT \
      -d "$SCAN_DOC_DEV" --source "ADF $SCAN_DUPLEX" \
      --resolution "$SCAN_RESOLUTION" --mode "$SCAN_MODE"
   then
      echo "could the scanner be off?"
      exit 1
   fi
}

PDF_OUTPUT=""
IMAGE_INPUT=""
SCAN_INPUT=0
SCAN_MODE="Lineart"
SCAN_DUPLEX="Front"
SCAN_RESOLUTION=300
SCAN_IM_FORMAT="tiff"
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

      -s)
         SCAN_INPUT=1
         ;;

      -d)
         shift
         SCAN_DUPLEX="$1"
         ;;

      -c)
         SCAN_MODE="Color"
         ;;

      *)
         echo "extraneous element: $1"
         echo "forgot to single-quote glob?"
         exit 1
   esac
   shift
done

if [ $SCAN_INPUT -eq 0 ] && [ -z "$IMAGE_INPUT" ]; then
   echo "no input images or scanner specified!"
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

if [ $SCAN_INPUT -eq 1 ]; then
   if [ -z "$SCAN_DOC_DEV" ]; then
      echo "\$SCAN_DOC_DEV not set!"
      exit 1
   fi

   SCAN_TEMP="`mktemp -d --suffix=.build-pdf`"
   IMAGE_INPUT="$SCAN_TEMP"'/*'".$SCAN_IM_FORMAT"
   scan_input_doc "$SCAN_DUPLEX" "$SCAN_RESOLUTION" "$SCAN_MODE" "$SCAN_TEMP/out%d.$SCAN_IM_FORMAT" "$SCAN_IM_FORMAT"
fi

convert_pdf_ocr "$SCAN_IM_FORMAT" "$SCAN_RESOLUTION" "$PDF_OUTPUT" "$IMAGE_INPUT"

if [ -n "$SCAN_TEMP" ] && [ -d "$SCAN_TEMP" ]; then
   rm -rvf "$SCAN_TEMP"
fi
