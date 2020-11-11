#!/usr/bin/env bash

## find every .txt file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.txt" \
  ! -name "*.filtered.txt"  \
| sed 's#.txt#.filtered.txt#' \
| xargs mk
