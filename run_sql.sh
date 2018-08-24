#!/bin/sh
#
# Run the specified SQL file with autocommit disabled
# If the SQL creates a table ensure it is removed
#
# Copyright 2017 Diomidis Spinellis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case $RDBMS in
  mysql)
    {
      echo 'set autocommit=0;'
      sed -n 's/^.*create  *table  *\([^ (]*\).*/drop table if exists \1;/pi' "$1"
      cat "$1"
      echo "commit;"
    } |
    mysql --quick --local-infile -u $DBUSER -p"$DBPASSWD" $MAINDB
    ;;
  sqlite)
    {
      echo "ATTACH DATABASE '$ROLAPDB.db' AS $ROLAPDB;"
      sed -n 's/^.*create  *table  *\([^ (]*\).*/drop table if exists \1;/pi' "$1"
      cat "$1"
    } |
    sqlite3 $MAINDB.db
    ;;
  *)
    echo "Unknown or unset RDBMS: [$RDBMS]" 1>&2
    exit 1
    ;;
esac
