#!/usr/bin/env -S sed -nf
#
# Copyright 2017-2026 Diomidis Spinellis
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
# Create database schema relationships when called on the output of the
# schema listing.
#

# Remove comments
s/[ \t]*--.*//

/^CREATE TABLE /{
  s/^CREATE TABLE \([^(]*\).*/\1/
  h
}

/REFERENCES /{
  s/.*REFERENCES \([^ (]*\).*/\1/
  G
  s/\n/& -> /
  s/$/;/
  p
}


# Terminate file with closing brace
$ {
  s/.*/}/
  p
}
