#!/usr/bin/env bash
## This small script runs a module test with the sample data

###
export FASTA_REFERENCE="test/reference/Hg19new.fa.gz"
export BCFTOOLS="bcftools"
###

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results/*.vcf.gz"
## Execute runmk.sh, it will find the basic example in test/data
## Move results from test/data to test/results
bash runmk.sh \
&& mv test/data/*.vcf.gz* test/results/ \
&& echo "[>>>] Module Test Successful"
