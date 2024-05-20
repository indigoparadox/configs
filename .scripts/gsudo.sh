#!/bin/bash

pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $@

$PKEXEC_RETVAL=$?

if [ $PKEXEC_RETVAL -ne 0 ]; then
   zenity --error --text="RetVal was: $PKEXEC_RETVAL"
fi

