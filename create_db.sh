#!/bin/sh
#
# Create and setup access for the specified database if it does
# not exist.
#
# Copyright 2017-2019 Diomidis Spinellis
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
    need_var DBUSER
    # Exit if database already exists
    echo quit | mysql -h $DBHOST -u $DBUSER $ROLAPDB 2>/dev/null && exit
    echo '[Enter database administrator password for user root]'
    (
      echo "create database $ROLAPDB;" ;
      echo "GRANT ALL PRIVILEGES ON $ROLAPDB.* to $DBUSER@'localhost';" ;
      echo 'flush privileges;'
    ) |
    mysql -h $DBHOST -u root -p
    ;;
  postgresql)
    # Create a schema, rather than a database
    need_var ROLAPDB
    need_var DBUSER
    {
      echo "SET client_min_messages='ERROR';"
      echo "create schema if not exists $ROLAPDB;" 
    } |
    psql -q -v 'ON_ERROR_STOP=1' -h $DBHOST -U $DBUSER $MAINDB
    # Exit if creation time functionality already exists
    psql -v 'ON_ERROR_STOP=1' -h $DBHOST -U $DBUSER -c 'select count (*) from t_create_history;' $MAINDB >/dev/null 2>&1 && exit
    # Setup table creation time functionality
    psql -q -v 'ON_ERROR_STOP=1' -h $DBHOST -U $DBUSER $MAINDB <$ROLAP_DIR/psql-ctime.sql
    ;;
  sqlite)
    ;;
  *)
    echo "The RDBMS variable specifies an unsupported database engine: [$RDBMS]" 1>&2
    exit 1
    ;;
esac
