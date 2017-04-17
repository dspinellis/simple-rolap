#!/bin/sed -f
#
# Create a sorted list of table dependencies
#
s/\.txt//
s/^\([^:]*\): \(.*\)/\2 \1/
