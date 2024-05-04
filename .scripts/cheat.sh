#!/bin/bash

if [ -z "$CHEAT_PATH" ]; then
   CHEAT_PATH="$HOME/.cheat"
fi

if [ -z "$1" ] || [ ! -f "$CHEAT_PATH/$1" ]; then
   echo "usage: $0 <program_name>"
   exit 1
fi

cat "$CHEAT_PATH/$1"

