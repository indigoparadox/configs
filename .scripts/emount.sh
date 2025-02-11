#!/bin/sh

EMOUNT_KEYRING="`which keyring`"

if [ -z "$EMOUNT_KEYRING" ]; then
   echo "please install python3-keyring!"
   exit 1
fi

EMOUNT_ENCFS="`which encfs`"

if [ -z "$EMOUNT_ENCFS" ]; then
   echo "please install encfs!"
   exit 1
fi
  
DO_UMOUNT=0
while [ "$1" ]; do
   case "$1" in
      -u)
         DO_UMOUNT=1
         ;;

      *)
         DIR_NAME=$1
         ;;
   esac
   shift
done

# Strip trailing slash.
DIR_NAME="`echo "$DIR_NAME" | tr -d '/'`"

if [ -z "$DIR_NAME" ]; then
   echo "usage: $0 [-u] <emount>"
   exit 1
fi

# Figure out if the source directory is an exception.
SRC_DIR_NAME="$EMOUNT_ROOT/$DIR_NAME"
for kv in `cat $HOME/.emountrc`; do
   if [ "`echo $kv | sed 's/:.*$//g'`" = "$DIR_NAME" ]; then
      SRC_DIR_NAME="`echo $kv | sed 's/^[^:]*://g'`"
   fi
done

# Figure out if we have a password.
if [ -z "`keyring get encfs $DIR_NAME`" ]; then
   keyring set encfs $DIR_NAME
fi

# Perform the mount/unmount.
if [ $DO_UMOUNT -eq 0 ]; then
   encfs --extpass="keyring get encfs $DIR_NAME" \
      $SRC_DIR_NAME $HOME/$DIR_NAME
else
   fusermount -u "$HOME/$DIR_NAME"
fi

