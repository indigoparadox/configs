#!/bin/bash

# Rename MP3s based on their MP3 title tag.

_mp3_in="$1"

if [ -z "$_mp3_in" ] || [ ! -f "$_mp3_in" ]; then
   echo "usage: $0 <mp3 file>"
   exit 1
fi

_mp3_title="`ffprobe \
   -loglevel error -show_entries stream_tags:format_tags -of json "$f" | \
   jq .format.tags.title | \
   tr -d '/' | \
   tr -d '"'`"

if [ -z "$_mp3_title" ] || [ "null" = "$_mp3_title" ]; then
   echo "invalid MP3 title!"
   exit 2
fi

mv -v "$_mp3_in" "$_mp3_title.mp3"

