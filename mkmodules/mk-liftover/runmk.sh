#!/usr/bin/env bash

## find every .txt file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.bed" \
  ! -name "GeneHancer*" \
| sed 's#.bed#.liftover.bed#' \
| xargs mk
