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

. $ROLAP_DIR/need_var.sh

need_var RDBMS

case $RDBMS in
  mysql)
    need_var ROLAPDB
    echo '[Enter database administrator password for user root]'
    echo "drop database if exists $ROLAPDB;" |
    mysql -h $DBHOST -u root -p
    ;;
  postgresql)
    need_var MAINDB
    need_var ROLAPDB
    need_var DBUSER
    {
      echo "SET client_min_messages='ERROR';"
      echo "delete from t_create_history where schema_name = '$ROLAPDB';"
      echo "drop schema if exists $ROLAPDB cascade;"
    } |
    psql -q -h $DBHOST -U $DBUSER $MAINDB
    ;;
  sqlite)
    need_var MAINDB
    rm -f "$MAINDB.db"
    ;;
  *)
    echo "The RDBMS variable specifies an unsupported database engine: [$RDBMS]" 1>&2
    exit 1
    ;;
esac
