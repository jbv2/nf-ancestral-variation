#!/usr/bin/env bash
## This small script runs a module test with the sample data

###
export CHAIN="test/reference/hg38ToHg19.over.chain.gz"
###

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"*.bed
## Execute runmk.sh, it will find the basic example in test/data
## Move results from test/data to test/results
bash runmk.sh \
&& mv test/data/*.liftover.bed* test/results/ \
&& echo "[>>>] Module Test Successful"
