#!/bin/sed -f
s/\.txt//
s/^\([^:]*\): \(.*\)/\2 \1/
