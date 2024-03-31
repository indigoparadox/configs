#!/bin/bash

CHECK_MK_PLUGIN_IS_CONFIG=0
if [ "$1" = "-c" ]; then
   CHECK_MK_PLUGIN_IS_CONFIG=1
   CHECK_MK_PLUGIN="$2"
else
   CHECK_MK_PLUGIN="$1"
fi

if [ -z "$CHECK_MK_URL" ]; then
   echo "CHECK_MK_URL has not been defined!"
   exit 1
fi

CHECK_MK_TEMP_DIR="`mktemp -d --suffix .checkmk`"
if [ -z "$CHECK_MK_PLUGINS_DIR" ]; then
   if [ $CHECK_MK_PLUGIN_IS_CONFIG -eq 1 ]; then
      CHECK_MK_PLUGINS_DIR="/etc/check_mk"
   else
      CHECK_MK_PLUGINS_DIR="/usr/lib/check_mk_agent/plugins/"
   fi
   echo "assuming default CHECK_MK_PLUGINS_DIR: $CHECK_MK_PLUGINS_DIR"
fi

if [ $CHECK_MK_PLUGIN_IS_CONFIG -eq 1 ]; then
   CHECK_MK_PLUGIN_URL="$CHECK_MK_URL/agents/cfg_examples/$CHECK_MK_PLUGIN"
else
   CHECK_MK_PLUGIN_URL="$CHECK_MK_URL/agents/plugins/$CHECK_MK_PLUGIN"
fi

wget "$CHECK_MK_PLUGIN_URL" -O "$CHECK_MK_TEMP_DIR/$CHECK_MK_PLUGIN" && \
sudo mv -v "$CHECK_MK_TEMP_DIR/$CHECK_MK_PLUGIN" "$CHECK_MK_PLUGINS_DIR" && \
sudo chown -v root:root "$CHECK_MK_PLUGINS_DIR/$CHECK_MK_PLUGIN"

if [ -f "$CHECK_MK_PLUGINS_DIR/$CHECK_MK_PLUGIN" ]; then
   if [ $CHECK_MK_PLUGIN_IS_CONFIG -eq 1 ]; then
      # Make config only root-readable.
      chmod -v o-rwx "$CHECK_MK_PLUGINS_DIR/$CHECK_MK_PLUGIN"
   else
      # Only mark actual plugins as executable.
      chmod -v +x "$CHECK_MK_PLUGINS_DIR/$CHECK_MK_PLUGIN"
   fi
fi

if [ -n "$CHECK_MK_TEMP_DIR" ]; then
   rm -rvf "$CHECK_MK_TEMP_DIR"
fi

