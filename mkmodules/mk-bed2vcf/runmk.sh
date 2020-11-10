#!/usr/bin/env bash

## find every .txt file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.bed" \
  ! -name "Gene*" \
| sed 's#.bed#.vcf.gz#' \
| xargs mk
