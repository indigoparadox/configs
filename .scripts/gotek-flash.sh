#!/bin/sh

DFU_FILE="$1"

if [ -z "$DFU_FILE" ]; then
   echo "usage: $0 <dfu file>"
   echo
   echo "Flash the given DFU file to attached Gotek board."
   echo "The Gotek must be in flash mode (boot jumper wire installed)."
   echo "This may have to be run several times until it is successful."
   exit 1
fi

echo Unprotecting...

# First, run the unprotect command (needs -D, even tho it doesn't use the file).
# This will probably generate an error, but it's fine.
sudo dfu-util -s :unprotect:force -D $DFU_FILE -a 0

echo Flashing...

# Perform the actual flash.
sudo dfu-util -D $DFU_FILE -a 0
