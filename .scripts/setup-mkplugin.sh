#!/bin/bash

CHECK_MK_PLUGIN="$1"

if [ -z "$CHECK_MK_URL" ]; then
   echo "CHECK_MK_URL has not been defined!"
   exit 1
fi

CHECK_MK_TEMP_DIR="`mktemp -d --suffix .checkmk`"
if [ -z "$CHECK_MK_PLUGINS_DIR" ]; then
   CHECK_MK_PLUGINS_DIR="/usr/lib/check_mk_agent/plugins/"
   echo "assuming default CHECK_MK_PLUGINS_DIR: $CHECK_MK_PLUGINS_DIR"
fi

wget "$CHECK_MK_URL/agents/plugins/$CHECK_MK_PLUGIN" \
   -O "$CHECK_MK_TEMP_DIR/$CHECK_MK_PLUGIN" && \
chmod -v +x "$CHECK_MK_TEMP_DIR/$CHECK_MK_PLUGIN" && \
sudo mv -v "$CHECK_MK_TEMP_DIR/$CHECK_MK_PLUGIN" "$CHECK_MK_PLUGINS_DIR" && \
sudo chown -v root:root "$CHECK_MK_PLUGINS_DIR/$CHECK_MK_PLUGIN"

if [ -n "$CHECK_MK_TEMP_DIR" ]; then
   rm -rvf "$CHECK_MK_TEMP_DIR"
fi

