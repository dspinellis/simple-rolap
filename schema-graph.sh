#!/bin/sh
#
# Output a graph of the SQLite3 database schema
#
# This requires nicely formatted table definitions, with each
# element on a separate line.

set -eu

cat $ROLAP_DIR/schema-head.dot
echo .schema |
  sqlite3 $ROLAPDB.db |
  sed -E '/^\s*(CREATE\s+(UNIQUE\s+)?INDEX)/,/;$/d' |
  $ROLAP_DIR/schema2nodes.sed
echo .schema |
  sqlite3 $ROLAPDB.db |
  $ROLAP_DIR/schema2edges.sed
