#!/bin/bash

CONFIGSYNC_DIR="`dirname "$0"`"
CONFIGSYNC_DIR="`cd "$CONFIGSYNC_DIR"`"
CONFIGSYNC_DIR="`pwd -P`"
CONFIGSYNC_EXCLUDE="setup.sh .config .stfolder .stignore .git .scripts .gitignore . .."
CONFIGSYNC_REMOVE_DEAD=".tmux.conf .aliases"

# Strip out letters and dots to produce 28, 29, 30, etc.
TMUX_VERSION="`tmux -V 2>/dev/null | sed -e 's/[^0-9]//g'`"

# TODO: Setup systemd services.

# Remove specified dead links.
for i in $CONFIGSYNC_REMOVE_DEAD; do
   CONFIGSYNC_HOME_TARGET="$HOME/$i"
   if [ "$HOME/$i" = "$CONFIGSYNC_HOME_TARGET" ] && \
   [ -L "$CONFIGSYNC_HOME_TARGET" ] && \
   [ ! -e "$CONFIGSYNC_HOME_TARGET" ]; then
      echo "Dead link: $i"
      rm -v "$HOME/$i"
   fi
done

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

   # Special case override: versioned tmux config.
   if [ "$CONFIGSYNC_DIR/.tmux-28.conf" = "$i" ]; then
      if [ -z "$TMUX_VERSION" ] || [ $TMUX_VERSION -gt 28 ]; then
         continue
      fi
      CONFIGSYNC_HOME_TARGET="$HOME/.tmux.conf"

   elif [ "$CONFIGSYNC_DIR/.tmux-29.conf" = "$i" ]; then
      if [ -z "$TMUX_VERSION" ] || [ $TMUX_VERSION -lt 29 ]; then
         continue
      fi
      CONFIGSYNC_HOME_TARGET="$HOME/.tmux.conf"
   fi

   # Skip git repo.
   if [ "x$i" = "x$CONFIGSYNC_DIR/.git" ]; then
      echo "Skipping git repo."
      continue
   fi

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

