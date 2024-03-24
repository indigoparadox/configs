#!/bin/bash

LAST_START=""
LAST_END=""

#ffmpeg -framerate 25 -pattern_type glob -i '$1/*.jpg' -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p output.mp4
#ffprobe -f lavfi -i movie=output.mp4,blackdetect[out0] -show_entries tags=lavfi.black_start,lavfi.black_end -of default=nw=1 -v quiet

V_INCR=0
V_CONCAT=""
IFS=$'\n'
for line in `cat frames.txt | uniq`; do
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
      TRIMS_OUT="$TRIMS_OUT[0:v]trim=start=$LAST_START:end=$LAST_END,setpts=PTS-STARTPTS[v$V_INCR]"

      if [ 0 -lt $V_INCR ] && [ 0 -ne $(($V_INCR % 2))  ]; then
         V_INCR=$(($V_INCR + 1))
         V_CONCAT="$V_CONCAT;[v$(($V_INCR - 2))][v$(($V_INCR - 1))]concat[v$(($V_INCR))]"
      fi
      V_INCR=$(($V_INCR + 1))

      unset LAST_START
      unset LAST_END
   fi
done

ffmpeg -i output.mp4 -filter_complex $TRIMS_OUT$V_CONCAT -map [v$(($V_INCR - 1))] out2.mp4

