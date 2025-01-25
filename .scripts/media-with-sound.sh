#!/bin/bash

_find_sound_dir="$1"

if [ -z "$_find_sound_dir" ]; then
   echo "usage: $0 <media_dir>"
fi

for f in "$_find_sound_dir"/*.mp4; do
   _find_sound_res="`mediainfo "$f" | grep ^Audio`"

   if [ "Audio" = "$_find_sound_res" ]; then
      echo "`basename "$f"`"
   fi
done

