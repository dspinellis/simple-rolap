#!/bin/sed -f
#
# Convert a list of table and report dependencies into a GraphViz dot(1)
# diagram
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

1i\
digraph D {
$a\
}
s/\.txt//
s/^\([^:]*\): \(.*\)/\2 \1/
s/reports\//Report\\n/g
s/tables\//Table\\n/g
s/^/\t"/
s/ /" -> "/
s/$/";/
