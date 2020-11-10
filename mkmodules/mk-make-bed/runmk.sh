#!/usr/bin/env bash

## find every .txt file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.txt" \
| sed 's#.txt#.bed#' \
| xargs mk
