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

# Exit with an error if the specified environment variable isn't set
need_var()
{
  local val=$(eval echo \$$1)
  if [ -z "$val" ] ; then
    echo "Required environment variable $1 is not set." 1>&2
    exit 1
  fi
}

need_var RDBMS
need_var MAINDB

case $RDBMS in
  mysql)
    need_var DBUSER
    need_var DBPASSWD
    {
      echo -n 'set autocommit=0; '
      add_drop_table "$1"
      echo "commit;"
    } |
    mysql --quick --local-infile -u $DBUSER -p"$DBPASSWD" $MAINDB
    ;;
  sqlite)
    need_var ROLAPDB
    {
      echo -n "ATTACH DATABASE '$ROLAPDB.db' AS $ROLAPDB; "
      add_drop_table "$1"
    } |
    sqlite3 $MAINDB.db
    ;;
  *)
    echo "The RDBMS variable specifies an unsupported database engine: [$RDBMS]" 1>&2
    exit 1
    ;;
esac
