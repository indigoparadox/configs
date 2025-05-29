#!/bin/bash

_exthd_name=ext_hd
_exthd_action=0

function _exthd_cso() {
   echo "opening ${_exthd_name}..."
   sudo cryptsetup luksOpen "`cat "$HOME/.${_exthd_name}_uuid"`" --key-file /etc/${_exthd_name}.key ${_exthd_name}_crypt
}

function _exthd_csc() {
   echo "closing ${_exthd_name}..."
   sudo cryptsetup luksClose ${_exthd_name}_crypt
}

function _exthd_mo() {
   echo "mounting ${_exthd_name}..."
   mount /mnt/${_exthd_name}/
}

function _exthd_um() {
   echo "unmounting ${_exthd_name}..."
   sudo umount /mnt/${_exthd_name}/
}

function _exthd_usage() {
   echo "usage: $0 [-n ext_hd_name] [-o|-c|-m|-u]"
   echo
   echo "-o - open ext_hd"
   echo "-c - close ext_hd"
   echo "-m - mount ext_hd"
   echo "-u - unmount ext_hd"
}

while [ "$1" ]; do
   case "$1" in
      -o)
         _exthd_action=1
         _exthd_cso
         ;;

      -c)
         _exthd_action=1
         _exthd_csc
         ;;

      -m)
         _exthd_action=1
         _exthd_mo
         ;;

      -u)
         _exthd_action=1
         _exthd_um
         ;;

      -n)
         shift
         _exthd_name=$1
         ;;

      *)
         _exthd_usage
         exit 1
   esac
   shift
done

if [ $_exthd_action -eq 0 ]; then
   _exthd_usage
fi

