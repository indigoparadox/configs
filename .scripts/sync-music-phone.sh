#!/bin/bash

if [ -z "$PHONE_MUSIC_DIR" ]; then
   echo "PHONE_MUSIC_DIR should be set to music dir on phone!"
   exit 1
fi

if [ -z "$NET_MUSIC_DIR" ]; then
   echo "NET_MUSIC_DIR should be set to music dir on network!"
   exit 1
fi

for m in "$PHONE_MUSIC_DIR"/*; do

   if [ -d "$m" ] || \
   echo "$m" | grep -q ".ini$" || \
   echo "$m" | grep -q ".sh$"
   then
      continue
   fi

   m_base="`basename "$m"`"
   m_album="`echo "$m_base" | sed 's/^{\([^}]*\)}.*/\1/g'`"
   if [ "$m_base" = "$m_album" ]; then
      m_net="$NET_MUSIC_DIR/$m_base"
   else
      m_net="$NET_MUSIC_DIR/$m_album/$m_base"
   fi

   if [ ! -f "$m_net" ]; then
      echo "missing: $m_net"
      continue
   fi

   # Compare files.

   m_hash="`cat "$m" | md5sum`"
   m_net_hash="`cat "$m_net" | md5sum`"

   if [ "$m_hash" != "$m_net_hash" ]; then
      echo "$m_base: $m_hash vs $m_net_hash"
      rm -v "$m"
      cp -v "$m_net" "$m"
   fi

done

