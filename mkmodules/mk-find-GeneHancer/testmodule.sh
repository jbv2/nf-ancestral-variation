#!/usr/bin/env bash
## This small script runs a module test with the sample data

###
export GENEHANCER="test/reference/GeneHancer_hg19.bed"
###

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results/*.tsv"
## Execute runmk.sh, it will find the basic example in test/data
## Move results from test/data to test/results
bash runmk.sh \
&& mv test/data/*.tsv test/results/ \
&& echo "[>>>] Module Test Successful"
