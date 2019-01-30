#!/bin/sh
#
# Create a list of dependencies for all SQL files in the current
# directory
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

for i in *.sql ; do
  base=$(basename "$i" .sql)
  if grep -i '^select' "$i" >/dev/null ; then
    target="reports\\/$base.txt"
  else
    target="tables\\/$base"
  fi
  sed -rn "/^delete/iQ;s/^.*(from|join)  *$ROLAPDB\.([a-zA-Z][-_a-zA-Z0-9]*).*\$/$target: tables\/\2/ip" "$i"
done |
sort -u
