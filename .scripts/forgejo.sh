#!/bin/bash

_forgejo_action=""
_forgejo_target_name=""
while [ "$1" ]; do
   case "$1" in
      -d)
         if [ "$_forgejo_action" != "" ] && \
         [ "$_forgejo_action" != "debian-pkg" ]; then
            echo "incompatible actions specified!"
            exit 1
         fi
         _forgejo_action="debian-pkg"
         shift
         _forgejo_pkg_pool="$_forgejo_pkg_pool $1"
         ;;

      *)
         _forgejo_target_name="$1"
         ;;
   esac
   shift
done

if [ -z "$_forgejo_action" ] || [ -z "$_forgejo_target_name" ]; then
   echo "usage: $0 [-d pool-name] [target-file]"
   exit 1
fi

if [ -z "$FORGEJO_URL" ] || [ -z "$FORGEJO_USER" ]; then
   echo "missing \$FORGEJO_URL and/or \$FORGEJO_USER environment variables!"
   exit 1
fi

_forgejo_oauth="`keyring get "$FORGEJO_URL" packages`"
if [ -z "$_forgejo_oauth" ]; then
   echo "no oauth token for $FORGEJO_URL packages present in keyring!"
   exit 1
fi

if [ "debian-pkg" = "$_forgejo_action" ]; then
   if [ -z "$_forgejo_pkg_pool" ]; then
      echo "missing package pool!"
      exit 1
   fi
   for pool in $_forgejo_pkg_pool; do
      curl --user $FORGEJO_USER:$_forgejo_oauth \
         --upload-file $_forgejo_target_name \
         $FORGEJO_URL/api/packages/$FORGEJO_USER/debian/pool/$pool/main/upload
   done
fi

