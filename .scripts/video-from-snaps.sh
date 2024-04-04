#!/bin/bash

VIDEO_SNAPS="$1"
VIDEO_OUT="$2"

if [ -z "$VIDEO_SNAPS" ] || [ -z "$VIDEO_OUT" ]; then
   echo "usage: $0 <snapshot directory> <output video>"
   exit 1
fi

function video_trim_black () {
   TRIM_INPUT="$1"
   TRIM_OUTPUT="$2"

   V_INCR=0
   V_CONCAT=""
   IFS=$'\n'
   # Fake an end at the start to avoid complicating things with "duration."
   for line in `ffprobe -f lavfi -i "movie=$TRIM_INPUT,blackdetect[out0]" -show_entries tags=lavfi.black_start,lavfi.black_end -of default=nw=1 -v quiet | (echo "TAG:lavfi.black_end=0" && cat) | uniq`; do
      LINE_START=`echo "$line" | sed -n 's/TAG.*start=\([0-9.]*\)/\1/p'`
      LINE_END=`echo "$line" | sed -n 's/TAG.*end=\([0-9.]*\)/\1/p'`

      if [ -n "$LINE_START" ]; then
         LAST_START="$LINE_START"
      elif [ -n "$LINE_END" ]; then
         LAST_END="$LINE_END"
      fi

      if [ -n "$LAST_START" ] && [ -n "$LAST_END" ]; then
         if [ -n "$TRIMS_OUT" ]; then
            TRIMS_OUT="$TRIMS_OUT;"
         fi
         TRIMS_OUT="$TRIMS_OUT[0:v]trim=start=$LAST_END:end=$LAST_START,setpts=PTS-STARTPTS[v$V_INCR]"

         if [ 0 -lt $V_INCR ] && [ 0 -ne $(($V_INCR % 2))  ]; then
            V_INCR=$(($V_INCR + 1))
            V_CONCAT="$V_CONCAT;[v$(($V_INCR - 2))][v$(($V_INCR - 1))]concat[v$(($V_INCR))]"
         fi
         V_INCR=$(($V_INCR + 1))

         unset LAST_START
         unset LAST_END
      fi
   done

   ffmpeg -i "$TRIM_INPUT" -filter_complex $TRIMS_OUT$V_CONCAT -map [v$(($V_INCR - 1))] "$TRIM_OUTPUT"
}

ffmpeg -framerate 25 -pattern_type glob -i "$VIDEO_SNAPS"'/*.jpg' -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p "$VIDEO_OUT"

video_trim_black "$VIDEO_OUT" "`basename "$VIDEO_OUT" .mp4`_trim.mp4"

