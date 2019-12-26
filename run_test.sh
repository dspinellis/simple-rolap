#!/bin/sh
#
# Run the rdbunit test files
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

# Temporary file that will be deleted on exit
trap 'rm -f "$db_out" "$rdbu_err"' 0
trap 'exit 2' 1 2 15
db_out=$(mktemp /tmp/run-test-db_out.XXXXXX)
rdbu_err=$(mktemp /tmp/run-test-rdbu_err.XXXXXX)

UNIT=${UNIT:-*.rdbu}

# Exit rdbunit each time to ensure it runs with a clean slate
for i in $UNIT ; do
  case $RDBMS in
    mysql)
      need_var DBHOST
      rdbunit --database=mysql $i 2>$rdbu_err |
	mysql -h $DBHOST -u root -N >$db_out
      ;;
    postgresql)
      need_var DBHOST
      need_var DBUSER
      need_var MAINDB
      rdbunit --database=postgresql $i 2>$rdbu_err |
	psql -h $DBHOST -U $DBUSER -t -q $MAINDB >$db_out
      ;;
    sqlite)
      rdbunit --database=sqlite $i 2>$rdbu_err |
	sqlite3 >$db_out
      ;;
    *)
      echo "Unknown or unset RDBMS: [$RDBMS]" 1>&2
      exit 2
      ;;
  esac

  db_exit=$?

  if [ -s $rdbu_err ] ; then
    echo "Error in rdbu_unit specification $i" 1>&2
    cat $rdbu_err 1>&2
    exit 2
  fi

  if [ $db_exit -ne 0 ] ; then
    echo "Error in database execution for $i" 1>&2
    exit 3
  fi

  # If we reach this point the database command finished without an error
  # Verify the file's contents
  grep -v '^$' $db_out
  if egrep -v -e '^ *ok [0-9]' -e '^ *[0-9]+\.\.[0-9]+.?$' -e '^ *$' $db_out >/dev/null; then
    echo "The test $i failed or produced extraneous output" 1>&2
    exit 4
  fi

done

echo 'All tests succeeded' 1>&2
