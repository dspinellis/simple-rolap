#!/bin/sh
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

test "$V" = 2 && set -x

# Exit with an error if the specified environment variable isn't set
need_var()
{
  local val=$(eval echo \$$1)
  if [ -z "$val" ] ; then
    echo "Required environment variable $1 is not set." 1>&2
    exit 1
  fi
}
