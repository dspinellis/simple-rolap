#!/bin/sed -f
#
# Convert a list of table and report dependencies into a GraphViz dot(1)
# diagram
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

# Graph header
1i\
digraph D {

# Graph footer
$a\
}

# Remove extension from the reports
s/\.txt//

# Space-separate dependencies
s/^\([^:]*\): \(.*\)/\2 \1/

# Tag tables and reports
s/reports\//Report\\n/g
s/tables\//Derived\\STable\\n/g
s/maindb\//Primary\\STable\\n/g

# Add opening quote
s/^/\t"/

# Add arrow
s/ /" -> "/

# Add closing quote
s/$/";/

# Unescape space
s/\\S/ /g
