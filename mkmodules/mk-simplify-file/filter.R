## load libraries
library("dplyr")
library(tidyr)

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/5_2.5_Data101719_.tmp" ## %.tsv values file
# args[2] <- "test/data/5_2.5_Data101719_.split" ## output

## Passing args to named objects
tsv_file <- read.table(file = args[1], header = T, sep = "\t", stringsAsFactors = F)
splitted_file <- args[2]

tsv_file <- tsv_file %>%
  mutate(Consequence = strsplit(as.character(Consequence), ",")) %>%
  unnest(Consequence)

if (tsv_file$STRAND == 1) {
  print("+")

}

# save tsv
write.table(x = tsv_file,
            file = splitted_file,
            append = F, quote = F,
            sep = "\t",
            row.names = F, col.names = T)
