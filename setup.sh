#!/bin/bash

CONFIGSYNC_DIR="`dirname "$0"`"
CONFIGSYNC_DIR="`cd "$CONFIGSYNC_DIR"`"
CONFIGSYNC_DIR="`pwd -P`"
CONFIGSYNC_EXCLUDE="setup.sh .stfolder .stignore . .."

for i in $CONFIGSYNC_DIR/* $CONFIGSYNC_DIR/.*; do
   # Skip excluded files.
   CONFIGSYNC_EXCLUDED=0
   for j in $CONFIGSYNC_EXCLUDE; do
      if [ "$CONFIGSYNC_DIR/$j" = "$i" ]; then
         CONFIGSYNC_EXCLUDED=1
      fi
   done
   if [ $CONFIGSYNC_EXCLUDED -eq 1 ]; then
      continue
   fi

   CONFIGSYNC_HOME_TARGET="$HOME/`basename "$i"`"

   # See if link already exists.
   if [ -L "$CONFIGSYNC_HOME_TARGET" ]; then
      echo "Link for $i already exists."
      continue
   fi

   # See if file or directory already exists.
   if [ -d "$CONFIGSYNC_HOME_TARGET" ] && [ -d "$i" ]; then
      echo "Directory $CONFIGSYNC_HOME_TARGET is blocking new link. Skipping"
      continue
   fi
   if [ -f "$CONFIGSYNC_HOME_TARGET" ] && [ -f "$i" ]; then
      echo "File $i is blocking new link. Skipping"
      continue
   fi

   ln -vs "$i" "$CONFIGSYNC_HOME_TARGET"
done

