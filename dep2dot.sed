#!/bin/sed -f
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
