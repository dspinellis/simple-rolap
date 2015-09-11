#!/bin/sh

for i in $* ; do
  sed -nr \
    "s|^.*(create  *table  *([^.]*\\.)?([^ (]*)).*|\\3\t$i\t/\1/|ip" $i
done |
sort >tags
