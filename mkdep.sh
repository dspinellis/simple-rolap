#!/bin/sh
#
# Create a list of dependencies for all SQL files in the current
# directory
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

if [ -z "$ROLAPDB" ] ; then
  echo 'Environment variable ROLAPDB is not set' !>&2
  exit 1
fi

for i in *.sql ; do

  # Issue error if dependencies can't be tracked
  if grep -i '/^.*(from|join)[ \t]' "$i" ; then
    echo 'No table specified after FROM or JOIN in the above statement(s)' 1>&2
    echo 'Dependencies cannot be correctly tracked' 1>&2
    exit 1
  fi

  base=$(basename "$i" .sql)
  if grep -i '^select' "$i" >/dev/null ; then
    target="reports\\/$base.txt"
  else
    target="tables\\/$base"
  fi
  sed -rn "/^delete/IQ;s/^.*(from|join)[ \t]*$ROLAPDB\.([a-zA-Z][-_a-zA-Z0-9]*).*\$/$target: tables\/\2/ip" "$i"
done |
sort -u
