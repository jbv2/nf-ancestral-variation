#!/usr/bin/env bash

## find every .txt file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.vcf.gz" \
  ! -name "*hg19.vcf.gz" \
  ! -name "*troglodytes*.vcf.gz" \
  ! -name "Altai*" \
  ! -name "vindija*" \
| sed 's#.vcf.gz#.genehancer.tsv#' \
| xargs mk
