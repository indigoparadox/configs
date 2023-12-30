#!/bin/bash

export vm="$1"

if [ -z "$vm" ]; then
   echo "usage: $0 <vm-name>"
   echo
   echo "Enable MPU-401 support for the given VM."
   exit 1
fi

# To enable the MPU-401 device
VBoxManage setextradata "$vm" VBoxInternal/Devices/mpu401/0/Trusted 1
# To enable the Adlib device
VBoxManage setextradata "$vm" VBoxInternal/Devices/adlib/0/Trusted 1
# To enable the EMU8000 device
VBoxManage setextradata "$vm" VBoxInternal/Devices/emu8000/0/Config/RomFile "$HOME/.pcem/roms/awe32.raw"

# Optional: to enable the Adlib device on the default SB16 ports too
VBoxManage setextradata "$vm" VBoxInternal/Devices/adlib/0/Config/MirrorPort "0x220"
# Optional: to enable an IRQ for MPU-401 MIDI input
VBoxManage setextradata "$vm" VBoxInternal/Devices/mpu401/0/Config/IRQ 9

