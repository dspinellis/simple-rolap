#!/bin/sh
# Create a CSV file with files and lines per project

set -e

mkdir -p clones data
cd clones

file_list()
{
  git ls-tree --full-tree -r --name-only "$@" HEAD
}

while read id url ; do
  test -d $id || git clone --bare "$url" $id
  cd $id
  nfiles=$(file_list | wc -l)
  nlines=$(file_list -z |
    xargs -0 -I '{}' git show 'HEAD:{}' |
    wc -l)
  echo "$id,$nfiles,$nlines"
  cd ..
done <../reports/project_urls.txt >../data/metrics.csv
