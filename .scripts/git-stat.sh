#!/bin/bash

# Check project directories AND maug submodules if applicable.
for d in * */maug; do
   if [ ! -d "$d" ]; then
      continue
   fi
   if [ ! -d "$d/.git" ]; then
      continue
   fi
   bash -c "cd $d && git diff --exit-code > /dev/null 2>&1"
   GIT_RES=$?
   if [ $GIT_RES -eq 1 ]; then
      printf "\033[0;31m$d: DIRTY\033[0m\n"
   elif [ $GIT_RES -eq 0 ]; then
      printf "\033[0;32m$d: CLEAN\033[0m\n"
   fi
done
printf '\033[0m'

