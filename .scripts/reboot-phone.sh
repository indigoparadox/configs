#!/bin/sh

wget --user=$IPPHONE_USER --password=`keyring get $IPPHONE_IP $IPPHONE_USER` http://$IPPHONE_IP/admin/reboot -O - > /dev/null 2>&1
