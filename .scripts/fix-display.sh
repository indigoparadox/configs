#!/bin/bash

# TODO: Currently this is correct for Zardoz. Make it smarter.

if DISPLAY=:0 xrandr | grep -q "^DP-1 connected"; then
   DISPLAY=:0 xrandr --output eDP-1 --off
fi

