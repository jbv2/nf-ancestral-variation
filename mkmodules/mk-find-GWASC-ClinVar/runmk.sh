#!/bin/bash

find -L . \
  -type f \
  -name "*.vcf.gz" \
  ! -name "*hg19.vcf.gz" \
  ! -name "*troglodytes*.vcf.gz" \
  ! -name "Altai*" \
  ! -name "vindija*" \
| sed "s#.vcf.gz#.GWASC.tsv#" \
| xargs mk
