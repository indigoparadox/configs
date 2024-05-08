#!/bin/bash

MIRROR_URL=""
MIRROR_XARGS=""
while [ "$1" ]; do
   case "$1" in
      -x)
         MIRROR_XARGS="$WGET_XARGS -X $1"
         shift
         ;;

      *)
         MIRROR_URL="$1"
         ;;
   esac
   shift
done

wget --mirror --convert-links --html-extension --wait=1 \
   $MIRROR_XARGS $MIRROR_URL | tee mirror.log

