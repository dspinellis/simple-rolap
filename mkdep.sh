#!/bin/sh
#
# Create a list of dependencies for all SQL files in the current
# directory.
# As a side effect:
# 1. Ensure that table names are specified on the same line as FROM and
#    JOIN
# 2. set the timestamp of table-tracking files to the corresponding
#    table's creation time.
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
need_var ROLAPDB

for i in *.sql ; do

  # Issue error if dependencies can't be tracked
  if egrep -iHn '^.*\<(from|join)[ \t]*$' "$i" 1>&2 ; then
    echo 'No table specified after FROM or JOIN in the above statement(s)' 1>&2
    echo 'Dependencies cannot be correctly tracked' 1>&2
    exit 1
  fi

  base=$(basename "$i" .sql)
  if ! egrep -i '\<create[[:space:]]*table\>' "$i" >/dev/null ; then
    target="reports\\/$base.txt"
  else
    target="tables\\/$base"

    # Freshen target file's date if the table already exists
    case $RDBMS in
      mysql)
	need_var DBUSER
	T=$(echo "SELECT create_time FROM INFORMATION_SCHEMA.TABLES where table_schema = '$ROLAPDB' AND table_name = '$base'" | mysql -N -u $DBUSER $ROLAPDB)
	;;
    esac
    if [ -n "$T" ] ; then
      mkdir -p tables
      touch -d "$T" "tables/$base"
    fi
  fi

  # Output dependencies
  sed -rn "/^delete/IQ;s/^.*(from|join)[ \t]*$ROLAPDB\.([a-zA-Z][-_a-zA-Z0-9]*).*\$/$target: tables\/\2/ip" "$i"
done |
sort -u
