#!/bin/sh
#
# Create tags for all tables to allow their quick access through editors
# that support them, such as vim or Emacs.
#

for i in $* ; do
  sed -nr \
    "s|^.*(create  *table  *([^.]*\\.)?([^ (]*)).*|\\3\t$i\t/\1/|ip" $i
done |
sort >tags
