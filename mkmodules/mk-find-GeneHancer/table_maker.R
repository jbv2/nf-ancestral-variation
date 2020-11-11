## load libraries
library("dplyr")
library("tidyr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/noneandertal_nochimpance.tmp" ## %.tsv values file
# args[2] <- "test/data/noneandertal_nochimpance.tsv" ## output

tsv_file <- read.table(file = args[1], header = T, sep = "\t", stringsAsFactors = F)
output_file <- args[2]

tsv_file.df <- tsv_file %>%
  select(-QUAL, -FILTER, -BED_Score, -BED_strand) %>%
  separate(col = Genehancer, into = c("Genehancer_ID", "Genehancer_Type", "Genehancer_Gene"), sep = "_")

# save tsv
write.table(x = tsv_file.df,
            file = output_file,
            append = F, quote = F,
            sep = "\t",
            row.names = F, col.names = T)

