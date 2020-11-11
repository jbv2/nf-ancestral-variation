#!/usr/bin/env bash

## find every .txt file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.liftover.vcf.gz" \
  ! -name ".liftover.bed" \
  ! -name "pan_troglodytes_19.vcf.gz*" \
  ! -name "AltaiNea.hg19_1000g.22.mod.vcf.gz*" \
  ! -name "vindija.22.sample.vcf.gz*" \
| sed 's#.liftover.vcf.gz#.tsv#' \
| xargs mk
