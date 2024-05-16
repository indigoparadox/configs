#!/bin/bash

read -rsp "Password: " pass
export $(echo -n "$pass" | gnome-keyring-daemon --replace --unlock)
unset pass

