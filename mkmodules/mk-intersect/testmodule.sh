#!/usr/bin/env bash
## This small script runs a module test with the sample data

###
export NEANDERTAL_VCF="test/reference/Ancestral/AltaiNea.hg19_1000g.22.mod.vcf.gz"
export DENISOVAN_VCF="test/reference/Ancestral/vindija.22.sample.vcf.gz"
export CHIMPANCE_VCF="test/reference/Ancestral/pan_troglodytes_19.vcf.gz"
###

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
rm -rf neandertal_denisovan_chimpance/
mkdir -p test/results
echo "[>>.] results will be created in test/results/*.bed"
## Execute runmk.sh, it will find the basic example in test/data
## Move results from test/data to test/results
bash runmk.sh \
&& mv test/data/*.tsv neandertal_denisovan_chimpance/*.vcf.gz* test/results/ \
&& echo "[>>>] Module Test Successful"
