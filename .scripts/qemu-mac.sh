#!/bin/bash

MAC_MEM=1024
# By default, we split boot and c because the ISO is quoted and qemu will get
# weird about an empty quoted arg and refuse to run.
MAC_CD="-boot"
MAC_CD_ISO="c"
while [ "$1" ]; do
   case "$1" in
      -m)
         shift
         MAC_MEM="$1"
         ;;

      -c)
         shift
         MAC_HDA="$1"
         ;;

      -d)
         shift
         # Keep ISO separate so we can quote it later.
         MAC_CD_ISO="$1"
         MAC_CD="-boot d -cdrom"
         ;;
   esac
   shift
done

if [ -z "$MAC_HDA" ]; then
   echo "no HD specified!"
   echo "usage: $0 [-m memory] <-c hard-disk> [-d cd-rom]"
   exit 1
fi

qemu-system-ppc \
   -L openbios-ppc \
   -M mac99,via=pmu \
   -cpu G4 \
   -m 1024 \
   -prom-env 'auto-boot?=true' \
   -prom-env 'vga-ndrv?=true' \
   -hda "$MAC_HDA" \
   -g 1024x768x32 \
   -netdev user,id=mynet0 \
   -rtc base=localtime \
   -device sungem,netdev=mynet0 \
   $MAC_CD "$MAC_CD_ISO"

