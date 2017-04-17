#!/bin/sh
#
# Create a list of dependencies for all SQL files in the current
# directory
#

for i in *.sql ; do
  base=$(basename $i .sql)
  if grep '^select' $i >/dev/null ; then
    target="reports\\/$base.txt"
  else
    target="tables\\/$base"
  fi
  sed -rn "/^delete/Q;s/^.*(from|join)  *$MAINDB\.([a-zA-Z][-_a-zA-Z0-9]*).*\$/$target: tables\/\2/p" $i
done |
sort -u
