# Loading data from WoS plaintext files for systematic literature reviews (SLRs)
# Date: 20-08-2024
# Author: Carl-Emil Pless

# Clear workspace
rm(list = ls())

# Load necessary libraries
library(here)
library(bibliometrix)
library(synthesisr)
library(tidyverse)

# Generate list of files
wos_list <- list.files(here("data", "raw_data", "slrs"), pattern = "*.txt")

# Load files from list into bibliometrix
wos <- convert2df(
    here("data", "raw_data", "slrs", wos_list),
    dbsource = "wos",
    format = "plaintext"
)

# Number of documents
nrow(wos)

    ## 642

# Remove documents with exact same title
wos_deduplicated <- deduplicate(
    wos,
    match_by = "TI",
    method = "exact"
)

# Number of removed documents
nrow(wos) - nrow(wos_deduplicated)

    ## 0

# Remove documents with missing authors, title, year, keywords, or subject
biblio <- wos_deduplicated %>%
    filter(!apply(is.na(select(., AU, TI, PY)), 1, any))

# Number of removed documents
nrow(wos_deduplicated) - nrow(biblio)

    ## 0

# Save to RDS file
saveRDS(biblio, file = here("data", "wrangled_data", "slrs", "biblio.rds"))

# Export to CSV file
write_csv(biblio, here("data", "wrangled_data", "slrs", "biblio.csv"))