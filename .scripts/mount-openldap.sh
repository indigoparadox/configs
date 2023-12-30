#!/bin/bash

sshfs -o password_stdin openldap-edit@${LDAP_SERVER}:/ /mnt/${LDAP_SERVER} <<< `keyring get ${LDAP_SERVER} openldap-edit`

