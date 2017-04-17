#!/bin/sed -f
#
# Convert a list of table and report dependencies into a GraphViz dot(1)
# diagram
#
1i\
digraph D {
$a\
}
s/\.txt//
s/^\([^:]*\): \(.*\)/\2 \1/
s/reports\//Report\\n/g
s/tables\//Table\\n/g
s/^/\t"/
s/ /" -> "/
s/$/";/
