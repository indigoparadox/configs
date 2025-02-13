#!/bin/bash

_ausplit_exec_ffmpeg_first() {
   echo ffmpeg -i "$1" -to "$2" -c copy "$3"
}

_ausplit_exec_ffmpeg_last() {
   echo ffmpeg -i "$1" -ss "$2" -c copy "$3"
}

_ausplit_exec_ffmpeg() {
   echo ffmpeg -i "$1" -ss "$2" -to "$3" -c copy "$4"
}

# Parse args.
_ausplit_gap="0.2"
while [ "$1" ]; do
   case "$1" in
      -g)
         shift
         _ausplit_gap="$1"
         ;;

      *)
         _ausplit_file="$1"
         ;;
   esac
   shift
done

if [ -z "$_ausplit_file" ]; then
   echo "usage: $0 [-g] <in_file>"
   exit 1
fi

# Get list of silences.
_ausplit_silences="`ffmpeg -i "$_ausplit_file" \
   -af silencedetect=d=$_ausplit_gap \
   -f null - |& awk '/silencedetect/ {print $4,$5}'`"

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

IFS=$'\n'
_ausplit_start=0
_ausplit_iter=0
_ausplit_ready=0
echo $_ausplit_silences
for s in $_ausplit_silences; do
   if echo $s | grep -q '^silence_start'; then
      if [ 0 -eq $_ausplit_iter ]; then 
         # The first iteration is a special case.
         _ausplit_start=0
      fi
      # A silence is starting, so a clip is ending.
      _ausplit_end="`echo $s | awk '{print $2}'`"

      # Parsing has pulled enough data to do a split!
      _ausplit_ready=1
   elif echo $s | grep -q '^silence_end'; then
      # A silence is ending, so a clip is starting.
      _ausplit_start="`echo $s | awk '{print $2}'`"
   fi


   if [ $_ausplit_ready -eq 1 ]; then
      #echo $_ausplit_start, $_ausplit_end

      if [ "0" == "$_ausplit_start" ]; then
         _ausplit_exec_ffmpeg_first \
            "$_ausplit_file" "$_ausplit_end" "output_$_ausplit_iter.mp3"
      else
         _ausplit_exec_ffmpeg \
            "$_ausplit_file" "$_ausplit_start" "$_ausplit_end" \
            "output_$_ausplit_iter.mp3"
      fi

      # Reset ready flag, go back to parsing.
      _ausplit_ready=0

      # Iterate clip.
      _ausplit_iter=$(($_ausplit_iter + 1))
   fi
done

# With the list out of the way, handle the last dangler.
_ausplit_exec_ffmpeg_last "$_ausplit_file" "$_ausplit_start" "output_$_ausplit_iter.mp3"

