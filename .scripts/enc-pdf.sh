#!/bin/sh
mkdir -p encrypted
for p in *.pdf; do
   qpdf --encrypt "`cat pw.txt`" "`cat pw.txt`" 256 -- "$p" "encrypted/$p"
done
