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
# Create database schema tablaes when called on the output of the schema
# listing.
#

# Remove comments
s/[ \t]*--.*//

/CREATE TABLE/ {
  # Create table and line
  s|CREATE TABLE \([^\n]*\)(|\1 [label=<<TABLE BORDER="1" CELLSPACING="0" CELLBORDER="0">\n<TR><TD><B>\1</B></TD></TR><HR/>\n<TR ALIGN="LEFT"><TD  BALIGN="LEFT">|
  # Initialize hold space with this, so as to accumulate the complete table
  h
  # Remove first line from pattern space to continue processing
  s/.*\n//
}

# Empty lines
/^[ \t]*$/n

# Field name
/^  / {
  s/ INT[^,]*//
  s/ BOOLEAN[^,]*//
  s/ TEXT[^,]*//
  s/ UNIQUE.*//
  s/ PRIMARY KEY.*//
  # Put table fields in separate lines
  s|,$|<BR/>|
  # And append to hold space
  H
}

# Table has ended
/ *);/ {
  # Finish the table
  s| *);|</TD></TR></TABLE>>];|
  # Append to hold space
  H
  # Move to patten space
  g
  # Remove embedded newlines
  s/\n *//g
  # Print
  p
}
