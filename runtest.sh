input_file="test/data/5_2.5_Data101719_.txt"
output_directory=$(dirname $input_file)/results/

echo -e "======\n Testing NF execution \n======" \
&& rm -rf test/results/ \
&& nextflow run ancestral_variation.nf \
	--input_file $input_file \
	--chain_file test/reference/hg38ToHg19.over.chain.gz \
	--fasta_reference "test/reference/Hg19new.fa.gz" \
	--neandertal test/reference/Ancestral/AltaiNea.hg19_1000g.22.mod.vcf.gz \
	--denisovan "test/reference/Ancestral/vindija.22.sample.vcf.gz" \
	--chimpance "test/reference/Ancestral/pan_troglodytes_19.vcf.gz" \
	--genehancer test/reference/GeneHancer_hg19.bed \
	--gwasc test/reference/gwas_catalog_v1.0.2-associations_e100_r2020-10-20.tsv \
	--output_dir $output_directory \
	-resume \
	-with-report $output_directory/`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag $output_directory/`date +%Y%m%d_%H%M%S`.DAG.html \
&& echo -e "======\n nf-ancestral_variation: Basic pipeline TEST SUCCESSFUL \n======"
