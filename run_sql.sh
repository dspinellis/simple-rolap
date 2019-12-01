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

# Add a drop table before a create table command
add_drop_table()
{
  sed 's/^\(.*create  *table  *\([^ (]*\).*\)/drop table if exists \2; \1/i' "$1"
}

# Add any configuration statements from the .config.sql file
add_config()
{
  if [ -r .config.sql ] ; then
    tr '\n' ' ' <.config.sql
  fi
}

. $ROLAP_DIR/need_var.sh

need_var RDBMS
need_var MAINDB

TAB=$(printf '\t')

case $RDBMS in
  mysql)
    need_var DBUSER
    need_var DBHOST
    need_var MAINDB
    {
      echo -n 'set autocommit=0; '
      add_config
      add_drop_table "$1"
      echo "commit;"
    } |
    mysql -h $DBHOST --quick --local-infile -u "$DBUSER" $MAINDB
    ;;
  postgresql)
    need_var DBUSER
    need_var DBHOST
    need_var MAINDB
    {
      echo -n "SET client_min_messages='ERROR';"
      echo -n 'begin; '
      add_config
      add_drop_table "$1"
      echo "commit;"
    } |
    psql -q -t -F "$TAB" -P footer -A -v 'ON_ERROR_STOP=1' -h $DBHOST -U $DBUSER $MAINDB
    ;;
  sqlite)
    need_var ROLAPDB
    {
      echo -n "ATTACH DATABASE '$ROLAPDB.db' AS $ROLAPDB; "
      add_config
      add_drop_table "$1"
    } |
    sqlite3 $MAINDB.db
    ;;
  *)
    echo "The RDBMS variable specifies an unsupported database engine: [$RDBMS]" 1>&2
    exit 1
    ;;
esac
