#!/usr/bin/env nextflow

/*================================================================
The Paleogenomics LAB presents...

  A pipeline to get the ancestral annotations variants.

==================================================================
Version: 0.1
Project repository:
==================================================================
Authors:

- Bioinformatics Design
 Judith Ballesteros Villascán (judith.vballesteros@gmail.com)

- Bioinformatics Development
 Judith Ballesteros Villascán (judith.vballesteros@gmail.com)

- Nextflow Port
 Judith Ballesteros Villascán (judith.vballesteros@gmail.com)

=============================
Pipeline Processes In Brief:
.
Pre-processing:
_pre1_simplify_file
_pre2_make_bed
_pre3_liftover
_pre4_bed2vcf

Core-processing:
_001_intersect
_002_find_GeneHancer
_003_find_GWASC_ClinVar

Pos-processing


================================================================*/

/* Define the help message as a function to call when needed *//////////////////////////////
def helpMessage() {
	log.info"""
  ==========================================
  A vcf nf-ancestral-variation pipeline
  v${version}
  ==========================================

	Usage:

  nextflow run ancestral_variation.nf --input_file <path to input 1> [--output_dir path to results ]

	  --input_file    <- txt file with annotation;
	  --output_dir     <- directory where results, intermediate and log files will be stored
	  -resume	   <- Use cached results if the executed project has been run before;
				default: not activated
				This native NF option checks if anything has changed from a previous pipeline execution.
				Then, it resumes the run from the last successful stage.
				i.e. If for some reason your previous run got interrupted,
				running the -resume option will take it from the last successful pipeline stage
				instead of starting over
				Read more here: https://www.nextflow.io/docs/latest/getstarted.html#getstart-resume
	  --help           <- Shows Pipeline Information
	  --version        <- Show nf-ancestral_variation version
	""".stripIndent()
}

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
version = "0.1"

/*//////////////////////////////
  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
pipeline_name = "nf-ancestral_variation"

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.vcf_file = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.help = false //default is false to not trigger help message automatically at every run
params.version = false //default is false to not trigger version message automatically at every run

/*//////////////////////////////
  If the user inputs the --help flag
  print the help message and exit pipeline
*/
if (params.help){
	helpMessage()
	exit 0
}

/*//////////////////////////////
  If the user inputs the --version flag
  print the pipeline version
*/
if (params.version){
	println "nf-ancestral_variation v${version}"
	exit 0
}

/*//////////////////////////////
  Define the Nextflow version under which this pipeline was developed or successfuly tested
  Updated by jballesteros at NOVEMBER 2020
*/
nextflow_required_version = '20.04.1.0'
/*
  Try Catch to verify compatible Nextflow version
  If user Nextflow version is lower than the required version pipeline will continue
  but a message is printed to tell the user maybe it's a good idea to update her/his Nextflow
*/
try {
	if( ! nextflow.version.matches(">= $nextflow_required_version") ){
		throw GroovyException('Your Nextflow version is older than Pipeline required version')
	}
} catch (all) {
	log.error "-----\n" +
			"  This pipeline requires Nextflow version: $nextflow_required_version \n" +
      "  But you are running version: $workflow.nextflow.version \n" +
			"  The pipeline will continue but some things may not work as intended\n" +
			"  You may want to run `nextflow self-update` to update Nextflow\n" +
			"============================================================"
}

/*//////////////////////////////
  INPUT PARAMETER VALIDATION BLOCK
*/

/* Check if the input directory is provided
    if it was not provided, it keeps the 'false' value assigned in the parameter initiation block above
    and this test fails
*/
if ( !params.input_file ) {
  log.error " Please provide the --input_file \n\n" +
  " For more information, execute: nextflow run nf-ancestral_variation --help"
  exit 1
}

/*
Output directory definition
Default value to create directory is the parent dir of --input_file
*/
params.output_dir = file(params.input_file).getParent()

/*
  Results and Intermediate directory definition
  They are always relative to the base Output Directory
  and they always include the pipeline name in the variable (pipeline_name) defined by this Script

  This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*
Useful functions definition
*/
/* define a function for extracting the file name from a full path */
/* The full path will be the one defined by the user to indicate where the reference file is located */
def get_baseName(f) {
	/* find where is the last appearance of "/", then extract the string +1 after this last appearance */
  	f.substring(f.lastIndexOf('/') + 1);
}


/*//////////////////////////////
  LOG RUN INFORMATION
*/
log.info"""
==========================================
The nf-ancestral_variation
v${version}
==========================================
"""
log.info "--Nextflow metadata--"
/* define function to store nextflow metadata summary info */
def nfsummary = [:]
/* log parameter values beign used into summary */
/* For the following runtime metadata origins, see https://www.nextflow.io/docs/latest/metadata.html */
nfsummary['Resumed run?'] = workflow.resume
nfsummary['Run Name']			= workflow.runName
nfsummary['Current user']		= workflow.userName
/* string transform the time and date of run start; remove : chars and replace spaces by underscores */
nfsummary['Start time']			= workflow.start.toString().replace(":", "").replace(" ", "_")
nfsummary['Script dir']		 = workflow.projectDir
nfsummary['Working dir']		 = workflow.workDir
nfsummary['Current dir']		= workflow.launchDir
nfsummary['Launch command'] = workflow.commandLine
log.info nfsummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "\n\n--Pipeline Parameters--"
/* define function to store nextflow metadata summary info */
def pipelinesummary = [:]
/* log parameter values beign used into summary */
pipelinesummary['Input File']			= params.input_file
pipelinesummary['Results Dir']		= results_dir
pipelinesummary['Intermediate Dir']		= intermediates_dir
/* print stored summary info */
log.info pipelinesummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "==========================================\nPipeline Start"

/*//////////////////////////////
  PIPELINE START
*/

/*
	READ INPUTS
*/

/* Load txt file into channel */
Channel
  .fromPath("${params.input_file}*")
	.toList()
  .set{ txt_input }

/* _pre1_simplify_file */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-simplify-file/*")
	.toList()
	.set{ mkfiles_pre1 }

process _pre1_simplify_file {

	publishDir "${intermediates_dir}/_pre1_simplify_file/",mode:"symlink"

	input:
	file txt from txt_input
	file mk_files from mkfiles_pre1

	output:
	file "*.filtered.txt" into results_pre1_simplify_file

	"""
	bash runmk.sh
	"""

}

/* _pre2_make_bed */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-make-bed/*")
	.toList()
	.set{ mkfiles_pre2 }

process _pre2_make_bed {

	publishDir "${intermediates_dir}/_pre2_formatvcf/",mode:"symlink"

	input:
	file txt from results_pre1_simplify_file
	file mk_files from mkfiles_pre2

	output:
	file "*.bed" into results_pre2_make_bed

  """
  bash runmk.sh
  """

}

/* _pre3_liftover */
/* get the chain file into a channel */
  Channel
	.fromPath("${params.chain_file}*")
	.toList()
	.set{ chain_file }

/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-liftover/*")
	.toList()
	.set{ mkfiles_pre3 }

process _pre3_liftover {

	publishDir "${intermediates_dir}/_pre3_liftover/",mode:"symlink"

	input:
	file bed from results_pre2_make_bed
  file chain from chain_file
	file mk_files from mkfiles_pre3

	output:
	file "*.liftover.bed" into results_pre3_liftover

  """
  export CHAIN="$chain"
  bash runmk.sh
  """

}

/* _pre4_bed2vcf */
/* Gather every previous result from pre4 before rejoining */
results_pre3_liftover
.toList()
.set{ lifted }

/* get the fasta reference into a channel */
  Channel
	.fromPath("${params.fasta_reference}*")
	// .toList()
	// .view()
	.set{ reference }

/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-bed2vcf/*")
	.toList()
	.set{ mkfiles_pre4 }

process _pre4_bed2vcf {

	publishDir "${intermediates_dir}/_pre4_bed2vcf/",mode:"symlink"

	input:
	file bed from lifted
  file fasta from reference
	file mk_files from mkfiles_pre4

	output:
	file "5_2.5_Data101719_.filtered.liftover.vcf.gz" into results_pre4_bed2vcf mode flatten

	"""
	export BCFTOOLS="${params.bcftools}"
	export FASTA_REFERENCE="$fasta"
	bash runmk.sh
	"""

}

// // /* _001_intersect */
// // /* Gather every previous result from pre4 before rejoining */
// results_pre4_bed2vcf
// .toList()
// .set{ vcfs }
//
// /* Read mkfile module files */
// Channel
// 	.fromPath("${workflow.projectDir}/mkmodules/mk-intersect/*")
// 	.toList()
// 	.set{ mkfiles_001 }
//
// process _001_intersect {
//
// 	publishDir "${intermediates_dir}/_001_intersect/",mode:"symlink"
//
// 	input:
// 	file vcf from vcfs
// 	file mk_files from mkfiles_001
//
// 	output:
// 	file "neandertal_denisovan_chimpance/*.vcf.g*" into results_001_intersect mode flatten
// 	file "*.tsv" into results_001_intersect_tsv
//
// 	"""
// 	export NEANDERTAL_VCF="${params.neandertal_vcf}"
// 	export DENISOVAN_VCF="${params.denisovan_vcf}"
// 	export CHIMPANCE_VCF="${params.chimpance_vcf}"
// 	bash runmk.sh
// 	"""
//
// }

// /* _002_find_GeneHancer */
// /* Gather every previous result from pre4 before rejoining */
// results_001_intersect
// .toList()
// .into{ vcf_intersected; vcf_intersected_2 }
//
// /* get the ancestral genomes into a channel */
//   Channel
// 	.fromPath("${params.genehancer}*")
// 	.toList()
// 	.set{ genehancer }
//
// /* Read mkfile module files */
// Channel
// 	.fromPath("${workflow.projectDir}/mkmodules/mk-find-GeneHancer/*")
// 	.toList()
// 	.set{ mkfiles_002 }
//
// process _002_find_GeneHancer {
//
// 	publishDir "${intermediates_dir}/_002_find_GeneHancer/",mode:"copy"
//
// 	input:
// 	file vcf from vcf_intersected
//   file gh from genehancer
// 	file mk_files from mkfiles_002
//
// 	output:
// 	file "*.tsv*" into results_002_find_GeneHancer
//
// 	"""
// 	export GENEHANCER="$gh"
// 	bash runmk.sh
// 	"""
//
// }
//
// /* _003_find_GWASC_ClinVar */
// /* Gather every previous result from pre4 before rejoining */
// // results_001_intersect
// // .toList()
// // .set{ vcf_intersected_2 }
//
// /* get the ancestral genomes into a channel */
//   Channel
// 	.fromPath("${params.gwasc}*")
// 	.toList()
// 	.set{ gwasc }
//
// /* Read mkfile module files */
// Channel
// 	.fromPath("${workflow.projectDir}/mkmodules/mk-find-GWASC-ClinVar/*")
// 	.toList()
// 	.set{ mkfiles_003 }
//
// process _003_find_GWASC_ClinVar {
//
// 	publishDir "${intermediates_dir}/_003_find_GWASC_ClinVar/",mode:"copy"
//
// 	input:
// 	file vcf from vcf_intersected_2
//   file association from gwasc
// 	file mk_files from mkfiles_003
//
// 	output:
// 	file "*.tsv*" into results_003_find_GWASC_ClinVar
//
// 	"""
// 	export GWASC="$association"
// 	bash runmk.sh
// 	"""
//
// }
