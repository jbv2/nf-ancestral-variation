## load libraries
library("dplyr")
#library("tidyr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/noneandertal_nochimpance.tsv" ## %.tsv values file
# args[2] <- "test/reference/gwas_catalog_v1.0.2-associations_e100_r2020-10-20.tsv" ## reference
# args[3] <- "test/data/noneandertal_nodenisovan_nochimpance.GWASC.tsv" ## output1
# args[4] <- "test/data/noneandertal_nodenisovan_nochimpance.ClinVar.tsv" ## output2

## Passing args to named objects
tsv_file <- read.table(file = args[1], header = T, sep = "\t", stringsAsFactors = F)

gwas <- read.table(file = args[2], header = T, sep = "\t", stringsAsFactors = F, fill = T, quote = "") %>%
  rename(gwas_ID=STRONGEST.SNP.RISK.ALLELE) %>% 
  select(gwas_ID, DISEASE.TRAIT, X95..CI..TEXT., P.VALUE, INITIAL.SAMPLE.SIZE, STUDY.ACCESSION,PUBMEDID) %>%
  rename(Disease_trait=DISEASE.TRAIT, Effect=X95..CI..TEXT., P_value=P.VALUE, Initial_Sample_Size=INITIAL.SAMPLE.SIZE, Study_Accession=STUDY.ACCESSION)

gwas_output <- args[3]

clinvar_output <- args[4]

##Manipulating files

variants.df <- tsv_file %>%
  select(-BED_Score, -BED_strand., -clinvar_clnsig, -clinvar_golden_stars, -clinvar_rs, -clinvar_trait) %>%
  mutate(gwas_ID = paste(ID, ALT, sep = "-")) 

gwasc_variants.df <- inner_join(x = variants.df, y = gwas, "gwas_ID")

clinvar_variants.df <- tsv_file %>%
filter(clinvar_rs!="-")

# save tsv
write.table(x = gwasc_variants.df,
            file = gwas_output,
            append = F, quote = F,
            sep = "\t",
            row.names = F, col.names = T)

write.table(x = clinvar_variants.df,
            file = clinvar_output,
            append = F, quote = F,
            sep = "\t",
            row.names = F, col.names = T)
