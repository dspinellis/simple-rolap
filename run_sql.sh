#!/bin/sh
#
# Run the specified SQL file with autocommit disabled
# If the SQL creates a table ensure it is removed
#

{
  echo 'set autocommit=0;'
  sed -n 's/^.*create  *table  *\([^ (]*\).*/drop table if exists \1;/pi' "$1"
  cat "$1"
  echo "commit;"
} |
mysql --local-infile -u $DBUSER -p"$DBPASSWD" $MAINDB
