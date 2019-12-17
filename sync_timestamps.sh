#!/bin/sh
#
# Synchronize the timestamps of unmodified files with their commit times
# in the Git repo
#
# Copyright 2019 Diomidis Spinellis
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

git ls-files |
while read file ; do
  # Skip different files
  git diff --quiet "$file" || continue
  # Obtain commit time
  t=$(git log --pretty=format:%cd -n 1 --date=format:%Y%m%d%H%M.%S -- "$file")
  # Set file's time to the commit time
  touch -m -t "$t" "$file"
done
