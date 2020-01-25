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
# Copyright 2017-2020 Diomidis Spinellis
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

# Do not attempt to run if database hasn't been created
if ! [ -r $ROLAPDB ] ; then
  exit
fi

for i in *.sql ; do

  # Issue error if dependencies can't be tracked
  if egrep -iHn '^.*\<(from|join)[[:space:]]*$' "$i" 1>&2 ; then
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
    if [ -z "$SKIP_TIMESTAMPING" ] ; then
      case $RDBMS in
	mysql)
	  need_var DBUSER
	  T=$(echo "SET time_zone='+00:00'; SELECT create_time FROM INFORMATION_SCHEMA.TABLES where table_schema = '$ROLAPDB' AND table_name = '$base'" |
	  mysql -h $DBHOST -N -u $DBUSER $ROLAPDB)
	  ;;
	postgresql)
	  T=$(echo "SELECT MAX(creation_date) FROM t_create_history where schema_name = '$ROLAPDB' AND object_identity = '$ROLAPDB.$base'" |
	  psql -h $DBHOST -U $DBUSER -t -q $MAINDB |
          sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
	  ;;
      esac
      if [ -n "$T" ] ; then
	mkdir -p tables
	TZ=UTC touch -d "$T" "tables/$base"
      fi
    fi
  fi

  # Output dependencies
  # Dependency patterns to search and replace
  SEARCH_ROLAPDB="^(.*)\<(from|join)[[:space:]]*$ROLAPDB\.([a-zA-Z][-_a-zA-Z0-9]*)(.*)"
  SEARCH_MAINDB="^(.*)\<(from|join)[[:space:]]*([a-zA-Z][-_a-zA-Z0-9]*)(.*)"
  sed -rn "
# Ignore delete queries
/^delete/IQ

# Remove line comments
s/--.*//

:retry_rolap
/$SEARCH_ROLAPDB/I {
  h		# Save pattern in hold space
  # Create dependency
  s/$SEARCH_ROLAPDB/$target: tables\/\3/I
  p		# Print dependency
  g		# Get back pattern space
  # Remove dependency
  s/$SEARCH_ROLAPDB/\1 \4/I
  b retry_rolap	# Try for another dependency
}
:retry_main
/$SEARCH_MAINDB/I {
  h		# Save pattern in hold space
  # Create dependency
  s/$SEARCH_MAINDB/$target: maindb\/\3/I
  p		# Print dependency
  g		# Get back pattern space
  # Remove dependency
  s/$SEARCH_MAINDB/\1 \4/I
  b retry_main	# Try for another dependency
}
" "$i"

done |
sort -u
