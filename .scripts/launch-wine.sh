#!/bin/bash

while [ "$1" ]; do
   case "$1" in
      -p)
         shift
         _wine_prefix="$1"
         ;;

      -a)
         shift
         _wine_arch="$1"
         ;;

      *)
         _wine_exe="$1"
         ;;

   esac
   shift
done

WINEPREFIX=$_wine_prefix WINEARCH=$_wine_arch wine $_wine_exe

