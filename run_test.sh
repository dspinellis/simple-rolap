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

set -e

# Temporary file that will be deleted on exit
trap 'rm -f "$tmpfile"' 0
trap 'exit 2' 1 2 15
tmpfile=$(mktemp /tmp/run-test.XXXXXX)

UNIT=${UNIT:-*.rdbu}

case $RDBMS in
  mysql)
    need_var DBHOST
    rdbunit --database=mysql $UNIT | mysql -h $DBHOST -u root -N >$tmpfile
    ;;
  postgresql)
    need_var DBHOST
    need_var DBUSER
    need_var MAINDB
    rdbunit --database=postgresql $UNIT |
      psql -h $DBHOST -U $DBUSER -t -q $MAINDB >$tmpfile
    ;;
  sqlite)
    # Exit rdbunit each time to ensure it runs with a clean slate
    for i in $UNIT ; do
      rdbunit --database=sqlite $i | sqlite3 >$tmpfile
    done
    ;;
  *)
    echo "Unknown or unset RDBMS: [$RDBMS]" 1>&2
    exit 1
    ;;
esac

# If we reach this point the database command finished without an error
# Verify the file's contents
grep -v '^$' $tmpfile
if egrep -v -e '^ *ok [0-9]' -e '^ *[0-9]+\.\.[0-9]+.?$' -e '^ *$' $tmpfile >/dev/null; then
  echo 'A test failed or produced extraneous output' 1>&2
  exit 1
else
  echo 'All tests succeeded' 1>&2
  exit 0
fi
