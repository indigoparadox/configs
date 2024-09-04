#!/bin/bash

if [ -z "$VMS_ROOT" ]; then
   zenity --error --text="VMS_ROOT is not defined!"
   exit 1
fi

VM_NAME="`zenity --list --column=Name \
   $(ls -1 "$VMS_ROOT")
   `"

if [ "" != "$VM_NAME" ]; then
   86Box.AppImage -P "$VMS_ROOT/$VM_NAME/"
fi

