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

set -e

case $RDBMS in
  mysql)
    rdbunit --database=mysql *.rdbu | mysql -u root -p$DBPASS -N
    ;;
  sqlite)
    # Exit rdbunit each time to ensure it runs with a clean slate
    for i in *.rdbu ; do
      rdbunit --database=sqlite $i | sqlite3
    done
    ;;
  *)
    echo "Unknown or unset RDBMS: [$RDBMS]" 1>&2
    exit 1
    ;;
esac